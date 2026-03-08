// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Afrikaans (`af`).
class AppLocalizationsAf extends AppLocalizations {
  AppLocalizationsAf([String locale = 'af']) : super(locale);

  @override
  String get appName => 'KidSecure';

  @override
  String get appTagline => 'Kleuterskool Bestuurplatform';

  @override
  String get splashTagline => 'Hou kleintjies veilig';

  @override
  String get cancel => 'Kanselleer';

  @override
  String get save => 'Stoor';

  @override
  String get close => 'Sluit';

  @override
  String get ok => 'OK';

  @override
  String get back => 'Terug';

  @override
  String get loading => 'Laai tans…';

  @override
  String get error => 'Fout';

  @override
  String get retry => 'Probeer weer';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nee';

  @override
  String get delete => 'Verwyder';

  @override
  String get edit => 'Wysig';

  @override
  String get add => 'Voeg by';

  @override
  String get search => 'Soek';

  @override
  String get update => 'Opdateer';

  @override
  String get confirm => 'Bevestig';

  @override
  String get submit => 'Dien in';

  @override
  String get remove => 'Verwyder';

  @override
  String get approve => 'Keur goed';

  @override
  String get optional => 'opsioneel';

  @override
  String get welcomeBack => 'Welkom terug';

  @override
  String get signInToContinue => 'Meld aan om voort te gaan';

  @override
  String get emailAddress => 'E-posadres';

  @override
  String get password => 'Wagwoord';

  @override
  String get emailRequired => 'E-pos is vereis';

  @override
  String get enterValidEmail => 'Voer \'n geldige e-pos in';

  @override
  String get passwordRequired => 'Wagwoord is vereis';

  @override
  String get minSixChars => 'Min. 6 karakters';

  @override
  String get forgotPassword => 'Wagwoord vergeet?';

  @override
  String get signIn => 'Teken In';

  @override
  String get dontHaveAccount => 'Het jy nie \'n rekening nie?';

  @override
  String get register => 'Registreer';

  @override
  String get firstTimeSetup => 'Eerste opset (Skep Administrateur)';

  @override
  String get resetPassword => 'Stel Wagwoord Terug';

  @override
  String get enterEmailForReset =>
      'Voer jou e-pos in om \'n terugstellingskakel te ontvang.';

  @override
  String get sendResetLink => 'Stuur Terugstellingskakel';

  @override
  String get resetEmailSent =>
      'Terugstellings-e-pos gestuur. Kyk jou inkassie.';

  @override
  String get invitationRequired => 'Uitnodiging Vereis';

  @override
  String get inviteSystemExplanation =>
      'KidSecure gebruik \'n veilige uitnodigingstelsel.\n\nVra jou skooladministrateur vir \'n onderwysersuitnodigingskakel, of vra jou onderwyser vir \'n oueruitnodigingskakel.';

  @override
  String get inviteStep1 => 'Ontvang \'n uitnodigingskakel van jou skool';

  @override
  String get inviteStep2 => 'Tik die kakel om KidSecure oop te maak';

  @override
  String get inviteStep3 => 'Voltooi registrasie — jou rol is vooraf toegewys';

  @override
  String get backToLogin => 'Terug na Aanmelding';

  @override
  String get alreadyHaveAccount => 'Het jy reeds \'n rekening? Teken in';

  @override
  String get createAccount => 'Skep Rekening';

  @override
  String invitedAs(String role) {
    return 'Uitgenooi as $role';
  }

  @override
  String get loadingCreche => 'Kleuterskool laai…';

  @override
  String get fullName => 'Volle Naam';

  @override
  String get phone => 'Telefoon';

  @override
  String get phoneOptional => 'Telefoon (opsioneel)';

  @override
  String get confirmPassword => 'Bevestig Wagwoord';

  @override
  String get nameRequired => 'Naam is vereis';

  @override
  String get minEightChars => 'Min. 8 karakters';

  @override
  String get passwordsDoNotMatch => 'Wagwoorde stem nie ooreen nie';

  @override
  String get verifyingInvite => 'Uitnodiging word geverifieer…';

  @override
  String get inviteUnavailable => 'Uitnodiging Nie Beskikbaar Nie';

  @override
  String get createSuperAdmin => 'Skep Superadministrateur';

  @override
  String get setupScreenTitle => 'Eerste Opset';

  @override
  String get setupScreenDescription =>
      'Hierdie skerm verskyn slegs een keer. Die superadministrateur kan alle kleuterskole, onderwysers en instellings bestuur.';

  @override
  String get adminDetails => 'Administrateurbesonderhede';

  @override
  String get emailAddressLabel => 'E-posadres';

  @override
  String get phoneOptionalLabel => 'Telefoonnommer (opsioneel)';

