import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/firebase_providers.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

/// Wraps a [LocalizationsDelegate] so it claims to support every locale,
/// falling back to [_fallback] (English by default) for locales the inner
/// delegate does not handle.  This prevents the "locale X is not supported"
/// warning Flutter emits when Material/Cupertino delegates don't cover every
/// locale declared in [AppLocalizations.supportedLocales].
class _FallbackDelegate<T> extends LocalizationsDelegate<T> {
  final LocalizationsDelegate<T> _inner;
  final Locale _fallback;

  const _FallbackDelegate(this._inner,
      {Locale fallback = const Locale('en')})
      : _fallback = fallback;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<T> load(Locale locale) =>
      _inner.load(_inner.isSupported(locale) ? locale : _fallback);

  @override
  bool shouldReload(_FallbackDelegate<T> old) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use locally bundled fonts — prevents network fetch failures in simulators
  // or restricted network environments.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Lock to portrait (optional — remove for tablet support)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase init — guard against hot-restart re-initialisation
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // FCM — request permission and configure foreground presentation
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, badge: true, sound: true,
  );

  // App Check — debug provider in dev, Play Integrity in production
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode
        ? AppleProvider.debug
        : AppleProvider.deviceCheck,
  );

  // In debug mode, print the App Check token so developers can register it
  // in Firebase Console → App Check → iOS app → Manage debug tokens.
  if (kDebugMode) {
    final appCheckToken = await FirebaseAppCheck.instance.getToken(true);
    // ignore: avoid_print
    print('┌─────────────────────────────────────────────────────┐');
    // ignore: avoid_print
    print('│ APP CHECK TOKEN (register in Firebase Console)      │');
    // ignore: avoid_print
    print('│ ${appCheckToken?.token ?? 'unavailable'}');
    // ignore: avoid_print
    print('└─────────────────────────────────────────────────────┘');
  }

  // Capture initial deep link (cold-start: app was not running when link tapped)
  String? initialInviteToken;
  try {
    final initialUri = await AppLinks().getInitialLink();
    if (initialUri != null &&
        initialUri.scheme == 'kidsecure' &&
        initialUri.host == 'invite') {
      initialInviteToken = initialUri.queryParameters['token'];
    }
  } catch (_) {
    // Ignore — no initial link
  }

  runApp(
    ProviderScope(
      child: KidSecureApp(initialInviteToken: initialInviteToken),
    ),
  );
}

class KidSecureApp extends ConsumerStatefulWidget {
  final String? initialInviteToken;
  const KidSecureApp({super.key, this.initialInviteToken});

  @override
  ConsumerState<KidSecureApp> createState() => _KidSecureAppState();
}

class _KidSecureAppState extends ConsumerState<KidSecureApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    // FCM foreground message → in-app SnackBar
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            [notification.title, notification.body]
                .where((s) => s != null && s.isNotEmpty)
                .join(' — '),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    });

    // FCM token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        ref.read(firestoreServiceProvider).saveFcmToken(user.uid, token);
      }
    });

    // Navigate to invite register for cold-start links
    if (widget.initialInviteToken != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(routerProvider).go(
          '${AppRoutes.inviteRegister}?token=${Uri.encodeComponent(widget.initialInviteToken!)}',
        );
      });
    }

    // Listen for warm/hot deep links (app already running)
    AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == 'kidsecure' && uri.host == 'invite') {
        final token = uri.queryParameters['token'];
        if (token != null && token.isNotEmpty) {
          ref.read(routerProvider).go(
            '${AppRoutes.inviteRegister}?token=${Uri.encodeComponent(token)}',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final languageCode = ref.watch(
      settingsProvider.select((s) => s.languageCode),
    );

    // Save FCM token whenever a user signs in
    ref.listen(currentUserProvider, (_, next) {
      next.whenData((user) async {
        if (user == null) return;
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          ref.read(firestoreServiceProvider).saveFcmToken(user.uid, token);
        }
      });
    });

    return MaterialApp.router(
      scaffoldMessengerKey: _messengerKey,
      title: 'KidSecure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      locale: Locale(languageCode),
      localizationsDelegates: [
        AppLocalizations.delegate,
        _FallbackDelegate<MaterialLocalizations>(GlobalMaterialLocalizations.delegate),
        GlobalWidgetsLocalizations.delegate,
        _FallbackDelegate<CupertinoLocalizations>(GlobalCupertinoLocalizations.delegate),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
