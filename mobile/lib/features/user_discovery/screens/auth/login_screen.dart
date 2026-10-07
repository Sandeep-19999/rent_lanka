import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:rent_lanka_mobile/features/user_discovery/services/auth_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/auth/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryRed = Color(0xFFE31E24);
  static const Color darkText = Color(0xFF171717);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================================================
  // EMAIL + PASSWORD LOGIN
  // =========================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential credential =
          await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final User? user = credential.user;

      _showMessage(
        user?.email != null
            ? 'Welcome ${user!.email}!'
            : 'Login successful!',
        isError: false,
      );

      // NEXT STEP:
      // Navigate to Role Selection / Home screen here.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Unable to sign in. Please try again.';

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // GOOGLE SIGN IN
  // =========================================================

  Future<void> _googleSignIn() async {
  debugPrint('========================================');
  debugPrint('GOOGLE SIGN IN: Button clicked');
  debugPrint('========================================');

  if (_isGoogleLoading) {
    return;
  }

  setState(() {
    _isGoogleLoading = true;
  });

  try {
    debugPrint('GOOGLE SIGN IN: Calling AuthService...');

    final UserCredential credential =
        await _authService.signInWithGoogle();

    debugPrint('GOOGLE SIGN IN: Firebase returned successfully');
    debugPrint('USER UID: ${credential.user?.uid}');
    debugPrint('USER EMAIL: ${credential.user?.email}');
    debugPrint('USER NAME: ${credential.user?.displayName}');

    if (!mounted) return;

    final User? user = credential.user;

    _showMessage(
      user?.displayName != null
          ? 'Welcome ${user!.displayName}!'
          : 'Google Sign-In successful!',
      isError: false,
    );

    // Later:
    // Navigate to Role Selection / Home screen here.
  } on FirebaseAuthException catch (e) {
    debugPrint('========================================');
    debugPrint('FIREBASE AUTH ERROR');
    debugPrint('ERROR CODE: ${e.code}');
    debugPrint('ERROR MESSAGE: ${e.message}');
    debugPrint('========================================');

    if (!mounted) return;

    String message;

    switch (e.code) {
      case 'popup-closed-by-user':
        message = 'Google Sign-In was cancelled.';
        break;

      case 'popup-blocked':
        message =
            'Google Sign-In popup was blocked. Please allow popups in Chrome.';
        break;

      case 'unauthorized-domain':
        message =
            'This domain is not authorized in Firebase Authentication.';
        break;

      case 'operation-not-allowed':
        message =
            'Google Sign-In is not enabled in Firebase Authentication.';
        break;

      case 'account-exists-with-different-credential':
        message =
            'An account already exists with this email using another sign-in method.';
        break;

      case 'network-request-failed':
        message =
            'Network error. Please check your internet connection.';
        break;

      default:
        message =
            'Firebase error: ${e.code}\n${e.message ?? 'Unknown error'}';
    }

    _showMessage(message);
  } catch (e, stackTrace) {
    debugPrint('========================================');
    debugPrint('GOOGLE SIGN IN UNKNOWN ERROR');
    debugPrint('ERROR: $e');
    debugPrint('STACK TRACE: $stackTrace');
    debugPrint('========================================');

    if (!mounted) return;

    _showMessage(
      'Google Sign-In error: $e',
    );
  } finally {
    debugPrint('GOOGLE SIGN IN: Finished');

    if (mounted) {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }
}

  // =========================================================
  // FORGOT PASSWORD
  // =========================================================

  Future<void> _forgotPassword() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'Please enter your email address first.',
      );
      return;
    }

    if (!email.contains('@')) {
      _showMessage(
        'Please enter a valid email address.',
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);

      if (!mounted) return;

      _showMessage(
        'Password reset email sent. Please check your inbox.',
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Unable to send password reset email.';

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          break;
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  // =========================================================
  // SNACKBAR MESSAGE
  // =========================================================

  void _showMessage(
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFB3261E) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // INPUT DECORATION
  // =========================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF777777),
        fontSize: 15,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 21,
        color: const Color(0xFF5F5B66),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F7F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5E5E5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryRed,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryRed,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryRed,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // TITLE
                    // =================================================

                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Sign in to continue discovering sports equipment.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF777777),
                      ),
                    ),

                    const SizedBox(height: 38),

                    // =================================================
                    // EMAIL
                    // =================================================

                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // PASSWORD
                    // =================================================

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _login();
                        }
                      },
                      decoration: _inputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF5F5B66),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // =================================================
                    // REMEMBER ME + FORGOT PASSWORD
                    // =================================================

                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: primaryRed,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ForgotPasswordScreen(),
    ),
  );
},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: primaryRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // =================================================
                    // SIGN IN BUTTON
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
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
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // DIVIDER
                    // =================================================

                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFFE3E3E3),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Color(0xFFE3E3E3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // GOOGLE SIGN IN BUTTON
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton(
                        onPressed:
                            _isGoogleLoading ? null : _googleSignIn,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkText,
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isGoogleLoading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.3,
                                  color: primaryRed,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  _GoogleLogo(),
                                  SizedBox(width: 12),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // =================================================
                    // CREATE ACCOUNT
                    // =================================================

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            // NEXT STEP:
                            // Navigate to SignUpScreen.
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: primaryRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// GOOGLE LOGO
// =============================================================

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE1E1E1),
        ),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}