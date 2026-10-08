import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/role/role_selection_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const Color primaryRed = Color(0xFFE31E24);
  static const Color darkText = Color(0xFF171717);

  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage(
          'No signed-in user found. Please sign in again.',
          isError: true,
        );
        return;
      }

      // Get latest user information from Firebase
      await user.reload();

      user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user != null && user.emailVerified) {
        _showMessage(
          'Email verified successfully!',
          isError: false,
        );

        Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const RoleSelectionScreen(),
    ),
  );
      } else {
        _showMessage(
          'Email is not verified yet. Please check your inbox and verify your email.',
          isError: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message ?? 'Unable to check email verification.',
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage(
          'No signed-in user found. Please sign in again.',
          isError: true,
        );
        return;
      }

      if (user.emailVerified) {
        _showMessage(
          'Your email is already verified.',
          isError: false,
        );
        return;
      }

      await user.sendEmailVerification();

      if (!mounted) return;

      _showMessage(
        'Verification email sent again. Please check your inbox.',
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'too-many-requests':
          message =
              'Too many requests. Please wait before trying again.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message =
              e.message ?? 'Unable to resend verification email.';
      }

      _showMessage(
        message,
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: isError
            ? const Color(0xFFB3261E)
            : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String email =
        FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 620,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 26,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 36),

                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: primaryRed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      color: primaryRed,
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'We sent a verification link to',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF777777),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Open the email and click the verification link. Then return to Rent Lanka and continue below.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF777777),
                    ),
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed:
                          _isChecking ? null : _checkVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            primaryRed.withValues(alpha: 0.55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isChecking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "I've Verified My Email",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Didn't receive the email?",
                          style: TextStyle(
                            color: Color(0xFF777777),
                          ),
                        ),
                        TextButton(
                          onPressed: _isResending
                              ? null
                              : _resendVerificationEmail,
                          child: _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryRed,
                                  ),
                                )
                              : const Text(
                                  'Resend',
                                  style: TextStyle(
                                    color: primaryRed,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}