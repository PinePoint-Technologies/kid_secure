import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/firebase_providers.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/models/user_model.dart';
import '../auth/providers/auth_provider.dart';
import '../onboarding/onboarding_screen.dart' show onboardingKeyForRole;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(themeProvider.notifier).load();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    // Await proper resolution — never read a loading snapshot
    final user = await ref.read(authStateProvider.future);
    if (!mounted) return;

    if (user == null) {
      context.go(AppRoutes.login);
      return;
    }

    final profile = await ref.read(currentUserProvider.future);
    if (!mounted) return;

    if (profile == null) {
      context.go(AppRoutes.login);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final onboardingDone =
        prefs.getBool(onboardingKeyForRole(profile.role)) ?? false;

    if (!onboardingDone) {
      context.go(AppRoutes.onboarding);
      return;
    }

    context.go(switch (profile.role) {
      UserRole.superAdmin => AppRoutes.superAdmin,
      UserRole.teacher => AppRoutes.teacher,
      UserRole.parent => AppRoutes.parent,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Real logo on white pill card
                Container(
                  width: 180,
                  height: 180,
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
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                )
                    .animate()
                    .scale(duration: 700.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 36),
                Text(
                  'Keeping little ones safe',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withAlpha(204),
                    fontSize: 17,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 500.ms),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
