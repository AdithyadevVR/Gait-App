import 'dart:ui';
import 'package:flutter/material.dart';

/// Dark dashboard theme: gradients, glass cards, neon accents.
class DashboardTheme {
  DashboardTheme._();

  static const Color surfaceDark = Color(0xFF0D1117);
  static const Color surfaceMid = Color(0xFF161B22);
  static const Color surfaceCard = Color(0xFF21262D);
  static const Color accentBlue = Color(0xFF58A6FF);
  static const Color accentCyan = Color(0xFF39C5CF);
  static const Color accentGreen = Color(0xFF3FB950);
  static const Color accentYellow = Color(0xFFD29922);
  static const Color accentOrange = Color(0xFFDB6D28);
  static const Color accentRed = Color(0xFFF85149);
  static const Color accentPurple = Color(0xFFA371F7);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E17),
      Color(0xFF0D1321),
      Color(0xFF12162B),
      Color(0xFF0F0A18),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
  );

  /// Glassmorphism card: blur + light border + rounded.
  static BoxDecoration glassCard({
    Color? color,
    double borderRadius = 20,
    Border? border,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: (color ?? surfaceCard).withOpacity(0.6),
      border: border ??
          Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Pressure gradient: blue → green → yellow → red (t in [0,1]).
  static Color pressureColor(double t) {
    final x = t.clamp(0.0, 1.0);
    if (x < 0.33) {
      return Color.lerp(const Color(0xFF1E88E5), const Color(0xFF43A047), x / 0.33)!;
    }
    if (x < 0.66) {
      return Color.lerp(const Color(0xFF43A047), const Color(0xFFFDD835), (x - 0.33) / 0.33)!;
    }
    return Color.lerp(const Color(0xFFFDD835), const Color(0xFFE53935), (x - 0.66) / 0.34)!;
  }

  /// Neon glow for high pressure (t > 0.6).
  static bool showGlow(double t) => t > 0.6;
}
