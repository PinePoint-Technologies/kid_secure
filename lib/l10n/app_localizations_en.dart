// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'KidSecure';

  @override
  String get appTagline => 'Creche Management Platform';

  @override
  String get splashTagline => 'Keeping little ones safe';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get update => 'Update';

  @override
  String get confirm => 'Confirm';

  @override
  String get submit => 'Submit';

  @override
  String get remove => 'Remove';

  @override
  String get approve => 'Approve';

  @override
  String get optional => 'optional';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get minSixChars => 'Min. 6 characters';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get firstTimeSetup => 'First-time Setup (Create Admin)';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get enterEmailForReset => 'Enter your email to receive a reset link.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetEmailSent => 'Reset email sent. Check your inbox.';

  @override
  String get invitationRequired => 'Invitation Required';

  @override
  String get inviteSystemExplanation =>
      'KidSecure uses a secure invite system.\n\nAsk your school administrator for a teacher invite link, or ask your teacher for a parent invite link.';

  @override
  String get inviteStep1 => 'Receive an invite link from your school';

  @override
  String get inviteStep2 => 'Tap the link to open KidSecure';

  @override
  String get inviteStep3 => 'Complete registration — your role is pre-assigned';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get createAccount => 'Create Account';

  @override
  String invitedAs(String role) {
    return 'Invited as $role';
  }

  @override
  String get loadingCreche => 'Loading crèche…';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get minEightChars => 'Min. 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get verifyingInvite => 'Verifying invite…';

  @override
  String get inviteUnavailable => 'Invite Unavailable';

  @override
  String get createSuperAdmin => 'Create Super Admin';

  @override
  String get setupScreenTitle => 'First-time Setup';

  @override
  String get setupScreenDescription =>
      'This screen only appears once. The super admin can manage all creches, teachers, and settings.';

  @override
  String get adminDetails => 'Admin Details';

  @override
  String get emailAddressLabel => 'Email address';

  @override
  String get phoneOptionalLabel => 'Phone number (optional)';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordMinEight => 'Password must be at least 8 characters';

  @override
  String get navHome => 'Home';

  @override
  String get navSignInOut => 'Sign In/Out';

  @override
  String get navGuardians => 'Guardians';

  @override
  String get navSickLeave => 'Sick Leave';

  @override
  String get navGps => 'GPS';

  @override
  String get navKids => 'Kids';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCreches => 'Crèches';

  @override
  String get navParents => 'Parents';

  @override
  String get navReports => 'Reports';

  @override
  String helloUser(String name) {
    return 'Hello, $name';
  }

  @override
  String get myChildren => 'My Children';

  @override
  String get noChildrenLinked =>
      'No children linked yet.\nContact your teacher.';

  @override
  String get contactTeacher => 'Contact your teacher.';

  @override
  String get notYetSignedIn => 'Not yet signed in';

  @override
  String ageLabel(String age) {
    return 'Age: $age';
  }

  @override
  String get manual => 'Manual';

  @override
  String get qrScan => 'QR Scan';

  @override
  String get guardian => 'Guardian';

  @override
  String get selectChild => 'Select Child';

  @override
  String get scanQrDescription => 'Scan a child\'s QR code to sign in or out';

  @override
  String get qrNotRecognised => 'QR code not recognised.';

  @override
  String childIdentified(String name) {
    return '$name identified! Tap sign in/out below.';
  }

  @override
  String childStatus(String name) {
    return '$name\'s Status';
  }

  @override
  String signedInAt(String time) {
    return 'Signed in at $time';
  }

  @override
  String get notYetSignedInToday => 'Not yet signed in today';

  @override
  String get signOut => 'Sign Out';

  @override
  String get noGuardians => 'No guardians added yet';

  @override
  String get noPermission => 'No permission';

  @override
  String get trustedGuardians => 'Trusted Guardians';

  @override
  String get addGuardian => 'Add Guardian';

  @override
  String get removeGuardian => 'Remove Guardian';

  @override
  String removeGuardianConfirm(String name) {
    return 'Remove $name as a guardian?';
  }

  @override
  String get showQrDescription =>
      'Show this QR to the teacher for gate check-in';

  @override
  String get permSignIn => 'Sign In';

  @override
  String get permSignOut => 'Sign Out';

  @override
  String get permVerified => 'Verified ✓';

  @override
  String get noSickLeaveLogged => 'No sick leave logged';

  @override
  String get tapToLogSickDay => 'Tap the button below to log a sick day';

  @override
  String get logSickLeave => 'Log Sick Leave';

  @override
  String get sickLeaveHistory => 'Sick Leave History';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String symptoms(String symptoms) {
    return 'Symptoms: $symptoms';
  }

  @override
  String attachmentCount(int count) {
    return '$count attachment(s)';
  }

  @override
  String loggedTime(String time) {
    return 'Logged $time';
  }

  @override
  String get child => 'Child';

  @override
  String get startDate => 'Start Date';

  @override
  String get multipleDays => 'Multiple days';

  @override
  String get endDate => 'End Date';

  @override
  String get notSet => 'Not set';

  @override
  String get reasonForAbsence => 'Reason for absence';

  @override
  String get reasonRequired => 'Reason is required';

  @override
  String get symptomsOptional => 'Symptoms (optional)';

  @override
  String get attachments => 'Attachments';

  @override
  String get attachDoctorNotes => 'Attach doctor\'s notes (PDF, JPG, PNG)';

  @override
  String get addAttachment => 'Add Attachment';

  @override
  String get submitSickLeave => 'Submit Sick Leave';

  @override
  String get selectChildFirst => 'Please select a child';

  @override
  String get sickLeaveLoggedNotification =>
      'Sick leave logged! Teacher will be notified.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get totalKids => 'Total Kids';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String sickLeavePending(int count) {
    return '$count sick leave pending';
  }

  @override
  String get reviewAndApprove => 'Review and approve below.';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get viewKids => 'View Kids';

  @override
  String get attendance => 'Attendance';

  @override
  String get addKid => 'Add Kid';

  @override
  String get guardianCheckin => 'Guardian Check-In';

  @override
  String get inviteParent => 'Invite Parent';

  @override
  String get noCrecheAssigned => 'No crèche assigned to your account.';

  @override
  String get failedToGenerateInvite =>
      'Failed to generate invite. Please try again.';

  @override
  String kidsEnrolled(int count) {
    return '$count Kids Enrolled';
  }

  @override
  String get searchKids => 'Search kids…';

  @override
  String get allergiesWarning => 'Has allergies';

  @override
  String get todaysAttendance => 'Today\'s Attendance';

  @override
  String get signedIn => 'Signed In';

  @override
  String get signedOut => 'Signed Out';

  @override
  String get absentLabel => 'Absent';

  @override
  String get sickLeaveLabel => 'Sick Leave';

  @override
  String signInTime(String time) {
    return 'Sign-in: $time';
  }

  @override
  String signOutTime(String time) {
    return 'Sign-out: $time';
  }

  @override
  String pendingCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String approvedCount(int count) {
    return 'Approved ($count)';
  }

  @override
  String get noSickLeaveSubmitted => 'No sick leave submitted';

  @override
  String get parentsCanLog => 'Parents can log sick leave from their app';

  @override
  String get overview => 'Overview';

  @override
  String get liveCountsAllSchools => 'Live counts across all schools';

  @override
  String get schools => 'Schools';

  @override
  String get teachers => 'Teachers';

  @override
  String get kids => 'Kids';

  @override
  String get parents => 'Parents';

  @override
  String get guardians => 'Guardians';

  @override
  String get manageCreches => 'Manage Crèches';

  @override
  String schoolsRegistered(int count) {
    return '$count school(s) registered';
  }

  @override
  String get addYourFirstSchool => 'Add your first school to get started';

  @override
  String get totalSchools => 'Total Schools';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get appLanguage => 'App Language';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get alertPreferences => 'Alert Preferences';

  @override
  String get alertPreferencesSubtitle => 'Attendance, messages, system';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get systemDefault => 'System Default';

  @override
  String get biometricSession => 'Biometric & Session';

  @override
  String get syncPreferences => 'Sync Preferences';

  @override
  String get syncSubtitle => 'Sync settings across devices';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get dataPrivacyPolicy => 'Data Privacy Policy';

  @override
  String get policyConsent => 'Policy Consent';

  @override
  String get policyAgreed => 'You have agreed to the policies.';

  @override
  String get policyTapToReview => 'Tap to review and accept.';

  @override
  String get faqsSupport => 'FAQs & Support';

  @override
  String get appVersion => 'App Version';

  @override
  String get role => 'Role';

  @override
  String get superAdministrator => 'Super Administrator';

  @override
  String get teacherRole => 'Teacher';

  @override
  String get parentRole => 'Parent';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutConfirm => 'Are you sure you want to log out?';

  @override
  String get language => 'Language';

  @override
  String get applyLanguage => 'Apply Language';

  @override
  String get kidSecureAdmin => 'KidSecure Admin';

  @override
  String get forWhichChild => 'For which child?';

  @override
  String get selectAChild => 'Select a child';

  @override
  String get guardianDetails => 'Guardian Details';

  @override
  String get firstName => 'First Name';

  @override
  String get required => 'Required';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get idNumberOptional => 'ID Number (optional)';

  @override
  String get guardianPin => 'Guardian PIN';

  @override
  String get guardianPinDescription =>
      'The guardian will use this PIN to sign a child in or out.';

  @override
  String get pinRequired => 'PIN is required';

  @override
  String get pinMinFourDigits => 'PIN must be at least 4 digits';

  @override
  String get relationship => 'Relationship';

  @override
  String get permissions => 'Permissions';

  @override
  String get canSignChildIn => 'Can sign child in';

  @override
  String get canSignChildOut => 'Can sign child out';

  @override
  String get guardianAddedSuccess => 'Guardian added successfully!';

  @override
  String get showQr => 'Show QR';

  @override
  String biometricOnTimeout(String timeout) {
    return 'Biometric on · $timeout';
  }

  @override
  String autoLockTimeout(String timeout) {
    return 'Auto-lock: $timeout';
  }

  @override
  String get userFallback => 'User';

  @override
  String get capacity => 'Capacity';

  @override
  String get manageTeachers => 'Manage Teachers';

  @override
  String get noKidsEnrolledYet => 'No kids enrolled yet';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String submittedTime(String time) {
    return 'Submitted $time';
  }

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get assignTeachers => 'Assign Teachers';

  @override
  String get inviteParentToCreche => 'Invite Parent to this Crèche';

  @override
  String get addTeacher => 'Add Teacher';

  @override
  String get inviteViaLink => 'Invite via Link';

  @override
  String get inviteViaLinkSubtitle =>
      'Generate a secure invite link for a teacher';

  @override
  String get createManually => 'Create Manually';

  @override
  String get createManuallySubtitle => 'Create a teacher account directly';

  @override
  String assignedAvailable(int assigned, int available) {
    return '$assigned assigned · $available available';
  }

  @override
  String get hideAssigned => 'Hide assigned';

  @override
  String get showAll => 'Show all';

  @override
  String get noTeachersFound =>
      'No teachers found.\nRegister teacher accounts first.';

  @override
  String get allTeachersAssigned =>
      'All teachers are already\nassigned to other crèches.';

  @override
  String get alreadyAssigned => 'Already Assigned';

  @override
  String get assign => 'Assign';
}
