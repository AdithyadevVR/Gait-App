import 'package:flutter/material.dart';

class ImuCard extends StatelessWidget {
  final double pitch;
  final double roll;
  final double ax;
  final double ay;
  final double az;
  final double gx;
  final double gy;
  final double gz;

  const ImuCard({
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IMU Deviation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDeviationItem('Forward Tilt', pitch),
                _buildDeviationItem('Side Tilt', roll),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Raw Accel Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRawItem('Ax', ax),
                _buildRawItem('Ay', ay),
                _buildRawItem('Az', az),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Raw Gyro Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRawItem('Gx', gx),
                _buildRawItem('Gy', gy),
                _buildRawItem('Gz', gz),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDeviationItem(String label, double value) {
    // Determine color based on deviation severity
    Color valueColor = Colors.green;
    if (value.abs() > 15) {
      valueColor = Colors.red;
    } else if (value.abs() > 5) {
      valueColor = Colors.orange;
    }

    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(1)}°',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRawItem(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value.toStringAsFixed(3),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
