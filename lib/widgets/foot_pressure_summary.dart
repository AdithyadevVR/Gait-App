import 'package:flutter/material.dart';
import 'sensor_card.dart';

class FootPressureSummary extends StatelessWidget {
  final double leftPressure;
  final double rightPressure;
  final double leftPressurePercent;
  final double rightPressurePercent;

  const FootPressureSummary({
    super.key,
    required this.leftPressure,
    required this.rightPressure,
    required this.leftPressurePercent,
    required this.rightPressurePercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SensorCard(
      title: 'Foot Pressure',
      subtitle: 'Total load and distribution',
      icon: Icons.balance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPressureTile(
                  context,
                  'Left',
                  leftPressure,
                  leftPressurePercent,
                  Colors.cyanAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPressureTile(
                  context,
                  'Right',
                  rightPressure,
                  rightPressurePercent,
                  Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pressure percentage',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: (leftPressurePercent * 100).round().clamp(1, 99),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.8),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                ),
              ),
              Expanded(
                flex: (rightPressurePercent * 100).round().clamp(1, 99),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.8),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Left ${(leftPressurePercent * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Right ${(rightPressurePercent * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPressureTile(
    BuildContext context,
    String label,
    double pressureKg,
    double percent,
    Color accent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            '$label pressure',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${pressureKg.toStringAsFixed(2)} kg',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percent * 100).toStringAsFixed(1)}% of total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
