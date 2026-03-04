import 'package:flutter/material.dart';
import 'sensor_card.dart';

class ImuPanel extends StatelessWidget {
  final double pitch;
  final double roll;
  final double ax;
  final double ay;
  final double az;
  final double gx;
  final double gy;
  final double gz;

  const ImuPanel({
    super.key,
    required this.pitch,
    required this.roll,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SensorCard(
      title: 'Motion & IMU',
      subtitle: 'Orientation, acceleration and angular velocity',
      icon: Icons.sensors,
      trailing: _buildPostureChip(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDeviationTile(
                  context: context,
                  label: 'Pitch',
                  value: pitch,
                  icon: Icons.swap_vert,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeviationTile(
                  context: context,
                  label: 'Roll',
                  value: roll,
                  icon: Icons.swap_horiz,
                  color: Colors.pinkAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Accelerometer (g)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _buildAxisRow(context, 'A', ax, ay, az, accent: Colors.lightBlueAccent),
          const SizedBox(height: 16),
          Text(
            'Gyroscope (°/s)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _buildAxisRow(context, 'G', gx, gy, gz, accent: Colors.amberAccent),
        ],
      ),
    );
  }

  Widget _buildPostureChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tiltMagnitude = (pitch.abs() + roll.abs()) / 2;

    Color chipColor;
    String label;

    if (tiltMagnitude < 5) {
      chipColor = Colors.greenAccent;
      label = 'Stable';
    } else if (tiltMagnitude < 15) {
      chipColor = Colors.orangeAccent;
      label = 'Leaning';
    } else {
      chipColor = Colors.redAccent;
      label = 'At Risk';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: chipColor.withOpacity(0.15),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_pin_circle, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviationTile({
    required BuildContext context,
    required String label,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color valueColor = colorScheme.onSurface;
    if (value.abs() > 15) {
      valueColor = Colors.redAccent;
    } else if (value.abs() > 5) {
      valueColor = Colors.orangeAccent;
    } else {
      valueColor = Colors.greenAccent;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.02),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withOpacity(0.18),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
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
                  '${value.toStringAsFixed(1)}°',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisRow(
    BuildContext context,
    String prefix,
    double x,
    double y,
    double z, {
    required Color accent,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildAxis(String label, double value, Color color) {
      final magnitude = value.abs().clamp(0.0, 1.0);

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$prefix$label',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: magnitude,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.6),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(3),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        buildAxis('x', x, accent),
        const SizedBox(width: 8),
        buildAxis('y', y, accent.withOpacity(0.8)),
        const SizedBox(width: 8),
        buildAxis('z', z, accent.withOpacity(0.6)),
      ],
    );
  }
}

