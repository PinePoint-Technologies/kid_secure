import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../shared/models/child_model.dart';

// ─── Watch a single child by ID ───────────────────────────────────────────────

final childByIdProvider =
    StreamProvider.family<ChildModel?, String>((ref, childId) {
  return ref.watch(firestoreServiceProvider).watchChildById(childId);
});

// ─── Link Parent to Child ─────────────────────────────────────────────────────

class LinkParentState {
  final String? error;
  const LinkParentState({this.error});
}

class LinkParentNotifier extends Notifier<LinkParentState> {
  @override
  LinkParentState build() => const LinkParentState();

  FirestoreService get _db => ref.read(firestoreServiceProvider);

  Future<void> link({
    required String childId,
    required String parentUid,
    required String crecheId,
  }) async {
    try {
      await _db.linkParentToChild(
          childId: childId, parentUid: parentUid, crecheId: crecheId);
    } catch (_) {
      state = const LinkParentState(error: 'Failed to link parent.');
    }
  }

  Future<void> unlink({
    required String childId,
    required String parentUid,
  }) async {
    try {
      await _db.unlinkParentFromChild(childId: childId, parentUid: parentUid);
    } catch (_) {
      state = const LinkParentState(error: 'Failed to unlink parent.');
    }
  }
}

final linkParentProvider =
    NotifierProvider<LinkParentNotifier, LinkParentState>(
  LinkParentNotifier.new,
);
