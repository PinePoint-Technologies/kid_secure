import 'package:cloud_functions/cloud_functions.dart';

class InviteValidationResult {
  final bool valid;
  final String? role;
  final String? crecheId;
  final String? tokenId;
  final String? error;

  const InviteValidationResult({
    required this.valid,
    this.role,
    this.crecheId,
    this.tokenId,
    this.error,
  });

  factory InviteValidationResult.fromMap(Map<String, dynamic> data) {
    return InviteValidationResult(
      valid: data['valid'] as bool? ?? false,
      role: data['role'] as String?,
      crecheId: data['crecheId'] as String?,
      tokenId: data['tokenId'] as String?,
      error: data['error'] as String?,
    );
  }
}

class InviteService {
  final FirebaseFunctions _functions;

  InviteService(this._functions);

  /// Calls [generateInvite] Cloud Function.
  /// Returns the deep-link: `kidsecure://invite?token=<JWT>`
  Future<String> generateInvite({
    required String role,
    required String crecheId,
  }) async {
    final callable = _functions.httpsCallable('generateInvite');
    final result = await callable.call<Map<String, dynamic>>({
      'role': role,
      'crecheId': crecheId,
    });
    return result.data['deepLink'] as String;
  }

  /// Calls [validateInvite] Cloud Function.
  /// Returns a validated result (no auth required).
  Future<InviteValidationResult> validateInvite(String token) async {
    final callable = _functions.httpsCallable('validateInvite');
    final result = await callable.call<Map<String, dynamic>>({'token': token});
    return InviteValidationResult.fromMap(
      Map<String, dynamic>.from(result.data as Map),
    );
  }

  /// Calls [consumeInvite] Cloud Function after successful registration.
  /// Marks the invite as used and writes an audit log entry.
  Future<void> consumeInvite(String tokenId) async {
    final callable = _functions.httpsCallable('consumeInvite');
    await callable.call<Map<String, dynamic>>({'tokenId': tokenId});
  }
}
