import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/models/user_model.dart';

/// SharedPreferences key for a given role.
String onboardingKeyForRole(UserRole role) => 'onboarding_done_${role.name}';

// ─── Slide data ───────────────────────────────────────────────────────────────

class _Slide {
  final IconData icon;
  final String title;
  final String body;

  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
  });
}

const _superAdminSlides = [
  _Slide(
    icon: Icons.dashboard_rounded,
    title: 'Full System Control',
    body: 'Oversee every crèche, user, and activity from one powerful dashboard.',
  ),
  _Slide(
    icon: Icons.school_rounded,
    title: 'Manage Crèches',
    body: 'Create crèches, assign teachers, and keep your network organised.',
  ),
  _Slide(
    icon: Icons.group_add_rounded,
    title: 'Users & Kids',
    body: 'Enrol kids, add parents and teachers, and link families to children.',
  ),
  _Slide(
    icon: Icons.bar_chart_rounded,
    title: 'Reports & Insights',
    body: 'Track enrollment trends and sick leave across every school at a glance.',
  ),
];

const _teacherSlides = [
  _Slide(
    icon: Icons.home_rounded,
    title: 'Your Classroom Hub',
    body: 'Manage all kids in your crèche from a single, easy-to-use dashboard.',
  ),
  _Slide(
    icon: Icons.fact_check_rounded,
    title: 'Track Attendance',
    body: 'Mark sign-in, sign-out, and absent status for each child every day.',
  ),
  _Slide(
    icon: Icons.qr_code_scanner_rounded,
    title: 'Guardian Check-In',
    body: 'Scan guardian QR codes and verify PINs to ensure safe, authorised pick-ups.',
  ),
  _Slide(
    icon: Icons.family_restroom_rounded,
    title: 'Kids & Parents',
    body: 'View kid profiles, log sick leave, and link parents to children with ease.',
  ),
];

const _parentSlides = [
  _Slide(
    icon: Icons.child_care_rounded,
    title: 'Stay Close to Your Child',
    body: 'Get real-time updates on your child\'s day at the crèche.',
  ),
  _Slide(
    icon: Icons.login_rounded,
    title: 'Sign In & Out',
    body: 'See exactly when your child arrives and leaves — always in the loop.',
  ),
  _Slide(
    icon: Icons.people_alt_rounded,
    title: 'Trusted Guardians',
    body: 'Add trusted guardians who are authorised to pick up your child.',
  ),
  _Slide(
    icon: Icons.medical_services_rounded,
    title: 'Sick Leave',
    body: 'Log your child\'s sick days and keep the crèche informed instantly.',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  UserRole? get _role => ref.read(currentUserProvider).valueOrNull?.role;

  List<_Slide> get _slides => switch (_role) {
        UserRole.superAdmin => _superAdminSlides,
        UserRole.teacher => _teacherSlides,
        UserRole.parent => _parentSlides,
        null => _superAdminSlides,
      };

  String get _dashboard => switch (_role) {
        UserRole.superAdmin => AppRoutes.superAdmin,
        UserRole.teacher => AppRoutes.teacher,
        UserRole.parent => AppRoutes.parent,
        null => AppRoutes.login,
      };

  LinearGradient get _gradient => switch (_role) {
        UserRole.superAdmin => AppColors.superAdminGradient,
        UserRole.teacher => AppColors.teacherGradient,
        UserRole.parent => AppColors.parentGradient,
        null => AppColors.splashGradient,
      };

  Color get _accentColor => switch (_role) {
        UserRole.superAdmin => AppColors.superAdmin,
        UserRole.teacher => AppColors.primaryLight,
        UserRole.parent => AppColors.accent,
        null => AppColors.primaryLight,
      };

  Future<void> _finish() async {
    final role = _role;
    if (role != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(onboardingKeyForRole(role), true);
    }
    if (mounted) context.go(_dashboard);
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    final isLast = _page == slides.length - 1;
    final accent = _accentColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                  ),
                ),
              ),

              // Slides
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: slides.length,
                  itemBuilder: (_, i) =>
                      _SlidePage(slide: slides[i], iconColor: accent),
                ),
              ),

              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          active ? Colors.white : Colors.white.withAlpha(80),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Next / Get Started
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      key: ValueKey(isLast),
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLast ? 'Get Started' : 'Next',
                        style: AppTextStyles.button.copyWith(color: accent),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Single slide ─────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  final Color iconColor;

  const _SlidePage({required this.slide, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Icon(slide.icon, size: 80, color: iconColor),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 48),
          Text(
            slide.title,
            style: AppTextStyles.headline2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            slide.body,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withAlpha(200),
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
