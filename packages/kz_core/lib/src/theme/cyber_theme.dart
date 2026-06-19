import 'package:flutter/material.dart';

/// Sistema de Color Cyber-Zen Industrial.
/// INMUTABLE — no modificar sin directiva global del arquitecto.
/// El acento dinámico se controla exclusivamente vía Riverpod Provider.
abstract final class CyberTheme {
  // ─── Fondos ───────────────────────────────────────────────────────────────
  /// Fondo absoluto y mate de toda la aplicación. Evita destellos visuales.
  static const Color bgObsidian = Color(0xFF0D0E15);

  // ─── Tipografía ───────────────────────────────────────────────────────────
  /// Texto principal e indicadores tipográficos de alto contraste.
  static const Color textNeutral = Color(0xFFFFFFFF);

  // ─── Feedback ─────────────────────────────────────────────────────────────
  /// Feedback inmediato para fallos críticos de entrada o alertas.
  static const Color errorRed = Color(0xFFE53935);

  /// Color de acento primario para éxitos y progreso.
  /// ⚠ Controlado dinámicamente vía Riverpod Provider — no usar directamente.
  static const Color defaultAccent = Color(0xFF00E676);

  // ─── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgObsidian,
    colorScheme: const ColorScheme.dark(
      surface: bgObsidian,
      primary: defaultAccent,
      error: errorRed,
      onSurface: textNeutral,
    ),
    fontFamily: 'Courier', // Monospace base — sobrescribir por feature
    useMaterial3: true,
  );
}
