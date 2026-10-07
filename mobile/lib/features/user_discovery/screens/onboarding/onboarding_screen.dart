import 'package:flutter/material.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/auth/login_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color primaryRed = Color(0xFFE31E24);
  static const Color darkText = Color(0xFF171717);

  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      icon: Icons.search_rounded,
      smallIcon: Icons.sports_cricket_rounded,
      title: 'Find the Equipment You Need',
      description:
          'Discover the right sports equipment quickly and easily for your next game.',
      label: 'Discover Equipment',
    ),
    OnboardingItem(
      icon: Icons.swap_horiz_rounded,
      smallIcon: Icons.cached_rounded,
      title: 'Rent or Exchange with Ease',
      description:
          'Rent what you need or exchange equipment you already have without the high cost of buying.',
      label: 'Rent & Exchange',
    ),
    OnboardingItem(
      icon: Icons.groups_rounded,
      smallIcon: Icons.favorite_rounded,
      title: 'Join the Sports Community',
      description:
          'Connect with other sports enthusiasts, share equipment and enjoy sports together.',
      label: 'Sports Community',
    ),
  ];

  void _nextPage() {
  if (_currentPage < _pages.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipOnboarding() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // ---------------- TOP BAR ----------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 20, 4),
                  child: Row(
                    children: [
                      const Text(
                        'Rent ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: darkText,
                        ),
                      ),
                      const Text(
                        'Lanka',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: primaryRed,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------- PAGE CONTENT ----------------
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        item: _pages[index],
                        availableHeight: constraints.maxHeight,
                      );
                    },
                  ),
                ),

                // ---------------- PAGE INDICATOR ----------------
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) {
                        final selected = index == _currentPage;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: selected ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: selected
                                ? primaryRed
                                : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ---------------- BUTTONS ----------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Row(
                    children: [
                      if (_currentPage > 0) ...[
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: const BorderSide(
                                color: Color(0xFFE2E2E2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Get Started'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// SINGLE ONBOARDING PAGE
// ============================================================

class OnboardingPage extends StatefulWidget {
  final OnboardingItem item;
  final double availableHeight;

  const OnboardingPage({
    super.key,
    required this.item,
    required this.availableHeight,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Smaller illustration automatically used on short screens.
    final bool shortScreen = widget.availableHeight < 750;

    final double illustrationSize = shortScreen ? 205 : 255;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const SizedBox(height: 8),

            ScaleTransition(
              scale: _scaleAnimation,
              child: IllustrationCard(
                icon: widget.item.icon,
                smallIcon: widget.item.smallIcon,
                size: illustrationSize,
              ),
            ),

            SizedBox(height: shortScreen ? 20 : 30),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                widget.item.label,
                style: const TextStyle(
                  color: Color(0xFFE31E24),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 14),

            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: shortScreen ? 25 : 29,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: const Color(0xFF171717),
                ),
              ),
            ),

            const SizedBox(height: 12),

            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Text(
                widget.item.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: shortScreen ? 14 : 15,
                  height: 1.5,
                  color: const Color(0xFF777777),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ILLUSTRATION
// ============================================================

class IllustrationCard extends StatelessWidget {
  final IconData icon;
  final IconData smallIcon;
  final double size;

  const IllustrationCard({
    super.key,
    required this.icon,
    required this.smallIcon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.17),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF6F6),
            Color(0xFFFFE6E8),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative circle
          Positioned(
            top: size * 0.10,
            right: size * 0.10,
            child: Container(
              width: size * 0.17,
              height: size * 0.17,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Decorative small circle
          Positioned(
            left: size * 0.10,
            bottom: size * 0.12,
            child: Container(
              width: size * 0.11,
              height: size * 0.11,
              decoration: const BoxDecoration(
                color: Color(0xFFFFCDD0),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main icon card
          Container(
            width: size * 0.51,
            height: size * 0.51,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: size * 0.27,
              color: const Color(0xFFE31E24),
            ),
          ),

          // Small floating icon
          Positioned(
            right: size * 0.11,
            bottom: size * 0.14,
            child: Container(
              width: size * 0.20,
              height: size * 0.20,
              decoration: BoxDecoration(
                color: const Color(0xFFE31E24),
                borderRadius: BorderRadius.circular(size * 0.065),
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Icon(
                smallIcon,
                size: size * 0.09,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ONBOARDING DATA MODEL
// ============================================================

class OnboardingItem {
  final IconData icon;
  final IconData smallIcon;
  final String title;
  final String description;
  final String label;

  const OnboardingItem({
    required this.icon,
    required this.smallIcon,
    required this.title,
    required this.description,
    required this.label,
  });
}