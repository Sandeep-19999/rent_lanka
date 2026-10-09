import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/account_deletion_service.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.service});

  final AccountDeletionService service;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_busy) return;
    if (widget.service.requiresPassword && _password.text.isEmpty) {
      setState(() => _error = 'Enter your current password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.service.deleteAccount(password: _password.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        FirebaseAuthException(code: 'wrong-password' || 'invalid-credential') =>
          'Current password is incorrect.',
        FirebaseAuthException(code: 'requires-recent-login') =>
          'Please sign in again, then retry deleting your account.',
        FirebaseAuthException(code: 'unsupported-provider') =>
          'Account deletion is unavailable for this sign-in method.',
        FirebaseAuthException(code: 'user-not-found' || 'user-mismatch') =>
          'Your login changed. Please sign in again.',
        FirebaseAuthException(code: 'player-account-required') =>
          'Please use the Sports Player account profile.',
        FirebaseException(code: 'permission-denied') =>
          'Unable to delete account data. Please contact support.',
        _ =>
          'Deletion could not finish. Some account data may already have '
              'been removed. Please retry.',
      };
      setState(() {
        _busy = false;
        _error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Delete Account?',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your account, profile, favourites, notifications, support '
              'reports and reviews will be permanently deleted. This cannot be undone. '
              'Shared booking, payment, exchange and chat records are retained.',
            ),
            if (widget.service.requiresPassword) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                enabled: !_busy,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFED1235))),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy ? null : _delete,
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFED1235)),
          child: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete Account'),
        ),
      ],
    ),
  );
}