  @override
  String get passwordLabel => 'Wagwoord';

  @override
  String get passwordMinEight => 'Wagwoord moet ten minste 8 karakters hê';

  @override
  String get navHome => 'Tuis';

  @override
  String get navSignInOut => 'Teken In/Uit';

  @override
  String get navGuardians => 'Voogde';

  @override
  String get navSickLeave => 'Siekverlof';

  @override
  String get navGps => 'GPS';

  @override
  String get navKids => 'Kinders';

  @override
  String get navAttendance => 'Bywoning';

  @override
  String get navDashboard => 'Paneelbord';

  @override
  String get navCreches => 'Kleuterskole';

  @override
  String get navParents => 'Ouers';

  @override
  String get navReports => 'Verslae';

  @override
  String helloUser(String name) {
    return 'Hallo, $name';
  }

  @override
  String get myChildren => 'My Kinders';

  @override
  String get noChildrenLinked =>
      'Geen kinders gekoppel nie.\nKontak jou onderwyser.';

  @override
  String get contactTeacher => 'Kontak jou onderwyser.';

  @override
  String get notYetSignedIn => 'Nog nie aangeteken nie';

  @override
  String ageLabel(String age) {
    return 'Ouderdom: $age';
  }

  @override
  String get manual => 'Handmatig';

  @override
  String get qrScan => 'QR-skandering';

  @override
  String get guardian => 'Voog';

  @override
  String get selectChild => 'Kies Kind';

  @override
  String get scanQrDescription =>
      'Skandeer \'n kind se QR-kode om in of uit te teken';

  @override
  String get qrNotRecognised => 'QR-kode nie herken nie.';

  @override
  String childIdentified(String name) {
    return '$name geïdentifiseer! Tik inteken/uitteken hieronder.';
  }

  @override
  String childStatus(String name) {
    return '$name se Status';
  }

  @override
  String signedInAt(String time) {
    return 'Aangeteken om $time';
  }

  @override
  String get notYetSignedInToday => 'Nog nie vandag aangeteken nie';

  @override
  String get signOut => 'Teken Uit';

  @override
  String get noGuardians => 'Geen voogde bygevoeg nie';

  @override
  String get noPermission => 'Geen toestemming nie';

  @override
  String get trustedGuardians => 'Vertroude Voogde';

  @override
  String get addGuardian => 'Voeg Voog By';

  @override
  String get removeGuardian => 'Verwyder Voog';

  @override
  String removeGuardianConfirm(String name) {
    return 'Verwyder $name as voog?';
  }

  @override
  String get showQrDescription =>
      'Wys hierdie QR aan die onderwyser vir hekinteken';

  @override
  String get permSignIn => 'Teken In';

  @override
  String get permSignOut => 'Teken Uit';

  @override
  String get permVerified => 'Geverifieer ✓';

  @override
  String get noSickLeaveLogged => 'Geen siekverlof aangeteken nie';

  @override
  String get tapToLogSickDay =>
      'Tik die knoppie hieronder om \'n siekdag aan te teken';

  @override
  String get logSickLeave => 'Teken Siekverlof Aan';

  @override
  String get sickLeaveHistory => 'Siekverlofgeskiedenis';

  @override
  String get pending => 'Hangende';

  @override
  String get approved => 'Goedgekeur';

  @override
  String get rejected => 'Afgekeur';

  @override
  String symptoms(String symptoms) {
    return 'Simptome: $symptoms';
  }

  @override
  String attachmentCount(int count) {
    return '$count aanhangsel(s)';
  }

  @override
  String loggedTime(String time) {
    return 'Aangeteken $time';
  }

  @override
  String get child => 'Kind';

  @override
  String get startDate => 'Begindatum';

  @override
  String get multipleDays => 'Meerdere dae';

  @override
  String get endDate => 'Einddatum';

  @override
  String get notSet => 'Nie gestel nie';

  @override
  String get reasonForAbsence => 'Rede vir afwesigheid';

  @override
  String get reasonRequired => 'Rede is vereis';

  @override
  String get symptomsOptional => 'Simptome (opsioneel)';

  @override
  String get attachments => 'Aanhangsels';

  @override
  String get attachDoctorNotes => 'Heg doktersnotas aan (PDF, JPG, PNG)';

  @override
  String get addAttachment => 'Voeg Aanhangsel By';

  @override
  String get submitSickLeave => 'Dien Siekverlof In';

  @override
  String get selectChildFirst => 'Kies asseblief \'n kind';

  @override
  String get sickLeaveLoggedNotification =>
      'Siekverlof aangeteken! Onderwyser sal ingelig word.';

  @override
  String get goodMorning => 'Goeie môre';

  @override
  String get goodAfternoon => 'Goeie middag';

  @override
  String get goodEvening => 'Goeie naand';

