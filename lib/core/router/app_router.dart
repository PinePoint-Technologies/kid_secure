import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/firebase_providers.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/setup_screen.dart';
import '../../features/super_admin/screens/super_admin_shell.dart';
import '../../features/super_admin/screens/super_admin_dashboard_screen.dart';
import '../../features/super_admin/screens/creche_list_screen.dart';
import '../../features/super_admin/screens/creche_form_screen.dart';
import '../../features/super_admin/screens/teacher_assignment_screen.dart';
import '../../features/super_admin/screens/admin_add_user_screen.dart';
import '../../features/super_admin/screens/admin_add_kid_screen.dart';
import '../../features/super_admin/screens/link_parent_screen.dart';
import '../../features/super_admin/screens/parents_management_screen.dart';
import '../../features/super_admin/screens/kids_management_screen.dart';
import '../../features/super_admin/screens/admin_reports_screen.dart';
import '../../features/teacher/screens/teacher_shell.dart';
import '../../features/teacher/screens/teacher_home_screen.dart';
import '../../features/teacher/screens/kids_list_screen.dart';
import '../../features/teacher/screens/kid_detail_screen.dart';
import '../../features/teacher/screens/add_kid_screen.dart';
import '../../features/teacher/screens/attendance_overview_screen.dart';
import '../../features/teacher/screens/teacher_sick_leave_screen.dart';
import '../../features/teacher/screens/teacher_guardian_checkin_screen.dart';
import '../../features/parent/screens/parent_shell.dart';
import '../../features/parent/screens/parent_home_screen.dart';
import '../../features/parent/sign_in_out/sign_in_out_screen.dart';
import '../../features/parent/guardians/guardian_list_screen.dart';
import '../../features/parent/guardians/add_guardian_screen.dart';
import '../../features/parent/sick_leave/sick_leave_screen.dart';
import '../../features/parent/sick_leave/log_sick_leave_screen.dart';
import '../../features/auth/screens/invite_register_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/edit_profile_screen.dart';
import '../../features/settings/screens/change_password_screen.dart';
import '../../features/settings/screens/language_screen.dart';
import '../../features/settings/screens/notifications_screen.dart';
import '../../features/settings/screens/appearance_screen.dart';
import '../../features/settings/screens/terms_screen.dart';
import '../../features/settings/screens/privacy_screen.dart';
import '../../features/settings/screens/help_support_screen.dart';
import '../../features/settings/screens/security_screen.dart';
import '../../shared/models/user_model.dart';

