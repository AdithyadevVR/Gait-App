import 'package:flutter/material.dart';
import 'sensor_card.dart';

class GaitMetricsPanel extends StatelessWidget {
  final int leftStepCount;
  final int rightStepCount;
  final double leftStepTime;
  final double rightStepTime;
  final double leftCadence;
  final double rightCadence;
  final double stepSymmetry;

  const GaitMetricsPanel({
    super.key,
    required this.leftStepCount,
    required this.rightStepCount,
    required this.leftStepTime,
    required this.rightStepTime,
    required this.leftCadence,
    required this.rightCadence,
    this.stepSymmetry = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalSteps = leftStepCount + rightStepCount;
    final avgCadence = totalSteps == 0
        ? 0.0
        : (leftCadence + rightCadence) / 2.0;

    return SensorCard(
      title: 'Gait Metrics',
      subtitle: 'Step symmetry, cadence and timing',
      icon: Icons.insights,
      trailing: _buildSummaryChip(context, totalSteps, avgCadence),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  label: 'Left',
                  steps: leftStepCount,
                  stepTime: leftStepTime,
                  cadence: leftCadence,
                  accent: Colors.cyanAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  label: 'Right',
                  steps: rightStepCount,
                  stepTime: rightStepTime,
                  cadence: rightCadence,
                  accent: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Step symmetry',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.timelapse, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Timing difference: ${stepSymmetry.toStringAsFixed(2)} s',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Step count distribution',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _buildSymmetryBar(context),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context,
    int totalSteps,
    double avgCadence,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.primaryContainer.withOpacity(0.2),
        border: Border.all(
          color: colorScheme.primaryContainer.withOpacity(0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_run, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$totalSteps steps • ${avgCadence.toStringAsFixed(0)} spm',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String label,
    required int steps,
    required double stepTime,
    required double cadence,
    required Color accent,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface.withOpacity(0.6),
        border: Border.all(color: accent.withOpacity(0.7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 28,
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
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.1,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric(
                context,
                'Steps',
                steps.toString(),
              ),
              _buildMiniMetric(
                context,
                'Step time',
                stepTime <= 0 ? '—' : '${stepTime.toStringAsFixed(2)} s',
              ),
              _buildMiniMetric(
                context,
                'Cadence',
                cadence <= 0 ? '—' : '${cadence.toStringAsFixed(0)} spm',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSymmetryBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalSteps = leftStepCount + rightStepCount;
    final leftRatio = totalSteps == 0 ? 0.5 : leftStepCount / totalSteps;
    final rightRatio = 1 - leftRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Expanded(
                  flex: (leftRatio * 1000).round(),
                  child: Container(
                    color: Colors.cyanAccent.withOpacity(0.85),
                  ),
                ),
                Expanded(
                  flex: (rightRatio * 1000).round(),
                  child: Container(
                    color: Colors.deepPurpleAccent.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Left ${(leftRatio * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Right ${(rightRatio * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

