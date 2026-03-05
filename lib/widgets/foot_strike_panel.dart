import 'package:flutter/material.dart';
import 'sensor_card.dart';

class FootStrikePanel extends StatelessWidget {
  final double leftHeelRatio;
  final double leftBallRatio;
  final double leftToeRatio;
  final double rightHeelRatio;
  final double rightBallRatio;
  final double rightToeRatio;

  const FootStrikePanel({
    super.key,
    required this.leftHeelRatio,
    required this.leftBallRatio,
    required this.leftToeRatio,
    required this.rightHeelRatio,
    required this.rightBallRatio,
    required this.rightToeRatio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SensorCard(
      title: 'Foot Strike Analysis',
      subtitle: 'Heel, ball and toe distribution',
      icon: Icons.grain,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFootRatios(
                  context,
                  'Left',
                  leftHeelRatio,
                  leftBallRatio,
                  leftToeRatio,
                  Colors.cyanAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFootRatios(
                  context,
                  'Right',
                  rightHeelRatio,
                  rightBallRatio,
                  rightToeRatio,
                  Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFootRatios(
    BuildContext context,
    String label,
    double heelRatio,
    double ballRatio,
    double toeRatio,
    Color accent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget ratioRow(String name, double value, Color color) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface.withOpacity(0.6),
        border: Border.all(color: accent.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.1,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ratioRow('Heel ratio', heelRatio, Colors.deepPurpleAccent),
          ratioRow('Ball ratio', ballRatio, Colors.tealAccent),
          ratioRow('Toe ratio', toeRatio, Colors.orangeAccent),
        ],
      ),
    );
  }
}
