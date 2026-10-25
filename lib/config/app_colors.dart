// ============================================================
//  APP COLORS — Poori app ke rang yahin se aate hain
//
//  Koi rang badalna ho to sirf yahan hex code badlein,
//  poori app me apne aap badal jayega.
//  Format: Color(0xFF + 6 digit hex)   e.g. #EA580C -> 0xFFEA580C
// ============================================================
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------- Brand ----------
  static const Color primary = Color(0xFFEA580C); // Orange — buttons, active tab, links
  static const Color primaryLight = Color(0xFFFFF1E8); // Halka orange — icon background
  static const Color navy = Color(0xFF011E60); // Logo ka navy — headers, certificate

  // ---------- Background ----------
  static const Color background = Color(0xFFFAF7F2); // Screen ka background (off-white)
  static const Color surface = Color(0xFFFFFFFF); // Cards ka background (white)
  static const Color border = Color(0xFFECE7E1); // Card / input ki border line

  // ---------- Text ----------
  static const Color textDark = Color(0xFF1C1917); // Main text
  static const Color textMuted = Color(0xFF78716C); // Halka / secondary text

  // ---------- Status ----------
  static const Color success = Color(0xFF15803D); // Green — discount, verified
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626); // Red — error message
  static const Color star = Color(0xFFF59E0B); // Rating star
  static const Color disabled = Color(0xFFD6D3D1); // Disabled button

  // ---------- Internship type badges ----------
  static const Color paidBg = Color(0xFFFFF1E8);
  static const Color paidText = Color(0xFFC2410C);
  static const Color freeBg = Color(0xFFDCFCE7);
  static const Color freeText = Color(0xFF15803D);
  static const Color stipendBg = Color(0xFFEFF6FF);
  static const Color stipendText = Color(0xFF1D4ED8);
  static const Color projectBg = Color(0xFFF3E8FF);
  static const Color projectText = Color(0xFF7E22CE);
}
