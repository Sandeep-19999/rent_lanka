import 'package:flutter/material.dart';
import 'package:rent_lanka_mobile/features/provider/screens/provider_dashboard.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/user_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/home/home_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  static const Color primaryRed = Color(0xFFE31E24);
  static const Color darkText = Color(0xFF171717);

  String? _selectedRole;
  bool _isLoading = false;

  final UserService _userService = UserService();

  void _selectRole(String role) {
    if (_isLoading) return;

    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _continue() async {
  if (_isLoading) return;

  if (_selectedRole == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a role to continue.'),
        backgroundColor: Color(0xFFB3261E),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final String role = _selectedRole!;

  setState(() {
    _isLoading = true;
  });

  try {
    // Save selected role to Firestore
    await _userService.saveUserRole(role);

    if (!mounted) return;

    // Sports Player -> User Home
    if (role == 'player') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
      return;
    }

    // Equipment Provider -> Existing Provider Dashboard
    if (role == 'provider') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const ProviderDashboard(),
        ),
        (route) => false,
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to save your role. Please try again.'),
        backgroundColor: Color(0xFFB3261E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
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
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 620,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Your Role',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'How would you like to use Rent Lanka?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF777777),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  _RoleCard(
                    title: 'Sports Player',
                    description:
                        'Discover and rent sports equipment for your activities.',
                    icon: Icons.sports_basketball_outlined,
                    selected: _selectedRole == 'player',
                    onTap: () => _selectRole('player'),
                  ),

                  const SizedBox(height: 18),

                  _RoleCard(
                    title: 'Equipment Provider',
                    description:
                        'List your sports equipment and manage rental requests.',
                    icon: Icons.storefront_outlined,
                    selected: _selectedRole == 'provider',
                    onTap: () => _selectRole('provider'),
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _continue,
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
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Center(
                    child: Text(
                      'You can update your role later from your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
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

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFE31E24);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selected
                ? primaryRed.withValues(alpha: 0.06)
                : const Color(0xFFF8F8FA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? primaryRed
                  : const Color(0xFFE5E5E5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: selected
                      ? primaryRed
                      : primaryRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 29,
                  color: selected ? Colors.white : primaryRed,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? primaryRed
                    : const Color(0xFFAAAAAA),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
