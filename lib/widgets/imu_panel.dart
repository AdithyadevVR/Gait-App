import 'package:flutter/material.dart';
import '../theme/dashboard_theme.dart';
import 'sensor_data_card.dart';

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
    return SensorDataCard(
      title: 'IMU motion',
      subtitle: 'Orientation, acceleration, gyroscope',
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
                  color: DashboardTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeviationTile(
                  context: context,
                  label: 'Roll',
                  value: roll,
                  icon: Icons.swap_horiz,
                  color: DashboardTheme.accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Accelerometer (g)',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          _buildAxisRow(context, 'A', ax, ay, az, accent: DashboardTheme.accentCyan),
          const SizedBox(height: 16),
          Text(
            'Gyroscope (°/s)',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          _buildAxisRow(context, 'G', gx, gy, gz, accent: DashboardTheme.accentYellow),
        ],
      ),
    );
  }

  Widget _buildPostureChip(BuildContext context) {
    final tiltMagnitude = (pitch.abs() + roll.abs()) / 2;
    Color chipColor;
    String label;
    if (tiltMagnitude < 5) {
      chipColor = DashboardTheme.accentGreen;
      label = 'Stable';
    } else if (tiltMagnitude < 15) {
      chipColor = DashboardTheme.accentYellow;
      label = 'Leaning';
    } else {
      chipColor = DashboardTheme.accentRed;
      label = 'At Risk';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: chipColor.withOpacity(0.2),
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
              fontSize: 10,
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
    Color valueColor = DashboardTheme.accentGreen;
    if (value.abs() > 15) valueColor = DashboardTheme.accentRed;
    else if (value.abs() > 5) valueColor = DashboardTheme.accentYellow;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withOpacity(0.2),
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
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.1,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${value.toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontSize: 20,
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
    Widget buildAxis(String label, double value, Color color) {
      final magnitude = value.abs().clamp(0.0, 1.0);
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$prefix$label',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: magnitude,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(3),
              style: TextStyle(
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: Colors.white.withOpacity(0.8),
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

