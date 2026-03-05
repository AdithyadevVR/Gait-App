import 'package:flutter/material.dart';
import '../theme/dashboard_theme.dart';
import 'sensor_data_card.dart';

class WarningsPanel extends StatefulWidget {
  final List<String> warnings;

  const WarningsPanel({super.key, required this.warnings});

  @override
  State<WarningsPanel> createState() => _WarningsPanelState();
}

class _WarningsPanelState extends State<WarningsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Green = balanced, Yellow = slight (1-2), Red = strong (3+)
  static (Color, String) _status(List<String> w) {
    if (w.isEmpty) return (DashboardTheme.accentGreen, 'Balanced');
    if (w.length <= 2) return (DashboardTheme.accentYellow, 'Slight imbalance');
    return (DashboardTheme.accentRed, 'Strong imbalance');
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _status(widget.warnings);
    final hasWarnings = widget.warnings.isNotEmpty;

    return SensorDataCard(
      title: 'Gait imbalance',
      subtitle: hasWarnings ? '${widget.warnings.length} alert(s)' : 'No issues',
      icon: hasWarnings ? Icons.warning_amber_rounded : Icons.check_circle_outline,
      trailing: hasWarnings
          ? AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: statusColor.withOpacity(_pulseAnimation.value),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: statusColor,
                    ),
                  ),
                );
              },
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: DashboardTheme.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DashboardTheme.accentGreen,
                ),
              ),
            ),
      child: hasWarnings
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.warnings
                  .map(
                    (msg) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: statusColor,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              msg,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: DashboardTheme.accentGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Gait within normal range',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
