import 'package:flutter/material.dart';

class StatChips extends StatelessWidget {
  const StatChips({
    super.key,
    required this.xp,
    required this.streak,
    required this.hearts,
    required this.heartsEnabled,
  });

  final int xp;
  final int streak;
  final int hearts;
  final bool heartsEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chip(Icons.bolt, '$xp', Colors.amber.shade700),
        const SizedBox(width: 6),
        _chip(Icons.local_fire_department, '$streak', Colors.orange),
        if (heartsEnabled) ...[
          const SizedBox(width: 6),
          _chip(Icons.favorite, '$hearts', Colors.redAccent),
        ],
      ],
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
