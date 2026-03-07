import 'package:app_links/app_links.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/invite_service.dart';

final firebaseFunctionsProvider = Provider<FirebaseFunctions>(
  (_) => FirebaseFunctions.instance,
);

final inviteServiceProvider = Provider<InviteService>(
  (ref) => InviteService(ref.watch(firebaseFunctionsProvider)),
);

/// Stream of deep-link URIs received while the app is running.
/// KidSecureApp listens to this and navigates to /invite/register when
/// a kidsecure://invite link is received.
final deepLinkStreamProvider = StreamProvider<Uri?>((ref) {
  return AppLinks().uriLinkStream.handleError((_) => null);
});

/// Stores the raw JWT token extracted from an invite deep link so it
/// survives navigation between providers/screens.
final pendingInviteTokenProvider = StateProvider<String?>((ref) => null);
