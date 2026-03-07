import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Brand (matched to logo) ────────────────────────────────────────────
  // Dark navy  → shield outline + "KidSecure" wordmark
  static const Color primary = Color(0xFF1B5286);
  static const Color primaryDark = Color(0xFF123A61);
  static const Color primaryLight = Color(0xFF4DAEE5);

  // Sky blue   → shield fill
  static const Color secondary = Color(0xFF4DAEE5);
  static const Color secondaryDark = Color(0xFF2B8CC4);
  static const Color secondaryLight = Color(0xFF93D4F5);

  // Golden yellow → child figure
  static const Color accent = Color(0xFFF5B731);
  static const Color accentDark = Color(0xFFD4920F);
  static const Color accentLight = Color(0xFFFDD882);

  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF97316);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // ─── Role colours ────────────────────────────────────────────────────────
  static const Color superAdmin = Color(0xFF8B5CF6);   // purple
  static const Color teacher = Color(0xFF1B5286);      // brand navy
  static const Color parent = Color(0xFF4DAEE5);       // sky blue

  // ─── Attendance status ───────────────────────────────────────────────────
  static const Color signedIn = Color(0xFF22C55E);
  static const Color signedOut = Color(0xFFEF4444);
  static const Color absent = Color(0xFFF97316);
  static const Color sickLeave = Color(0xFF8B5CF6);

  // ─── Neutral light ───────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF4FA);
  static const Color border = Color(0xFFD4E3F0);
  static const Color divider = Color(0xFFBDD5EC);

  static const Color textPrimary = Color(0xFF0D2D4A);
  static const Color textSecondary = Color(0xFF3D6080);
  static const Color textHint = Color(0xFF8BA8C2);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ─── Neutral dark ────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0A1929);
  static const Color surfaceDark = Color(0xFF0F2439);
  static const Color surfaceVariantDark = Color(0xFF163450);
  static const Color borderDark = Color(0xFF234B70);

  static const Color textPrimaryDark = Color(0xFFE8F2FB);
  static const Color textSecondaryDark = Color(0xFF93C4E0);
  static const Color textHintDark = Color(0xFF4A7A9B);

  // ─── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B5286), Color(0xFF4DAEE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient superAdminGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient teacherGradient = LinearGradient(
    colors: [Color(0xFF1B5286), Color(0xFF2B8CC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient parentGradient = LinearGradient(
    colors: [Color(0xFF4DAEE5), Color(0xFF1B5286)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF5B731), Color(0xFFFFD966)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0D2D4A), Color(0xFF1B5286), Color(0xFF4DAEE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
