"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notifyParentsOnAttendance = exports.consumeInvite = exports.validateInvite = exports.generateInvite = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const params_1 = require("firebase-functions/params");
const jwt = require("jsonwebtoken");
const uuid_1 = require("uuid");
admin.initializeApp();
const db = admin.firestore();
const INVITE_JWT_SECRET = (0, params_1.defineSecret)("INVITE_JWT_SECRET");
// ── generateInvite ────────────────────────────────────────────────────────────
// Called by: super_admin (role='teacher' or 'parent') | teacher (role='parent' only)
// Returns:   { deepLink, tokenId }
exports.generateInvite = (0, https_1.onCall)({ secrets: [INVITE_JWT_SECRET] }, async (request) => {
    var _a, _b;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "You must be signed in.");
    }
    const { role, crecheId } = request.data;
    if (!role || !crecheId) {
        throw new https_1.HttpsError("invalid-argument", "role and crecheId are required.");
    }
    if (role !== "teacher" && role !== "parent") {
        throw new https_1.HttpsError("invalid-argument", "role must be teacher or parent.");
    }
    // Load caller profile
    const callerSnap = await db.collection("users").doc(request.auth.uid).get();
    if (!callerSnap.exists) {
        throw new https_1.HttpsError("not-found", "Caller user profile not found.");
    }
    const callerRole = (_a = callerSnap.data().role) !== null && _a !== void 0 ? _a : "";
    // Role-based guards
    if (callerRole !== "super_admin" && callerRole !== "teacher") {
        throw new https_1.HttpsError("permission-denied", "Only super admins and teachers can generate invites.");
    }
    if (callerRole === "teacher") {
        if (role !== "parent") {
            throw new https_1.HttpsError("permission-denied", "Teachers can only invite parents.");
        }
        const teacherCrecheIds = (_b = callerSnap.data().crecheIds) !== null && _b !== void 0 ? _b : [];
        if (!teacherCrecheIds.includes(crecheId)) {
            throw new https_1.HttpsError("permission-denied", "You are not assigned to this crèche.");
        }
    }
    const tokenId = (0, uuid_1.v4)();
    const secret = INVITE_JWT_SECRET.value();
    const payload = {
        tokenId,
        role,
        crecheId,
        createdBy: request.auth.uid,
    };
    const token = jwt.sign(payload, secret, { expiresIn: "7d" });
    const expiresAt = admin.firestore.Timestamp.fromMillis(Date.now() + 7 * 24 * 60 * 60 * 1000);
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
});
// ── validateInvite ────────────────────────────────────────────────────────────
// Called by: unauthenticated app (before registration)
// Returns:   { valid, role, crecheId, tokenId } or { valid: false, error }
exports.validateInvite = (0, https_1.onCall)({ secrets: [INVITE_JWT_SECRET] }, async (request) => {
    const { token } = request.data;
    if (!token) {
        return { valid: false, error: "No token provided." };
    }
    const secret = INVITE_JWT_SECRET.value();
    let payload;
    try {
        payload = jwt.verify(token, secret);
    }
    catch (_a) {
        return { valid: false, error: "This invite link has expired or is invalid." };
    }
    const inviteSnap = await db.collection("invites").doc(payload.tokenId).get();
    if (!inviteSnap.exists) {
        return { valid: false, error: "Invite not found." };
    }
    const invite = inviteSnap.data();
    if (invite.consumed) {
        return { valid: false, error: "This invite link has already been used." };
    }
    return {
        valid: true,
        role: payload.role,
        crecheId: payload.crecheId,
        tokenId: payload.tokenId,
    };
});
// ── consumeInvite ─────────────────────────────────────────────────────────────
// Called by: authenticated app after successful registration
// Returns:   { success: true }
exports.consumeInvite = (0, https_1.onCall)({ secrets: [INVITE_JWT_SECRET] }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Must be signed in to consume an invite.");
    }
    const { tokenId } = request.data;
    if (!tokenId) {
        throw new https_1.HttpsError("invalid-argument", "tokenId is required.");
    }
    const inviteRef = db.collection("invites").doc(tokenId);
    // Atomic transaction to prevent double-consumption races
    await db.runTransaction(async (tx) => {
        const snap = await tx.get(inviteRef);
        if (!snap.exists) {
            throw new https_1.HttpsError("not-found", "Invite not found.");
        }
        if (snap.data().consumed) {
            throw new https_1.HttpsError("already-exists", "Invite already consumed.");
        }
        tx.update(inviteRef, {
            consumed: true,
            consumedAt: admin.firestore.FieldValue.serverTimestamp(),
            consumedBy: request.auth.uid,
        });
    });
    // Audit log (outside transaction — fire-and-forget acceptable here)
    const inviteSnap = await inviteRef.get();
    const inviteData = inviteSnap.data();
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
});
// ── notifyParentsOnAttendance ─────────────────────────────────────────────────
// Triggered whenever an attendance document is created or updated.
// Sends an FCM push notification to all linked parents when a child is
// signed in or out, and includes geofence status in the message body.
exports.notifyParentsOnAttendance = (0, firestore_1.onDocumentWritten)("attendance/{docId}", async (event) => {
    var _a, _b, _c, _d, _e, _f;
    const after = (_b = (_a = event.data) === null || _a === void 0 ? void 0 : _a.after) === null || _b === void 0 ? void 0 : _b.data();
    const before = (_d = (_c = event.data) === null || _c === void 0 ? void 0 : _c.before) === null || _d === void 0 ? void 0 : _d.data();
    // Ignore deletes and non-attendance-status documents
    if (!after)
        return;
    const status = after.status;
    if (status !== "signed_in" && status !== "signed_out")
        return;
    // Only act on actual status transitions
    if ((before === null || before === void 0 ? void 0 : before.status) === status)
        return;
    const childId = after.childId;
    const crecheId = after.crecheId;
    // ── Fetch child ──────────────────────────────────────────────────────────
    const childSnap = await db.collection("children").doc(childId).get();
    if (!childSnap.exists)
        return;
    const childData = childSnap.data();
    const childName = `${childData.firstName} ${childData.lastName}`;
    const parentIds = (_e = childData.parentIds) !== null && _e !== void 0 ? _e : [];
    // ── Fetch crèche ─────────────────────────────────────────────────────────
    const crecheSnap = await db.collection("creches").doc(crecheId).get();
    const crecheName = crecheSnap.exists ? crecheSnap.data().name : "Crèche";
    // ── Geofence check (sign-in only) ────────────────────────────────────────
    let withinGeofence = null;
    if (status === "signed_in" && crecheSnap.exists) {
        const crecheData = crecheSnap.data();
        const cLat = crecheData.latitude;
        const cLon = crecheData.longitude;
        const radius = (_f = crecheData.geofenceRadiusMeters) !== null && _f !== void 0 ? _f : 200;
        const signLat = after.signInLatitude;
        const signLon = after.signInLongitude;
        if (cLat != null && cLon != null && signLat != null && signLon != null) {
            withinGeofence = _haversineMeters(signLat, signLon, cLat, cLon) <= radius;
        }
    }
    // ── Build notification ───────────────────────────────────────────────────
    let title;
    let body;
    if (status === "signed_in") {
        title = `${childName} has arrived`;
        body = withinGeofence === false
            ? `⚠️ Signed in outside ${crecheName}`
            : `✅ Signed in at ${crecheName}`;
    }
    else {
        title = `${childName} has left`;
        body = `Signed out from ${crecheName}`;
    }
    // ── Collect FCM tokens ───────────────────────────────────────────────────
    const tokens = [];
    for (const uid of parentIds) {
        const userSnap = await db.collection("users").doc(uid).get();
        if (!userSnap.exists)
            continue;
        const token = userSnap.data().fcmToken;
        if (token)
            tokens.push(token);
    }
    if (tokens.length === 0)
        return;
    // ── Send FCM ─────────────────────────────────────────────────────────────
    await admin.messaging().sendEachForMulticast({
        tokens,
        notification: { title, body },
        data: { childId, crecheId, status },
        android: { priority: "high" },
        apns: { payload: { aps: { sound: "default" } } },
    });
});
// ── Helpers ───────────────────────────────────────────────────────────────────
function _haversineMeters(lat1, lon1, lat2, lon2) {
    const R = 6371000;
    const dLat = _toRad(lat2 - lat1);
    const dLon = _toRad(lon2 - lon1);
    const a = Math.sin(dLat / 2) ** 2 +
        Math.cos(_toRad(lat1)) * Math.cos(_toRad(lat2)) * Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
function _toRad(deg) {
    return (deg * Math.PI) / 180;
}
//# sourceMappingURL=index.js.map