import 'package:flutter/material.dart';

class PressureCard extends StatelessWidget {
  final String title;
  final double heelKg;
  final double ballKg;
  final double toeKg;

  const PressureCard({
    super.key,
    required this.title,
    required this.heelKg,
    required this.ballKg,
    required this.toeKg,
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
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildRow('Toe', toeKg),
            _buildRow('Ball', ballKg),
            _buildRow('Heel', heelKg),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          Text(
            '${value.toStringAsFixed(2)} kg',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
