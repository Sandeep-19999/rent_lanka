
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:rent_lanka_mobile/features/user_discovery/services/auth_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/user_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/auth/forgot_password_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/auth/signup_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/home/home_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/role/role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryRed = Color(0xFFE31E24);
  static const Color darkText = Color(0xFF171717);

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

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
  // NAVIGATION AFTER LOGIN
  // =========================================================

  Future<void> _navigateAfterLogin() async {
    try {
      final String? role =
          await _userService.getCurrentUserRole();

      if (!mounted) return;

      final String normalizedRole =
          (role ?? '').trim().toLowerCase();

      debugPrint('CURRENT USER ROLE: $normalizedRole');

      // PLAYER -> HOME SCREEN
      if (normalizedRole == 'player') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
        return;
      }

      // PROVIDER -> EXISTING PROVIDER FLOW
      // Provider navigation will be integrated by the team.
      if (normalizedRole == 'provider') {
        _showMessage(
          'Provider account signed in successfully.',
          isError: false,
        );
        return;
      }

      // NO ROLE -> ROLE SELECTION SCREEN
      if (normalizedRole.isEmpty) {
        debugPrint(
          'NO ROLE FOUND: Navigating to Role Selection',
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const RoleSelectionScreen(),
          ),
          (route) => false,
        );
        return;
      }

      _showMessage(
        'Unknown account role: $normalizedRole',
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('ROLE CHECK ERROR: $e');

      _showMessage(
        'Unable to load your account role. Please try again.',
      );
    }
  }

  // =========================================================
  // EMAIL + PASSWORD LOGIN
  // =========================================================

  Future<void> _login() async {
    if (_isLoading || _isGoogleLoading) return;

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

      debugPrint(
        'EMAIL LOGIN SUCCESS: ${credential.user?.email}',
      );

      await _navigateAfterLogin();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message =
          'Unable to sign in. Please try again.';

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
          message =
              'Too many login attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message =
              'Please check your internet connection.';
          break;
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      debugPrint('EMAIL LOGIN ERROR: $e');

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
    if (_isGoogleLoading || _isLoading) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      debugPrint('GOOGLE SIGN IN STARTED');

      final UserCredential credential =
          await _authService.signInWithGoogle();

      debugPrint('GOOGLE SIGN IN SUCCESS');
      debugPrint('UID: ${credential.user?.uid}');
      debugPrint('EMAIL: ${credential.user?.email}');
      debugPrint('NAME: ${credential.user?.displayName}');

      if (!mounted) return;

      // CHECK USER ROLE AND NAVIGATE
      await _navigateAfterLogin();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint('GOOGLE AUTH ERROR: ${e.code}');
      debugPrint('ERROR MESSAGE: ${e.message}');

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
      if (!mounted) return;

      debugPrint('GOOGLE SIGN IN ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      _showMessage(
        'Google Sign-In error: $e',
      );
    } finally {
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

      String message =
          'Unable to send password reset email.';

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'too-many-requests':
          message =
              'Too many requests. Please try again later.';
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
  // SNACKBAR
  // =========================================================

  void _showMessage(
    String message, {
    bool isError = true,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB3261E)
            : const Color(0xFF2E7D32),
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

  // =========================================================
  // LOGIN UI
  // =========================================================

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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
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
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

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
                        if (!_isLoading &&
                            !_isGoogleLoading) {
                          _login();
                        }
                      },
                      decoration: _inputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon:
                            Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons.visibility_outlined,
                            color:
                                const Color(0xFF5F5B66),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter your password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

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
                                _rememberMe =
                                    value ?? false;
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
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
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

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed:
                            (_isLoading || _isGoogleLoading)
                                ? null
                                : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              primaryRed.withValues(
                            alpha: 0.55,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
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

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton(
                        onPressed:
                            (_isGoogleLoading || _isLoading)
                                ? null
                                : _googleSignIn,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkText,
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: _isGoogleLoading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child:
                                    CircularProgressIndicator(
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

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SignUpScreen(),
                              ),
                            );
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
          color: Color(0xFFE1E1E1),
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
