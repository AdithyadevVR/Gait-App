import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/dashboard_theme.dart';

/// Standalone foot heatmap: blue → green → yellow → red gradient + glow for high pressure.
/// Animates pressure changes smoothly via TweenAnimationBuilder in parent if desired.
class FootHeatmapWidget extends StatelessWidget {
  final double heelKg;
  final double ballKg;
  final double toeKg;
  final bool isRightFoot;

  const FootHeatmapWidget({
    super.key,
    required this.heelKg,
    required this.ballKg,
    required this.toeKg,
    this.isRightFoot = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      heelKg.abs(),
      ballKg.abs(),
      toeKg.abs(),
      1.0,
    ].reduce((a, b) => a > b ? a : b);

    double norm(double v) => (v.abs() / maxValue).clamp(0.0, 1.0);
    final heelT = norm(heelKg);
    final ballT = norm(ballKg);
    final toeT = norm(toeKg);

    return CustomPaint(
      painter: _HeatmapPainter(
        heelColor: DashboardTheme.pressureColor(heelT),
        ballColor: DashboardTheme.pressureColor(ballT),
        toeColor: DashboardTheme.pressureColor(toeT),
        heelGlow: DashboardTheme.showGlow(heelT),
        ballGlow: DashboardTheme.showGlow(ballT),
        toeGlow: DashboardTheme.showGlow(toeT),
        isRightFoot: isRightFoot,
      ),
      size: Size.infinite,
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final Color heelColor;
  final Color ballColor;
  final Color toeColor;
  final bool heelGlow;
  final bool ballGlow;
  final bool toeGlow;
  final bool isRightFoot;

  _HeatmapPainter({
    required this.heelColor,
    required this.ballColor,
    required this.toeColor,
    required this.heelGlow,
    required this.ballGlow,
    required this.toeGlow,
    required this.isRightFoot,
  });

  static Path _footPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.42, h * 0.95)
      ..quadraticBezierTo(w * 0.32, h * 0.80, w * 0.30, h * 0.62)
      ..quadraticBezierTo(w * 0.30, h * 0.46, w * 0.38, h * 0.32)
      ..quadraticBezierTo(w * 0.44, h * 0.22, w * 0.50, h * 0.18)
      ..quadraticBezierTo(w * 0.64, h * 0.14, w * 0.66, h * 0.22)
      ..quadraticBezierTo(w * 0.72, h * 0.22, w * 0.72, h * 0.28)
      ..quadraticBezierTo(w * 0.74, h * 0.34, w * 0.73, h * 0.40)
      ..quadraticBezierTo(w * 0.78, h * 0.60, w * 0.70, h * 0.78)
      ..quadraticBezierTo(w * 0.64, h * 0.92, w * 0.52, h * 0.97)
      ..quadraticBezierTo(w * 0.46, h * 0.99, w * 0.42, h * 0.95)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Path footPath = _footPath(size);
    if (isRightFoot) {
      final m = Matrix4.identity()
        ..scale(-1.0, 1.0, 1.0)
        ..translate(-w, 0.0);
      footPath = footPath.transform(m.storage);
    }

    final heelRect = Rect.fromCenter(center: Offset(w * 0.48, h * 0.84), width: w * 0.48, height: h * 0.22);
    final ballRect = Rect.fromCenter(center: Offset(w * 0.55, h * 0.48), width: w * 0.50, height: h * 0.18);
    final toeRect = Rect.fromCenter(center: Offset(w * 0.60, h * 0.26), width: w * 0.40, height: h * 0.16);

    canvas.save();
    canvas.clipPath(footPath);

    void drawRegion(Rect rect, Color color, bool glow) {
      if (glow) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(16), const Radius.circular(44)),
          Paint()
            ..color = color.withOpacity(0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
        );
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(40)),
        Paint()..color = color.withOpacity(0.92),
      );
    }

    drawRegion(heelRect, heelColor, heelGlow);
    drawRegion(ballRect, ballColor, ballGlow);
    drawRegion(toeRect, toeColor, toeGlow);

    canvas.restore();

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.white.withOpacity(0.25);
    canvas.drawPath(footPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) {
    return heelColor != old.heelColor || ballColor != old.ballColor ||
        toeColor != old.toeColor || heelGlow != old.heelGlow ||
        ballGlow != old.ballGlow || toeGlow != old.toeGlow ||
        isRightFoot != old.isRightFoot;
  }
}
