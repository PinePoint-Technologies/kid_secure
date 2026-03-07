abstract final class AppConstants {
  // Collection names
  static const String colUsers = 'users';
  static const String colCreches = 'creches';
  static const String colChildren = 'children';
  static const String colGuardians = 'guardians';
  static const String colAttendance = 'attendance';
  static const String colSickLeave = 'sick_leave';
  static const String colNotifications = 'notifications';
  static const String colPayments = 'payments';
  static const String colInvoices = 'invoices';
  static const String colLocations = 'locations';
  static const String colInvites = 'invites';
  static const String colAuditLogs = 'audit_logs';

  // SharedPreferences keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefLocale = 'locale';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefUserRole = 'user_role';
  static const String prefSelectedCreche = 'selected_creche';

  // Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleTeacher = 'teacher';
  static const String roleParent = 'parent';

  // Attendance status
  static const String attendanceSignedIn = 'signed_in';
  static const String attendanceSignedOut = 'signed_out';
  static const String attendanceAbsent = 'absent';
  static const String attendanceSickLeave = 'sick_leave';

  // Pagination
  static const int pageSize = 20;

  // GPS
  static const double geofenceRadiusMeters = 200;
  static const int locationUpdateIntervalSecs = 30;

  // App
  static const String appName = 'KidSecure';
  static const String supportEmail = 'support@kidsecure.app';
  static const String privacyPolicyUrl = 'https://kidsecure.app/privacy';
  static const String termsUrl = 'https://kidsecure.app/terms';
}
