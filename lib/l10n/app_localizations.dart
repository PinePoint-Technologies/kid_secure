import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_af.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ve.dart';
import 'app_localizations_zu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('af'),
    Locale('en'),
    Locale('ve'),
    Locale('zu')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'KidSecure'**
  String get appName;

  /// Tagline shown on login
  ///
  /// In en, this message translates to:
  /// **'Creche Management Platform'**
  String get appTagline;

  /// Splash screen tagline
  ///
  /// In en, this message translates to:
  /// **'Keeping little ones safe'**
  String get splashTagline;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @minSixChars.
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters'**
  String get minSixChars;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @firstTimeSetup.
  ///
  /// In en, this message translates to:
  /// **'First-time Setup (Create Admin)'**
  String get firstTimeSetup;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link.'**
  String get enterEmailForReset;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent. Check your inbox.'**
  String get resetEmailSent;

  /// No description provided for @invitationRequired.
  ///
  /// In en, this message translates to:
  /// **'Invitation Required'**
  String get invitationRequired;

  /// No description provided for @inviteSystemExplanation.
  ///
  /// In en, this message translates to:
  /// **'KidSecure uses a secure invite system.\n\nAsk your school administrator for a teacher invite link, or ask your teacher for a parent invite link.'**
  String get inviteSystemExplanation;

  /// No description provided for @inviteStep1.
  ///
  /// In en, this message translates to:
  /// **'Receive an invite link from your school'**
  String get inviteStep1;

  /// No description provided for @inviteStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap the link to open KidSecure'**
  String get inviteStep2;

  /// No description provided for @inviteStep3.
  ///
  /// In en, this message translates to:
  /// **'Complete registration — your role is pre-assigned'**
  String get inviteStep3;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @invitedAs.
  ///
  /// In en, this message translates to:
  /// **'Invited as {role}'**
  String invitedAs(String role);

  /// No description provided for @loadingCreche.
  ///
  /// In en, this message translates to:
  /// **'Loading crèche…'**
  String get loadingCreche;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @minEightChars.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get minEightChars;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @verifyingInvite.
  ///
  /// In en, this message translates to:
  /// **'Verifying invite…'**
  String get verifyingInvite;

  /// No description provided for @inviteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Invite Unavailable'**
  String get inviteUnavailable;

  /// No description provided for @createSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Create Super Admin'**
  String get createSuperAdmin;

  /// No description provided for @setupScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'First-time Setup'**
  String get setupScreenTitle;

  /// No description provided for @setupScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'This screen only appears once. The super admin can manage all creches, teachers, and settings.'**
  String get setupScreenDescription;

  /// No description provided for @adminDetails.
  ///
  /// In en, this message translates to:
  /// **'Admin Details'**
  String get adminDetails;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressLabel;

  /// No description provided for @phoneOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get phoneOptionalLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordMinEight.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinEight;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSignInOut.
  ///
  /// In en, this message translates to:
  /// **'Sign In/Out'**
  String get navSignInOut;

  /// No description provided for @navGuardians.
  ///
  /// In en, this message translates to:
  /// **'Guardians'**
  String get navGuardians;

  /// No description provided for @navSickLeave.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave'**
  String get navSickLeave;

  /// No description provided for @navKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get navKids;

  /// No description provided for @navAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get navAttendance;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navCreches.
  ///
  /// In en, this message translates to:
  /// **'Crèches'**
  String get navCreches;

  /// No description provided for @navParents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get navParents;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// No description provided for @myChildren.
  ///
  /// In en, this message translates to:
  /// **'My Children'**
  String get myChildren;

  /// No description provided for @noChildrenLinked.
  ///
  /// In en, this message translates to:
  /// **'No children linked yet.\nContact your teacher.'**
  String get noChildrenLinked;

  /// No description provided for @contactTeacher.
  ///
  /// In en, this message translates to:
  /// **'Contact your teacher.'**
  String get contactTeacher;

  /// No description provided for @notYetSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not yet signed in'**
  String get notYetSignedIn;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age: {age}'**
  String ageLabel(String age);

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @qrScan.
  ///
  /// In en, this message translates to:
  /// **'QR Scan'**
  String get qrScan;

  /// No description provided for @guardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get guardian;

  /// No description provided for @selectChild.
  ///
  /// In en, this message translates to:
  /// **'Select Child'**
  String get selectChild;

  /// No description provided for @scanQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan a child\'s QR code to sign in or out'**
  String get scanQrDescription;

  /// No description provided for @qrNotRecognised.
  ///
  /// In en, this message translates to:
  /// **'QR code not recognised.'**
  String get qrNotRecognised;

  /// No description provided for @childIdentified.
  ///
  /// In en, this message translates to:
  /// **'{name} identified! Tap sign in/out below.'**
  String childIdentified(String name);

  /// No description provided for @childStatus.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Status'**
  String childStatus(String name);

  /// No description provided for @signedInAt.
  ///
  /// In en, this message translates to:
  /// **'Signed in at {time}'**
  String signedInAt(String time);

  /// No description provided for @notYetSignedInToday.
  ///
  /// In en, this message translates to:
  /// **'Not yet signed in today'**
  String get notYetSignedInToday;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @noGuardians.
  ///
  /// In en, this message translates to:
  /// **'No guardians added yet'**
  String get noGuardians;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'No permission'**
  String get noPermission;

  /// No description provided for @trustedGuardians.
  ///
  /// In en, this message translates to:
  /// **'Trusted Guardians'**
  String get trustedGuardians;

  /// No description provided for @addGuardian.
  ///
  /// In en, this message translates to:
  /// **'Add Guardian'**
  String get addGuardian;

  /// No description provided for @removeGuardian.
  ///
  /// In en, this message translates to:
  /// **'Remove Guardian'**
  String get removeGuardian;

  /// No description provided for @removeGuardianConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} as a guardian?'**
  String removeGuardianConfirm(String name);

  /// No description provided for @showQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Show this QR to the teacher for gate check-in'**
  String get showQrDescription;

  /// No description provided for @permSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get permSignIn;

  /// No description provided for @permSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get permSignOut;

  /// No description provided for @permVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified ✓'**
  String get permVerified;

  /// No description provided for @noSickLeaveLogged.
  ///
  /// In en, this message translates to:
  /// **'No sick leave logged'**
  String get noSickLeaveLogged;

  /// No description provided for @tapToLogSickDay.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to log a sick day'**
  String get tapToLogSickDay;

  /// No description provided for @logSickLeave.
  ///
  /// In en, this message translates to:
  /// **'Log Sick Leave'**
  String get logSickLeave;

  /// No description provided for @sickLeaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave History'**
  String get sickLeaveHistory;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms: {symptoms}'**
  String symptoms(String symptoms);

  /// No description provided for @attachmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} attachment(s)'**
  String attachmentCount(int count);

  /// No description provided for @loggedTime.
  ///
  /// In en, this message translates to:
  /// **'Logged {time}'**
  String loggedTime(String time);

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @multipleDays.
  ///
  /// In en, this message translates to:
  /// **'Multiple days'**
  String get multipleDays;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @reasonForAbsence.
  ///
  /// In en, this message translates to:
  /// **'Reason for absence'**
  String get reasonForAbsence;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get reasonRequired;

  /// No description provided for @symptomsOptional.
  ///
  /// In en, this message translates to:
  /// **'Symptoms (optional)'**
  String get symptomsOptional;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @attachDoctorNotes.
  ///
  /// In en, this message translates to:
  /// **'Attach doctor\'s notes (PDF, JPG, PNG)'**
  String get attachDoctorNotes;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get addAttachment;

  /// No description provided for @submitSickLeave.
  ///
  /// In en, this message translates to:
  /// **'Submit Sick Leave'**
  String get submitSickLeave;

  /// No description provided for @selectChildFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a child'**
  String get selectChildFirst;

  /// No description provided for @sickLeaveLoggedNotification.
  ///
  /// In en, this message translates to:
  /// **'Sick leave logged! Teacher will be notified.'**
  String get sickLeaveLoggedNotification;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @totalKids.
  ///
  /// In en, this message translates to:
  /// **'Total Kids'**
  String get totalKids;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @sickLeavePending.
  ///
  /// In en, this message translates to:
  /// **'{count} sick leave pending'**
  String sickLeavePending(int count);

  /// No description provided for @reviewAndApprove.
  ///
  /// In en, this message translates to:
  /// **'Review and approve below.'**
  String get reviewAndApprove;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewKids.
  ///
  /// In en, this message translates to:
  /// **'View Kids'**
  String get viewKids;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @addKid.
  ///
  /// In en, this message translates to:
  /// **'Add Kid'**
  String get addKid;

  /// No description provided for @guardianCheckin.
  ///
  /// In en, this message translates to:
  /// **'Guardian Check-In'**
  String get guardianCheckin;

  /// No description provided for @inviteParent.
  ///
  /// In en, this message translates to:
  /// **'Invite Parent'**
  String get inviteParent;

  /// No description provided for @noCrecheAssigned.
  ///
  /// In en, this message translates to:
  /// **'No crèche assigned to your account.'**
  String get noCrecheAssigned;

  /// No description provided for @failedToGenerateInvite.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate invite. Please try again.'**
  String get failedToGenerateInvite;

  /// No description provided for @kidsEnrolled.
  ///
  /// In en, this message translates to:
  /// **'{count} Kids Enrolled'**
  String kidsEnrolled(int count);

  /// No description provided for @searchKids.
  ///
  /// In en, this message translates to:
  /// **'Search kids…'**
  String get searchKids;

  /// No description provided for @allergiesWarning.
  ///
  /// In en, this message translates to:
  /// **'Has allergies'**
  String get allergiesWarning;

  /// No description provided for @todaysAttendance.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Attendance'**
  String get todaysAttendance;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed In'**
  String get signedIn;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed Out'**
  String get signedOut;

  /// No description provided for @absentLabel.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absentLabel;

  /// No description provided for @sickLeaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave'**
  String get sickLeaveLabel;

  /// No description provided for @signInTime.
  ///
  /// In en, this message translates to:
  /// **'Sign-in: {time}'**
  String signInTime(String time);

  /// No description provided for @signOutTime.
  ///
  /// In en, this message translates to:
  /// **'Sign-out: {time}'**
  String signOutTime(String time);

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String pendingCount(int count);

  /// No description provided for @approvedCount.
  ///
  /// In en, this message translates to:
  /// **'Approved ({count})'**
  String approvedCount(int count);

  /// No description provided for @noSickLeaveSubmitted.
  ///
  /// In en, this message translates to:
  /// **'No sick leave submitted'**
  String get noSickLeaveSubmitted;

  /// No description provided for @parentsCanLog.
  ///
  /// In en, this message translates to:
  /// **'Parents can log sick leave from their app'**
  String get parentsCanLog;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @liveCountsAllSchools.
  ///
  /// In en, this message translates to:
  /// **'Live counts across all schools'**
  String get liveCountsAllSchools;

  /// No description provided for @schools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get schools;

  /// No description provided for @teachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get teachers;

  /// No description provided for @kids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kids;

  /// No description provided for @parents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get parents;

  /// No description provided for @guardians.
  ///
  /// In en, this message translates to:
  /// **'Guardians'**
  String get guardians;

  /// No description provided for @manageCreches.
  ///
  /// In en, this message translates to:
  /// **'Manage Crèches'**
  String get manageCreches;

  /// No description provided for @schoolsRegistered.
  ///
  /// In en, this message translates to:
  /// **'{count} school(s) registered'**
  String schoolsRegistered(int count);

  /// No description provided for @addYourFirstSchool.
  ///
  /// In en, this message translates to:
  /// **'Add your first school to get started'**
  String get addYourFirstSchool;

  /// No description provided for @totalSchools.
  ///
  /// In en, this message translates to:
  /// **'Total Schools'**
  String get totalSchools;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @alertPreferences.
  ///
  /// In en, this message translates to:
  /// **'Alert Preferences'**
  String get alertPreferences;

  /// No description provided for @alertPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance, messages, system'**
  String get alertPreferencesSubtitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @biometricSession.
  ///
  /// In en, this message translates to:
  /// **'Biometric & Session'**
  String get biometricSession;

  /// No description provided for @syncPreferences.
  ///
  /// In en, this message translates to:
  /// **'Sync Preferences'**
  String get syncPreferences;

  /// No description provided for @syncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync settings across devices'**
  String get syncSubtitle;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @dataPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Data Privacy Policy'**
  String get dataPrivacyPolicy;

  /// No description provided for @policyConsent.
  ///
  /// In en, this message translates to:
  /// **'Policy Consent'**
  String get policyConsent;

  /// No description provided for @policyAgreed.
  ///
  /// In en, this message translates to:
  /// **'You have agreed to the policies.'**
  String get policyAgreed;

  /// No description provided for @policyTapToReview.
  ///
  /// In en, this message translates to:
  /// **'Tap to review and accept.'**
  String get policyTapToReview;

  /// No description provided for @faqsSupport.
  ///
  /// In en, this message translates to:
  /// **'FAQs & Support'**
  String get faqsSupport;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @superAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Super Administrator'**
  String get superAdministrator;

  /// No description provided for @teacherRole.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacherRole;

  /// No description provided for @parentRole.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parentRole;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @applyLanguage.
  ///
  /// In en, this message translates to:
  /// **'Apply Language'**
  String get applyLanguage;

  /// No description provided for @kidSecureAdmin.
  ///
  /// In en, this message translates to:
  /// **'KidSecure Admin'**
  String get kidSecureAdmin;

  /// No description provided for @forWhichChild.
  ///
  /// In en, this message translates to:
  /// **'For which child?'**
  String get forWhichChild;

  /// No description provided for @selectAChild.
  ///
  /// In en, this message translates to:
  /// **'Select a child'**
  String get selectAChild;

  /// No description provided for @guardianDetails.
  ///
  /// In en, this message translates to:
  /// **'Guardian Details'**
  String get guardianDetails;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequired;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @idNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'ID Number (optional)'**
  String get idNumberOptional;

  /// No description provided for @guardianPin.
  ///
  /// In en, this message translates to:
  /// **'Guardian PIN'**
  String get guardianPin;

  /// No description provided for @guardianPinDescription.
  ///
  /// In en, this message translates to:
  /// **'The guardian will use this PIN to sign a child in or out.'**
  String get guardianPinDescription;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get pinRequired;

  /// No description provided for @pinMinFourDigits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits'**
  String get pinMinFourDigits;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @canSignChildIn.
  ///
  /// In en, this message translates to:
  /// **'Can sign child in'**
  String get canSignChildIn;

  /// No description provided for @canSignChildOut.
  ///
  /// In en, this message translates to:
  /// **'Can sign child out'**
  String get canSignChildOut;

  /// No description provided for @guardianAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Guardian added successfully!'**
  String get guardianAddedSuccess;

  /// No description provided for @showQr.
  ///
  /// In en, this message translates to:
  /// **'Show QR'**
  String get showQr;

  /// No description provided for @biometricOnTimeout.
  ///
  /// In en, this message translates to:
  /// **'Biometric on · {timeout}'**
  String biometricOnTimeout(String timeout);

  /// No description provided for @autoLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock: {timeout}'**
  String autoLockTimeout(String timeout);

  /// No description provided for @userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallback;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @manageTeachers.
  ///
  /// In en, this message translates to:
  /// **'Manage Teachers'**
  String get manageTeachers;

  /// No description provided for @noKidsEnrolledYet.
  ///
  /// In en, this message translates to:
  /// **'No kids enrolled yet'**
  String get noKidsEnrolledYet;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @submittedTime.
  ///
  /// In en, this message translates to:
  /// **'Submitted {time}'**
  String submittedTime(String time);

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @assignTeachers.
  ///
  /// In en, this message translates to:
  /// **'Assign Teachers'**
  String get assignTeachers;

  /// No description provided for @inviteParentToCreche.
  ///
  /// In en, this message translates to:
  /// **'Invite Parent to this Crèche'**
  String get inviteParentToCreche;

  /// No description provided for @addTeacher.
  ///
  /// In en, this message translates to:
  /// **'Add Teacher'**
  String get addTeacher;

  /// No description provided for @inviteViaLink.
  ///
  /// In en, this message translates to:
  /// **'Invite via Link'**
  String get inviteViaLink;

  /// No description provided for @inviteViaLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a secure invite link for a teacher'**
  String get inviteViaLinkSubtitle;

  /// No description provided for @createManually.
  ///
  /// In en, this message translates to:
  /// **'Create Manually'**
  String get createManually;

  /// No description provided for @createManuallySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a teacher account directly'**
  String get createManuallySubtitle;

  /// No description provided for @assignedAvailable.
  ///
  /// In en, this message translates to:
  /// **'{assigned} assigned · {available} available'**
  String assignedAvailable(int assigned, int available);

  /// No description provided for @hideAssigned.
  ///
  /// In en, this message translates to:
  /// **'Hide assigned'**
  String get hideAssigned;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @noTeachersFound.
  ///
  /// In en, this message translates to:
  /// **'No teachers found.\nRegister teacher accounts first.'**
  String get noTeachersFound;

  /// No description provided for @allTeachersAssigned.
  ///
  /// In en, this message translates to:
  /// **'All teachers are already\nassigned to other crèches.'**
  String get allTeachersAssigned;

  /// No description provided for @alreadyAssigned.
  ///
  /// In en, this message translates to:
  /// **'Already Assigned'**
  String get alreadyAssigned;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['af', 'en', 've', 'zu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'af':
      return AppLocalizationsAf();
    case 'en':
      return AppLocalizationsEn();
    case 've':
      return AppLocalizationsVe();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