  @override
  String get totalKids => 'Totale Kinders';

  @override
  String get present => 'Teenwoordig';

  @override
  String get absent => 'Afwesig';

  @override
  String sickLeavePending(int count) {
    return '$count siekverlof hangende';
  }

  @override
  String get reviewAndApprove => 'Hersien en keur hieronder goed.';

  @override
  String get quickActions => 'Vinnige Aksies';

  @override
  String get viewKids => 'Sien Kinders';

  @override
  String get attendance => 'Bywoning';

  @override
  String get addKid => 'Voeg Kind By';

  @override
  String get guardianCheckin => 'Voog Inteken';

  @override
  String get inviteParent => 'Nooi Ouer';

  @override
  String get noCrecheAssigned =>
      'Geen kleuterskool aan jou rekening toegewys nie.';

  @override
  String get failedToGenerateInvite =>
      'Kon nie uitnodiging genereer nie. Probeer weer.';

  @override
  String kidsEnrolled(int count) {
    return '$count Kinders Ingeskryf';
  }

  @override
  String get searchKids => 'Soek kinders…';

  @override
  String get allergiesWarning => 'Het allergieë';

  @override
  String get todaysAttendance => 'Vandag se Bywoning';

  @override
  String get signedIn => 'Aangeteken';

  @override
  String get signedOut => 'Uitgeteken';

  @override
  String get absentLabel => 'Afwesig';

  @override
  String get sickLeaveLabel => 'Siekverlof';

  @override
  String signInTime(String time) {
    return 'Inteken: $time';
  }

  @override
  String signOutTime(String time) {
    return 'Uitteken: $time';
  }

  @override
  String pendingCount(int count) {
    return 'Hangende ($count)';
  }

  @override
  String approvedCount(int count) {
    return 'Goedgekeur ($count)';
  }

  @override
  String get noSickLeaveSubmitted => 'Geen siekverlof ingedien nie';

  @override
  String get parentsCanLog => 'Ouers kan siekverlof via hul app aanteken';

  @override
  String get overview => 'Oorsig';

  @override
  String get liveCountsAllSchools => 'Lewende tellings oor alle skole';

  @override
  String get schools => 'Skole';

  @override
  String get teachers => 'Onderwysers';

  @override
  String get kids => 'Kinders';

  @override
  String get parents => 'Ouers';

  @override
  String get guardians => 'Voogde';

  @override
  String get manageCreches => 'Bestuur Kleuterskole';

  @override
  String schoolsRegistered(int count) {
    return '$count skool/skole geregistreer';
  }

  @override
  String get addYourFirstSchool => 'Voeg jou eerste skool by om te begin';

  @override
  String get totalSchools => 'Totale Skole';

  @override
  String get settings => 'Instellings';

  @override
  String get editProfile => 'Wysig Profiel';

  @override
  String get changePassword => 'Verander Wagwoord';

  @override
  String get appLanguage => 'Toepassingstaal';

  @override
  String get pushNotifications => 'Stootkennisgewings';

  @override
  String get enabled => 'Geaktiveer';

  @override
  String get disabled => 'Gedeaktiveer';

  @override
  String get alertPreferences => 'Waarskuwingsvoorkeure';

  @override
  String get alertPreferencesSubtitle => 'Bywoning, boodskappe, stelsel';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Donker';

  @override
  String get light => 'Lig';

  @override
  String get systemDefault => 'Stelselverstek';

  @override
  String get biometricSession => 'Biometrie & Sessie';

  @override
  String get syncPreferences => 'Sinkroniseervoorkeure';

  @override
  String get syncSubtitle => 'Sinkroniseer instellings oor toestelle';

  @override
  String get termsOfUse => 'Gebruiksvoorwaardes';

  @override
  String get dataPrivacyPolicy => 'Dataprivaatheidsbeleid';

  @override
  String get policyConsent => 'Beleidstoestemming';

  @override
  String get policyAgreed => 'U het met die beleide ingestem.';

  @override
  String get policyTapToReview => 'Tik om te hersien en te aanvaar.';

  @override
  String get faqsSupport => 'Gereelde Vrae & Ondersteuning';

  @override
  String get appVersion => 'Toepassingsweergawe';

  @override
  String get role => 'Rol';

  @override
  String get superAdministrator => 'Superadministrateur';

  @override
  String get teacherRole => 'Onderwyser';

  @override
  String get parentRole => 'Ouer';

  @override
  String get logOut => 'Meld Af';

  @override
  String get logOutConfirm => 'Is jy seker jy wil afmeld?';

  @override
  String get language => 'Taal';

  @override
  String get applyLanguage => 'Pas Taal Toe';

  @override
  String get kidSecureAdmin => 'KidSecure Administrateur';

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
