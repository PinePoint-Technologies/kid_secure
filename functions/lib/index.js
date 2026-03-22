"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendCrecheWelcomeEmail = exports.traccarWebhook = exports.trackerWebhook = exports.notifyParentsOnAttendance = exports.consumeInvite = exports.validateInvite = exports.generateInvite = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const params_1 = require("firebase-functions/params");
const jwt = require("jsonwebtoken");
const uuid_1 = require("uuid");
const nodemailer = require("nodemailer");
admin.initializeApp();
const db = admin.firestore();
const INVITE_JWT_SECRET = (0, params_1.defineSecret)("INVITE_JWT_SECRET");
const TRACKER_API_KEY = (0, params_1.defineSecret)("TRACKER_API_KEY");
const SMTP_USER = (0, params_1.defineSecret)("SMTP_USER");
const SMTP_PASS = (0, params_1.defineSecret)("SMTP_PASS");
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
// ── trackerWebhook ────────────────────────────────────────────────────────────
// HTTP endpoint for GPS+GSM tracker devices.
// Tracker must POST JSON with x-tracker-key header matching TRACKER_API_KEY.
//
// Request body:
//   { deviceId, lat, lon, timestamp?, speed?, batteryLevel? }
// Response:
//   200 { ok: true } | 400/401 { error: string }
exports.trackerWebhook = (0, https_1.onRequest)({ secrets: [TRACKER_API_KEY] }, async (req, res) => {
    // ── Auth ─────────────────────────────────────────────────────────────────
    const apiKey = req.headers["x-tracker-key"];
    if (!apiKey || apiKey !== TRACKER_API_KEY.value()) {
        res.status(401).json({ error: "Unauthorized" });
        return;
    }
    // ── Validate body ─────────────────────────────────────────────────────────
    const { deviceId, lat, lon, timestamp, speed, batteryLevel } = req.body;
    if (!deviceId || lat == null || lon == null) {
        res.status(400).json({ error: "deviceId, lat, and lon are required." });
        return;
    }
    const recordedAt = timestamp != null
        ? admin.firestore.Timestamp.fromMillis(timestamp * 1000)
        : admin.firestore.FieldValue.serverTimestamp();
    const locationData = Object.assign(Object.assign({ lat,
        lon,
        recordedAt }, (speed != null && { speed })), (batteryLevel != null && { batteryLevel }));
    await _handleTrackerPing(deviceId, lat, lon, locationData);
    res.status(200).json({ ok: true });
});
// ── traccarWebhook ────────────────────────────────────────────────────────────
// Receives position forwards from a self-hosted Traccar server.
// Configure Traccar: forward.type=json, forward.url=<this URL>,
//   forward.header=x-tracker-key: <TRACKER_API_KEY secret value>
// Traccar POSTs: { position: { latitude, longitude, speed (knots),
//   fixTime (ISO 8601), attributes: { battery } }, device: { uniqueId } }
exports.traccarWebhook = (0, https_1.onRequest)({ secrets: [TRACKER_API_KEY] }, async (req, res) => {
    var _a, _b, _c, _d, _e, _f, _g;
    const apiKey = req.headers["x-tracker-key"];
    if (!apiKey || apiKey !== TRACKER_API_KEY.value()) {
        res.status(401).json({ error: "Unauthorized" });
        return;
    }
    const body = req.body;
    const deviceId = (_a = body.device) === null || _a === void 0 ? void 0 : _a.uniqueId;
    const lat = (_b = body.position) === null || _b === void 0 ? void 0 : _b.latitude;
    const lon = (_c = body.position) === null || _c === void 0 ? void 0 : _c.longitude;
    if (!deviceId || lat == null || lon == null) {
        res.status(400).json({
            error: "device.uniqueId, position.latitude and position.longitude are required.",
        });
        return;
    }
    const fixTime = (_d = body.position) === null || _d === void 0 ? void 0 : _d.fixTime;
    const recordedAt = fixTime
        ? admin.firestore.Timestamp.fromDate(new Date(fixTime))
        : admin.firestore.FieldValue.serverTimestamp();
    // Traccar reports speed in knots — convert to m/s
    const speedKnots = (_e = body.position) === null || _e === void 0 ? void 0 : _e.speed;
    const speedMs = speedKnots != null ? speedKnots * 0.514444 : undefined;
    const batteryLevel = (_g = (_f = body.position) === null || _f === void 0 ? void 0 : _f.attributes) === null || _g === void 0 ? void 0 : _g.battery;
    const locationData = Object.assign(Object.assign({ lat,
        lon,
        recordedAt }, (speedMs != null && { speed: speedMs })), (batteryLevel != null && { batteryLevel }));
    await _handleTrackerPing(deviceId, lat, lon, locationData);
    res.status(200).json({ ok: true });
});
// ── _handleTrackerPing ────────────────────────────────────────────────────────
// Writes a tracker location to Firestore and sends a geofence-breach FCM
// notification to linked parents when the device is outside the crèche boundary.
async function _handleTrackerPing(deviceId, lat, lon, locationData) {
    var _a, _b, _c, _d;
    const trackerRef = db.collection("trackers").doc(deviceId);
    await Promise.all([
        trackerRef.set(locationData, { merge: true }),
        trackerRef.collection("locations").add(locationData),
    ]);
    const childSnap = await db
        .collection("children")
        .where("trackerId", "==", deviceId)
        .where("status", "==", "active")
        .limit(1)
        .get();
    if (childSnap.empty)
        return;
    const childDoc = childSnap.docs[0];
    const childData = childDoc.data();
    const childName = `${childData.firstName} ${childData.lastName}`;
    const crecheId = (_a = childData.crecheId) !== null && _a !== void 0 ? _a : "";
    const parentIds = (_b = childData.parentIds) !== null && _b !== void 0 ? _b : [];
    const crecheSnap = await db.collection("creches").doc(crecheId).get();
    if (!crecheSnap.exists)
        return;
    const crecheData = crecheSnap.data();
    const cLat = crecheData.latitude;
    const cLon = crecheData.longitude;
    const radius = (_c = crecheData.geofenceRadiusMeters) !== null && _c !== void 0 ? _c : 200;
    if (cLat == null || cLon == null)
        return;
    if (_haversineMeters(lat, lon, cLat, cLon) <= radius)
        return;
    const tokens = [];
    for (const uid of parentIds) {
        const userSnap = await db.collection("users").doc(uid).get();
        if (!userSnap.exists)
            continue;
        const fcmToken = userSnap.data().fcmToken;
        if (fcmToken)
            tokens.push(fcmToken);
    }
    if (tokens.length > 0) {
        await admin.messaging().sendEachForMulticast({
            tokens,
            notification: {
                title: `⚠️ ${childName} left the crèche`,
                body: `Tracker detected outside ${(_d = crecheData.name) !== null && _d !== void 0 ? _d : "crèche"} boundary.`,
            },
            data: {
                childId: childDoc.id,
                crecheId,
                event: "tracker_geofence_breach",
                deviceId,
            },
            android: { priority: "high" },
            apns: { payload: { aps: { sound: "default" } } },
        });
    }
}
// ── sendCrecheWelcomeEmail ────────────────────────────────────────────────────
// Triggered when a new crèche document is created in Firestore.
// Sends an onboarding welcome email to the crèche's registered email address.
exports.sendCrecheWelcomeEmail = (0, firestore_1.onDocumentCreated)({ document: "creches/{crecheId}", secrets: [SMTP_USER, SMTP_PASS] }, async (event) => {
    var _a, _b;
    const data = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!data)
        return;
    const email = data.email;
    if (!email)
        return; // no email address on this crèche — skip
    const crecheName = (_b = data.name) !== null && _b !== void 0 ? _b : "Your Crèche";
    const address = [data.address, data.city, data.province]
        .filter(Boolean)
        .join(", ");
    const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: { user: SMTP_USER.value(), pass: SMTP_PASS.value() },
    });
    await transporter.sendMail({
        from: `"KidSecure" <${SMTP_USER.value()}>`,
        to: email,
        subject: `Welcome to KidSecure — ${crecheName} is live!`,
        html: _buildWelcomeEmailHtml(crecheName, address),
    });
});
// ── Email HTML template ───────────────────────────────────────────────────────
function _buildWelcomeEmailHtml(crecheName, address) {
    const addressLine = address ? `<p style="margin:0 0 4px;font-size:14px;color:#6b7280;">${address}</p>` : "";
    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1.0" />
  <title>Welcome to KidSecure</title>
</head>
<body style="margin:0;padding:0;background-color:#f3f4f6;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:40px 16px;">
    <tr>
      <td align="center">
        <table width="100%" style="max-width:560px;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#1B5286 0%,#2176C7 100%);padding:36px 40px;text-align:center;">
              <h1 style="margin:0;font-size:26px;font-weight:800;color:#ffffff;letter-spacing:-0.5px;">KidSecure</h1>
              <p style="margin:6px 0 0;font-size:14px;color:rgba(255,255,255,0.75);letter-spacing:0.5px;">Safe. Smart. Connected.</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px 28px;">
              <h2 style="margin:0 0 6px;font-size:22px;font-weight:700;color:#111827;">Welcome aboard, ${crecheName}!</h2>
              ${addressLine}
              <p style="margin:20px 0 0;font-size:15px;line-height:1.7;color:#374151;">
                Your crèche has been successfully registered on <strong>KidSecure</strong>.
                You now have access to a complete school management platform built around
                child safety, real-time GPS tracking, and seamless communication between
                staff and parents.
              </p>
            </td>
          </tr>

          <!-- Divider -->
          <tr>
            <td style="padding:0 40px;">
              <hr style="border:none;border-top:1px solid #e5e7eb;margin:0;" />
            </td>
          </tr>

          <!-- Next steps -->
          <tr>
            <td style="padding:28px 40px 8px;">
              <h3 style="margin:0 0 20px;font-size:15px;font-weight:700;color:#111827;text-transform:uppercase;letter-spacing:0.8px;">Get started in 3 steps</h3>

              <!-- Step 1 -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:18px;">
                <tr>
                  <td width="40" valign="top">
                    <div style="width:32px;height:32px;border-radius:50%;background:#1B5286;color:#fff;font-size:14px;font-weight:700;text-align:center;line-height:32px;">1</div>
                  </td>
                  <td style="padding-left:14px;">
                    <p style="margin:0;font-size:15px;font-weight:600;color:#111827;">Add your teachers</p>
                    <p style="margin:4px 0 0;font-size:14px;color:#6b7280;line-height:1.5;">Invite your staff so they can sign children in and out and communicate with parents.</p>
                  </td>
                </tr>
              </table>

              <!-- Step 2 -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:18px;">
                <tr>
                  <td width="40" valign="top">
                    <div style="width:32px;height:32px;border-radius:50%;background:#1B5286;color:#fff;font-size:14px;font-weight:700;text-align:center;line-height:32px;">2</div>
                  </td>
                  <td style="padding-left:14px;">
                    <p style="margin:0;font-size:15px;font-weight:600;color:#111827;">Enrol children</p>
                    <p style="margin:4px 0 0;font-size:14px;color:#6b7280;line-height:1.5;">Register each child in your crèche and optionally assign a GPS tracker device to them.</p>
                  </td>
                </tr>
              </table>

              <!-- Step 3 -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:8px;">
                <tr>
                  <td width="40" valign="top">
                    <div style="width:32px;height:32px;border-radius:50%;background:#1B5286;color:#fff;font-size:14px;font-weight:700;text-align:center;line-height:32px;">3</div>
                  </td>
                  <td style="padding-left:14px;">
                    <p style="margin:0;font-size:15px;font-weight:600;color:#111827;">Link parents &amp; guardians</p>
                    <p style="margin:4px 0 0;font-size:14px;color:#6b7280;line-height:1.5;">Invite parents so they receive real-time check-in notifications and can track their child's location.</p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Divider -->
          <tr>
            <td style="padding:24px 40px 0;">
              <hr style="border:none;border-top:1px solid #e5e7eb;margin:0;" />
            </td>
          </tr>

          <!-- Support note -->
          <tr>
            <td style="padding:24px 40px 36px;">
              <p style="margin:0;font-size:14px;color:#6b7280;line-height:1.6;">
                If you have any questions or need help setting up, reply to this email
                and our support team will be happy to assist.
              </p>
              <p style="margin:18px 0 0;font-size:14px;color:#374151;">
                Welcome to the KidSecure family 👋<br />
                <strong>The KidSecure Team</strong>
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#f9fafb;padding:20px 40px;border-top:1px solid #e5e7eb;text-align:center;">
              <p style="margin:0;font-size:12px;color:#9ca3af;">
                © ${new Date().getFullYear()} KidSecure. All rights reserved.<br />
                This email was sent because your crèche was registered on the KidSecure platform.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}
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