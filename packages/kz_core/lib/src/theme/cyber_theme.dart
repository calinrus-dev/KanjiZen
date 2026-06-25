import 'package:flutter/material.dart';

/// Extensión de tema para propiedades dinámicas del motor Kanjizen
class CyberThemeExtension extends ThemeExtension<CyberThemeExtension> {
  const CyberThemeExtension({
    required this.accentColor,
    required this.fontMultiplier,
    required this.strokeMultiplier,
  });

  final Color accentColor;
  final double fontMultiplier;
  final double strokeMultiplier;

  @override
  ThemeExtension<CyberThemeExtension> copyWith({
    Color? accentColor,
    double? fontMultiplier,
    double? strokeMultiplier,
  }) {
    return CyberThemeExtension(
      accentColor: accentColor ?? this.accentColor,
      fontMultiplier: fontMultiplier ?? this.fontMultiplier,
      strokeMultiplier: strokeMultiplier ?? this.strokeMultiplier,
    );
  }

  @override
  ThemeExtension<CyberThemeExtension> lerp(
    covariant ThemeExtension<CyberThemeExtension>? other,
    double t,
  ) {
    if (other is! CyberThemeExtension) return this;
    return CyberThemeExtension(
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      fontMultiplier:
          lerpDouble(fontMultiplier, other.fontMultiplier, t) ?? fontMultiplier,
      strokeMultiplier:
          lerpDouble(strokeMultiplier, other.strokeMultiplier, t) ??
          strokeMultiplier,
    );
  }

  double? lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}

/// Sistema de Color Cyber-Zen Industrial.
abstract final class CyberTheme {
  static const Color bgObsidian = Color(0xFF000000); // Negro puro OLED
  static const Color textNeutral = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFE53935);
  static const Color defaultAccent = Color(0xFF00E676);

  static ThemeData themeData({
    Color accentColor = defaultAccent,
    double fontMultiplier = 1.0,
    double strokeMultiplier = 1.0,
  }) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgObsidian,
      colorScheme: ColorScheme.dark(
        surface: bgObsidian,
        primary: accentColor,
        error: errorRed,
        onSurface: textNeutral,
      ),
      fontFamily: 'Courier',
      useMaterial3: true,
      extensions: [
        CyberThemeExtension(
          accentColor: accentColor,
          fontMultiplier: fontMultiplier,
          strokeMultiplier: strokeMultiplier,
        ),
      ],
    );
  }
}
