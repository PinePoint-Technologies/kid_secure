import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as jwt from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";

admin.initializeApp();

const db = admin.firestore();
const INVITE_JWT_SECRET = defineSecret("INVITE_JWT_SECRET");

// ── Types ────────────────────────────────────────────────────────────────────

interface InvitePayload {
  tokenId: string;
  role: "teacher" | "parent";
  crecheId: string;
  createdBy: string;
}

// ── generateInvite ────────────────────────────────────────────────────────────
// Called by: super_admin (role='teacher' or 'parent') | teacher (role='parent' only)
// Returns:   { deepLink, tokenId }

export const generateInvite = onCall(
  { secrets: [INVITE_JWT_SECRET] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }

    const { role, crecheId } = request.data as {
      role: "teacher" | "parent";
      crecheId: string;
    };

    if (!role || !crecheId) {
      throw new HttpsError("invalid-argument", "role and crecheId are required.");
    }
    if (role !== "teacher" && role !== "parent") {
      throw new HttpsError("invalid-argument", "role must be teacher or parent.");
    }

    // Load caller profile
    const callerSnap = await db.collection("users").doc(request.auth.uid).get();
    if (!callerSnap.exists) {
      throw new HttpsError("not-found", "Caller user profile not found.");
    }
    const callerRole: string = callerSnap.data()!.role ?? "";

    // Role-based guards
    if (callerRole !== "super_admin" && callerRole !== "teacher") {
      throw new HttpsError("permission-denied", "Only super admins and teachers can generate invites.");
    }
    if (callerRole === "teacher") {
      if (role !== "parent") {
        throw new HttpsError("permission-denied", "Teachers can only invite parents.");
      }
      const teacherCrecheIds: string[] = callerSnap.data()!.crecheIds ?? [];
      if (!teacherCrecheIds.includes(crecheId)) {
        throw new HttpsError("permission-denied", "You are not assigned to this crèche.");
      }
    }

    const tokenId = uuidv4();
    const secret = INVITE_JWT_SECRET.value();
    const payload: InvitePayload = {
      tokenId,
      role,
      crecheId,
      createdBy: request.auth.uid,
    };

    const token = jwt.sign(payload, secret, { expiresIn: "7d" });
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      Date.now() + 7 * 24 * 60 * 60 * 1000
    );

    // Persist invite document (Admin SDK bypasses Firestore rules)
    await db.collection("invites").doc(tokenId).set({
      tokenId,
      role,
      crecheId,
      createdBy: request.auth.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
      consumed: false,
      consumedAt: null,
      consumedBy: null,
    });

    // Audit log
    await db.collection("audit_logs").add({
      event: "invite_generated",
      tokenId,
      actorUid: request.auth.uid,
      targetRole: role,
      crecheId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      metadata: {},
    });

    const deepLink = `kidsecure://invite?token=${encodeURIComponent(token)}`;
    return { deepLink, tokenId };
  }
);

// ── validateInvite ────────────────────────────────────────────────────────────
// Called by: unauthenticated app (before registration)
// Returns:   { valid, role, crecheId, tokenId } or { valid: false, error }

export const validateInvite = onCall(
  { secrets: [INVITE_JWT_SECRET] },
  async (request) => {
    const { token } = request.data as { token: string };
    if (!token) {
      return { valid: false, error: "No token provided." };
    }

    const secret = INVITE_JWT_SECRET.value();
    let payload: InvitePayload;
    try {
      payload = jwt.verify(token, secret) as InvitePayload;
    } catch {
      return { valid: false, error: "This invite link has expired or is invalid." };
    }

    const inviteSnap = await db.collection("invites").doc(payload.tokenId).get();
    if (!inviteSnap.exists) {
      return { valid: false, error: "Invite not found." };
    }

    const invite = inviteSnap.data()!;
    if (invite.consumed) {
      return { valid: false, error: "This invite link has already been used." };
    }

    return {
      valid: true,
      role: payload.role,
      crecheId: payload.crecheId,
      tokenId: payload.tokenId,
    };
  }
);

// ── consumeInvite ─────────────────────────────────────────────────────────────
// Called by: authenticated app after successful registration
// Returns:   { success: true }

export const consumeInvite = onCall(
  { secrets: [INVITE_JWT_SECRET] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in to consume an invite.");
    }

    const { tokenId } = request.data as { tokenId: string };
    if (!tokenId) {
      throw new HttpsError("invalid-argument", "tokenId is required.");
    }

    const inviteRef = db.collection("invites").doc(tokenId);

    // Atomic transaction to prevent double-consumption races
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(inviteRef);
      if (!snap.exists) {
        throw new HttpsError("not-found", "Invite not found.");
      }
      if (snap.data()!.consumed) {
        throw new HttpsError("already-exists", "Invite already consumed.");
      }
      tx.update(inviteRef, {
        consumed: true,
        consumedAt: admin.firestore.FieldValue.serverTimestamp(),
        consumedBy: request.auth!.uid,
      });
    });

    // Audit log (outside transaction — fire-and-forget acceptable here)
    const inviteSnap = await inviteRef.get();
    const inviteData = inviteSnap.data()!;
    await db.collection("audit_logs").add({
      event: "invite_consumed",
      tokenId,
      actorUid: request.auth.uid,
      targetRole: inviteData.role,
      crecheId: inviteData.crecheId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      metadata: { generatedBy: inviteData.createdBy },
    });

    return { success: true };
  }
);
