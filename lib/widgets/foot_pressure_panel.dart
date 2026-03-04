import 'package:flutter/material.dart';
import 'sensor_card.dart';

class FootPressurePanel extends StatelessWidget {
  final String title;
  final double heelKg;
  final double ballKg;
  final double toeKg;
  final bool isRightFoot;

  const FootPressurePanel({
    super.key,
    required this.title,
    required this.heelKg,
    required this.ballKg,
    required this.toeKg,
    this.isRightFoot = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SensorCard(
      title: title,
      subtitle: 'Real-time plantar pressure distribution',
      icon: isRightFoot ? Icons.directions_walk : Icons.directions_walk_outlined,
      trailing: _buildLoadChip(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 420;
          return isWide
              ? Row(
                  children: [
                    Expanded(flex: 3, child: _buildFootHeatmap(context)),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: _buildSensorValues(context)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 180,
                      child: _buildFootHeatmap(context),
                    ),
                    const SizedBox(height: 16),
                    _buildSensorValues(context),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildLoadChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalLoad = heelKg + ballKg + toeKg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.secondaryContainer.withOpacity(0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.opacity, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            '${totalLoad.toStringAsFixed(1)} kg',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFootHeatmap(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxValue = [
      heelKg.abs(),
      ballKg.abs(),
      toeKg.abs(),
      1.0, // avoid division by zero
    ].reduce((a, b) => a > b ? a : b);

    Color colorFor(double value) {
      final t = (value.abs() / maxValue).clamp(0.0, 1.0);
      // Interpolate from cool (blue) to hot (red)
      return Color.lerp(
            Colors.blueAccent,
            Colors.redAccent,
            t,
          ) ??
          colorScheme.primary;
    }

    return AspectRatio(
      aspectRatio: 2 / 5,
      child: CustomPaint(
        painter: _FootHeatmapPainter(
          heelColor: colorFor(heelKg),
          ballColor: colorFor(ballKg),
          toeColor: colorFor(toeKg),
          outlineColor: colorScheme.outlineVariant.withOpacity(0.7),
          isRightFoot: isRightFoot,
        ),
      ),
    );
  }

  Widget _buildSensorValues(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildChip(String label, double value, Color accent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surface.withOpacity(0.7),
          border: Border.all(color: accent.withOpacity(0.7), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    accent.withOpacity(0.2),
                    accent,
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.1,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.toStringAsFixed(2)} kg',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildChip('Heel', heelKg, Colors.deepPurpleAccent),
        const SizedBox(height: 10),
        buildChip('Ball', ballKg, Colors.tealAccent.shade400),
        const SizedBox(height: 10),
        buildChip('Toe', toeKg, Colors.orangeAccent),
      ],
    );
  }
}

class _FootHeatmapPainter extends CustomPainter {
  final Color heelColor;
  final Color ballColor;
  final Color toeColor;
  final Color outlineColor;
  final bool isRightFoot;

  _FootHeatmapPainter({
    required this.heelColor,
    required this.ballColor,
    required this.toeColor,
    required this.outlineColor,
    required this.isRightFoot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Stylised footprint outline (narrow heel, arch, wide toes)
    final footPath = Path()
      // start at inner heel
      ..moveTo(width * 0.42, height * 0.95)
      // inner arch up towards midfoot
      ..quadraticBezierTo(
        width * 0.32,
        height * 0.80,
        width * 0.30,
        height * 0.62,
      )
      ..quadraticBezierTo(
        width * 0.30,
        height * 0.46,
        width * 0.38,
        height * 0.32,
      )
      ..quadraticBezierTo(
        width * 0.44,
        height * 0.22,
        width * 0.50,
        height * 0.18,
      )
      // big toe
      ..quadraticBezierTo(
        width * 0.64,
        height * 0.14,
        width * 0.66,
        height * 0.22,
      )
      // second toe
      ..quadraticBezierTo(
        width * 0.72,
        height * 0.22,
        width * 0.72,
        height * 0.28,
      )
      // outer toe ridge
      ..quadraticBezierTo(
        width * 0.74,
        height * 0.34,
        width * 0.73,
        height * 0.40,
      )
      // outer edge down towards heel
      ..quadraticBezierTo(
        width * 0.78,
        height * 0.60,
        width * 0.70,
        height * 0.78,
      )
      ..quadraticBezierTo(
        width * 0.64,
        height * 0.92,
        width * 0.52,
        height * 0.97,
      )
      ..quadraticBezierTo(
        width * 0.46,
        height * 0.99,
        width * 0.42,
        height * 0.95,
      )
      ..close();

    // Mirror for right foot if needed
    if (isRightFoot) {
      final matrix4 = Matrix4.identity()
        ..scale(-1.0, 1.0, 1.0)
        ..translate(-width, 0.0);
      footPath.transform(matrix4.storage);
    }

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = outlineColor;

    // Heel region (rounded pad)
    final heelRect = Rect.fromCenter(
      center: Offset(width * 0.48, height * 0.84),
      width: width * 0.48,
      height: height * 0.22,
    );

    // Ball region (across metatarsal heads)
    final ballRect = Rect.fromCenter(
      center: Offset(width * 0.55, height * 0.48),
      width: width * 0.50,
      height: height * 0.18,
    );

    // Toe region (slightly separate from ball)
    final toeRect = Rect.fromCenter(
      center: Offset(width * 0.60, height * 0.26),
      width: width * 0.40,
      height: height * 0.16,
    );

    canvas.save();

    // Clip to the foot silhouette for heatmap effect
    canvas.clipPath(footPath);

    canvas.drawRRect(
      RRect.fromRectAndRadius(heelRect, const Radius.circular(40)),
      Paint()..color = heelColor.withOpacity(0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ballRect, const Radius.circular(40)),
      Paint()..color = ballColor.withOpacity(0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(toeRect, const Radius.circular(40)),
      Paint()..color = toeColor.withOpacity(0.9),
    );

    canvas.restore();

    // Draw silhouette outline on top
    canvas.drawPath(footPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _FootHeatmapPainter oldDelegate) {
    return heelColor != oldDelegate.heelColor ||
        ballColor != oldDelegate.ballColor ||
        toeColor != oldDelegate.toeColor ||
        outlineColor != oldDelegate.outlineColor ||
        isRightFoot != oldDelegate.isRightFoot;
  }
}

