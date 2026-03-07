import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait (optional — remove for tablet support)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  @override
  void initState() {
    super.initState();

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

    return MaterialApp.router(
      title: 'KidSecure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