final _rootNavKey = GlobalKey<NavigatorState>();

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const setup = '/setup'; //super-user

  // Super Admin
  static const superAdmin = '/super-admin';          // dashboard
  static const superAdminCreches = '/super-admin/creches';
  static const superAdminCrecheNew = '/super-admin/creches/new';
  static const superAdminCrecheEdit = '/super-admin/creches/:crecheId/edit';
  static const superAdminTeacherAssign =
      '/super-admin/creches/:crecheId/teachers';
  static const superAdminAddTeacher =
      '/super-admin/creches/:crecheId/teachers/new';
  static const superAdminParents = '/super-admin/parents';
  static const superAdminAddParent = '/super-admin/parents/new';
  static const superAdminKids = '/super-admin/kids';
  static const superAdminAddKid = '/super-admin/kids/new';
  static const superAdminLinkParent = '/super-admin/kids/:childId/link-parent';
  static const superAdminReports = '/super-admin/reports';

  // Teacher
  static const teacher = '/teacher';
  static const teacherKids = '/teacher/kids';
  static const teacherKidDetail = '/teacher/kids/:childId';
  static const teacherAddKid = '/teacher/kids/new';
  static const teacherLinkParent = '/teacher/kids/:childId/link-parent';
  static const teacherAttendance = '/teacher/attendance';
  static const teacherSickLeave = '/teacher/sick-leave';
  static const teacherAddParent = '/teacher/parents/new';
  static const teacherGuardianCheckin = '/teacher/guardian-checkin';

  // Parent
  static const parent = '/parent';
  static const parentSignInOut = '/parent/sign-in-out';
  static const parentGuardians = '/parent/guardians';
  static const parentAddGuardian = '/parent/guardians/new';
  static const parentSickLeave = '/parent/sick-leave';
  static const parentLogSickLeave = '/parent/sick-leave/new';

  // Invite registration (no auth required)
  static const inviteRegister = '/invite/register';

  // Settings (accessible from all roles)
  static const settings = '/settings';
  static const settingsEditProfile = '/settings/edit-profile';
  static const settingsChangePassword = '/settings/change-password';
  static const settingsLanguage = '/settings/language';
  static const settingsNotifications = '/settings/notifications';
  static const settingsAppearance = '/settings/appearance';
  static const settingsTerms = '/settings/terms';
  static const settingsPrivacy = '/settings/privacy';
  static const settingsHelp = '/settings/help';
  static const settingsSecurity = '/settings/security';

  // ─── Path helpers (substitutes path parameters) ───────────────────────────

  static String superAdminTeacherAssignPath(String crecheId) =>
      '/super-admin/creches/$crecheId/teachers';

  static String superAdminAddTeacherPath(String crecheId) =>
      '/super-admin/creches/$crecheId/teachers/new';

  static String superAdminCrecheEditPath(String crecheId) =>
      '/super-admin/creches/$crecheId/edit';

  static String superAdminLinkParentPath(String childId) =>
      '/super-admin/kids/$childId/link-parent';

  static String teacherLinkParentPath(String childId) =>
      '/teacher/kids/$childId/link-parent';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return AppRoutes.splash;

      final firebaseUser = authState.valueOrNull;
      final isLoggedIn = firebaseUser != null;
      final isLoginRoute = state.uri.toString().startsWith('/login') ||
          state.uri.toString().startsWith('/register') ||
          state.uri.toString().startsWith('/setup') ||
          state.uri.toString().startsWith('/invite') ||
          state.uri.toString().startsWith('/onboarding') ||
          state.uri.toString() == AppRoutes.splash;

      if (!isLoggedIn && !isLoginRoute) return AppRoutes.login;
      if (isLoggedIn && (state.uri.toString() == AppRoutes.login ||
          state.uri.toString() == AppRoutes.register ||
          state.uri.toString() == AppRoutes.splash)) {
        final user = currentUser.valueOrNull;
        if (user == null) return null; // still loading user profile
        return switch (user.role) {
          UserRole.superAdmin => AppRoutes.superAdmin,
          UserRole.teacher => AppRoutes.teacher,
          UserRole.parent => AppRoutes.parent,
        };
      }
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.inviteRegister,
        builder: (_, state) => InviteRegisterScreen(
          initialToken: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.setup,
        builder: (_, __) => const SetupScreen(),
      ),

      // ─── Settings (root navigator — no shell, no bottom nav) ─────────────
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsEditProfile,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsChangePassword,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsLanguage,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsNotifications,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAppearance,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const AppearanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsTerms,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacy,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsHelp,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsSecurity,
        parentNavigatorKey: _rootNavKey,
        builder: (_, __) => const SecurityScreen(),
      ),

      // ─── Super Admin ─────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => SuperAdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.superAdmin,
            builder: (_, __) => const SuperAdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.superAdminCreches,
            builder: (_, __) => const CrecheListScreen(),
          ),
          GoRoute(
            path: AppRoutes.superAdminCrecheNew,
            builder: (_, __) => const CrecheFormScreen(),
          ),
          GoRoute(
            path: AppRoutes.superAdminCrecheEdit,
            builder: (_, state) =>
                CrecheFormScreen(crecheId: state.pathParameters['crecheId']),
          ),
          GoRoute(
            path: AppRoutes.superAdminTeacherAssign,
            builder: (_, state) => TeacherAssignmentScreen(
                crecheId: state.pathParameters['crecheId']!),
          ),
          GoRoute(
            path: AppRoutes.superAdminAddTeacher,
            builder: (_, state) => AdminAddUserScreen(
              role: UserRole.teacher,
              initialCrecheId: state.pathParameters['crecheId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.superAdminParents,
            builder: (_, __) => const ParentsManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.superAdminAddParent,
            builder: (_, __) => const AdminAddUserScreen(role: UserRole.parent),
          ),
          GoRoute(
            path: AppRoutes.superAdminKids,
            builder: (_, __) => const KidsManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.superAdminAddKid,
            builder: (_, __) => const AdminAddKidScreen(),
          ),
          GoRoute(
            path: AppRoutes.superAdminLinkParent,
            builder: (_, state) => LinkParentScreen(
                childId: state.pathParameters['childId']!),
          ),
          GoRoute(
            path: AppRoutes.superAdminReports,
            builder: (_, __) => const AdminReportsScreen(),
          ),
        ],
      ),

      // ─── Teacher ─────────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => TeacherShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.teacher,
            builder: (_, __) => const TeacherHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.teacherKids,
            builder: (_, __) => const KidsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.teacherAddKid,
            builder: (_, __) => const AddKidScreen(),
          ),
          GoRoute(
            path: AppRoutes.teacherKidDetail,
            builder: (_, state) => KidDetailScreen(
                childId: state.pathParameters['childId']!),
          ),
          GoRoute(
            path: AppRoutes.teacherLinkParent,
            builder: (_, state) => LinkParentScreen(
                childId: state.pathParameters['childId']!),
          ),
          GoRoute(
            path: AppRoutes.teacherAttendance,
            builder: (_, __) => const AttendanceOverviewScreen(),
          ),
          GoRoute(
            path: AppRoutes.teacherSickLeave,
            builder: (_, __) => const TeacherSickLeaveScreen(),
          ),
          GoRoute(
            path: AppRoutes.teacherAddParent,
            builder: (_, __) => AdminAddUserScreen(
              role: UserRole.parent,
              onSuccess: (context) {
                if (context.canPop()) context.pop();
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.teacherGuardianCheckin,
            builder: (_, __) => const TeacherGuardianCheckinScreen(),
          ),
        ],
      ),

      // ─── Parent ──────────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => ParentShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.parent,
            builder: (_, __) => const ParentHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.parentSignInOut,
            builder: (_, __) => const SignInOutScreen(),
          ),
          GoRoute(
            path: AppRoutes.parentGuardians,
            builder: (_, __) => const GuardianListScreen(),
          ),
          GoRoute(
            path: AppRoutes.parentAddGuardian,
            builder: (_, __) => const AddGuardianScreen(),
          ),
          GoRoute(
            path: AppRoutes.parentSickLeave,
            builder: (_, __) => const SickLeaveScreen(),
          ),
          GoRoute(
            path: AppRoutes.parentLogSickLeave,
            builder: (_, __) => const LogSickLeaveScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
