import 'package:flutter/material.dart';
import 'sensor_card.dart';

class WarningsPanel extends StatelessWidget {
  final List<String> warnings;

  const WarningsPanel({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SensorCard(
      title: 'Warnings',
      subtitle: warnings.isEmpty ? 'No issues detected' : 'Gait alerts',
      icon: Icons.warning_amber_rounded,
      trailing: warnings.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${warnings.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
              ),
            )
          : null,
      child: warnings.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Gait within normal range',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: warnings
                  .map(
                    (msg) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orangeAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              msg,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
