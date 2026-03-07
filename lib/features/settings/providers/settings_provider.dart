import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class SettingsState {
  final String languageCode;
  final bool pushNotificationsEnabled;
  final bool attendanceAlerts;
  final bool teacherParentMessages;
  final bool systemUpdates;
  final bool biometricEnabled;
  final int sessionTimeoutMinutes; // 0 = never
  final bool backupEnabled;
  final bool policyConsent;

  const SettingsState({
    this.languageCode = 'en',
    this.pushNotificationsEnabled = true,
    this.attendanceAlerts = true,
    this.teacherParentMessages = true,
    this.systemUpdates = true,
    this.biometricEnabled = false,
    this.sessionTimeoutMinutes = 30,
    this.backupEnabled = false,
    this.policyConsent = false,
  });

  SettingsState copyWith({
    String? languageCode,
    bool? pushNotificationsEnabled,
    bool? attendanceAlerts,
    bool? teacherParentMessages,
    bool? systemUpdates,
    bool? biometricEnabled,
    int? sessionTimeoutMinutes,
    bool? backupEnabled,
    bool? policyConsent,
  }) =>
      SettingsState(
        languageCode: languageCode ?? this.languageCode,
        pushNotificationsEnabled:
            pushNotificationsEnabled ?? this.pushNotificationsEnabled,
        attendanceAlerts: attendanceAlerts ?? this.attendanceAlerts,
        teacherParentMessages:
            teacherParentMessages ?? this.teacherParentMessages,
        systemUpdates: systemUpdates ?? this.systemUpdates,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        sessionTimeoutMinutes:
            sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
        backupEnabled: backupEnabled ?? this.backupEnabled,
        policyConsent: policyConsent ?? this.policyConsent,
      );
}

// ─── Language options ─────────────────────────────────────────────────────────

const kLanguageOptions = [
  (code: 'en', name: 'English', native: 'English'),
  (code: 'zu', name: 'isiZulu', native: 'isiZulu'),
  (code: 've', name: 'Tshivenda', native: 'Tshivenda'),
  (code: 'af', name: 'Afrikaans', native: 'Afrikaans'),
];

String languageDisplayName(String code) =>
    kLanguageOptions.firstWhere((l) => l.code == code,
        orElse: () => kLanguageOptions.first).name;

// ─── Session timeout options ──────────────────────────────────────────────────

const kTimeoutOptions = [
  (minutes: 0, label: 'Never'),
  (minutes: 15, label: '15 minutes'),
  (minutes: 30, label: '30 minutes'),
  (minutes: 60, label: '1 hour'),
  (minutes: 120, label: '2 hours'),
];

String timeoutLabel(int minutes) =>
    kTimeoutOptions.firstWhere((t) => t.minutes == minutes,
        orElse: () => kTimeoutOptions[2]).label;

// ─── Prefs keys ───────────────────────────────────────────────────────────────

abstract final class _Keys {
  static const language = 'settings_language';
  static const pushNotif = 'settings_push_notif';
  static const attendance = 'settings_attendance_alerts';
  static const messages = 'settings_messages';
  static const sysUpdates = 'settings_system_updates';
  static const biometric = 'settings_biometric';
  static const sessionTimeout = 'settings_session_timeout';
  static const backup = 'settings_backup';
  static const policyConsent = 'settings_policy_consent';
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _load();
    return const SettingsState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      languageCode: prefs.getString(_Keys.language) ?? 'en',
      pushNotificationsEnabled: prefs.getBool(_Keys.pushNotif) ?? true,
      attendanceAlerts: prefs.getBool(_Keys.attendance) ?? true,
      teacherParentMessages: prefs.getBool(_Keys.messages) ?? true,
      systemUpdates: prefs.getBool(_Keys.sysUpdates) ?? true,
      biometricEnabled: prefs.getBool(_Keys.biometric) ?? false,
      sessionTimeoutMinutes: prefs.getInt(_Keys.sessionTimeout) ?? 30,
      backupEnabled: prefs.getBool(_Keys.backup) ?? false,
      policyConsent: prefs.getBool(_Keys.policyConsent) ?? false,
    );
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Keys.language, code);
  }

  Future<void> setPushNotifications(bool value) async {
    state = state.copyWith(pushNotificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.pushNotif, value);
  }

  Future<void> setAttendanceAlerts(bool value) async {
    state = state.copyWith(attendanceAlerts: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.attendance, value);
  }

  Future<void> setTeacherParentMessages(bool value) async {
    state = state.copyWith(teacherParentMessages: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.messages, value);
  }

  Future<void> setSystemUpdates(bool value) async {
    state = state.copyWith(systemUpdates: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.sysUpdates, value);
  }

  Future<void> setBiometric(bool value) async {
    state = state.copyWith(biometricEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.biometric, value);
  }

  Future<void> setSessionTimeout(int minutes) async {
    state = state.copyWith(sessionTimeoutMinutes: minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_Keys.sessionTimeout, minutes);
  }

  Future<void> setBackup(bool value) async {
    state = state.copyWith(backupEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.backup, value);
  }

  Future<void> setPolicyConsent(bool value) async {
    state = state.copyWith(policyConsent: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.policyConsent, value);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

// ─── App version provider ─────────────────────────────────────────────────────

final appVersionProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});
