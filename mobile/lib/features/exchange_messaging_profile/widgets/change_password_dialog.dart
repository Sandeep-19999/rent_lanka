import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/password_service.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key, this.service});

  final PasswordService? service;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late final PasswordService _service = widget.service ?? PasswordService();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.changePassword(_current.text, _password.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = switch (error.code) {
          'wrong-password' || 'invalid-credential' =>
            'Current password is incorrect.',
          'weak-password' =>
            'Choose a stronger password that meets your account requirements.',
          'network-request-failed' => 'Check your connection and try again.',
          'too-many-requests' => 'Too many attempts. Please try again later.',
          'requires-recent-login' || 'user-token-expired' || 'user-not-found' =>
            'Please sign in again before changing your password.',
          'password-provider-required' =>
            'Manage your password through your sign-in provider.',
          _ => 'Unable to update your password. Please try again.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to update your password. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supported = _service.supportsPassword;
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: const Text('Change password'),
        content: SingleChildScrollView(
          child: supported
              ? Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _field(_current, 'Current password', (value) =>
                          value == null || value.isEmpty
                              ? 'Enter your current password.'
                              : null),
                      const SizedBox(height: 12),
                      _field(_password, 'New password', (value) {
                        if (value == null || value.length < 6) {
                          return 'Use at least 6 characters.';
                        }
                        if (value == _current.text) {
                          return 'Choose a different password.';
                        }
                        return null;
                      }),
                      const SizedBox(height: 12),
                      _field(_confirm, 'Confirm new password', (value) =>
                          value != _password.text
                              ? 'Passwords do not match.'
                              : null),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        )),
                      ],
                    ],
                  ),
                )
              : const Text(
                  'This account uses a sign-in provider such as Google. '
                  'Manage your password through that provider.',
                ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: Text(supported ? 'Cancel' : 'Close'),
          ),
          if (supported)
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFED1235),
                foregroundColor: Colors.white,
              ),
              child: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Update'),
            ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
      String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      autocorrect: false,
      enableSuggestions: false,
      enabled: !_saving,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }
}
