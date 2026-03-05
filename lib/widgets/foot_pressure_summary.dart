import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/dashboard_theme.dart';
import 'sensor_data_card.dart';

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
    return SensorDataCard(
      title: 'Pressure distribution',
      subtitle: 'Total load and balance',
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
                  DashboardTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPressureTile(
                  context,
                  'Right',
                  rightPressure,
                  rightPressurePercent,
                  DashboardTheme.accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pressure percentage',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
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
                    color: DashboardTheme.accentCyan.withOpacity(0.9),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                ),
              ),
              Expanded(
                flex: (rightPressurePercent * 100).round().clamp(1, 99),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: DashboardTheme.accentPurple.withOpacity(0.9),
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
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.6)),
              ),
              Text(
                'Right ${(rightPressurePercent * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.6)),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: DashboardTheme.surfaceCard.withOpacity(0.6),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label pressure',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 4),
          Text(
            '${pressureKg.toStringAsFixed(2)} kg',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percent * 100).toStringAsFixed(1)}% of total',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
