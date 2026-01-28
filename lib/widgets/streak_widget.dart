import 'package:flutter/material.dart';
import '../services/gamification_service.dart';

class StreakWidget extends StatelessWidget {
  final GamificationService _gamificationService = GamificationService();

  StreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _gamificationService.gamificationStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final streak = data['streak'] ?? 0;
        final lives = data['lives'] ?? 3;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Streak Icon and Count
              const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Lives Icon and Count
              const Icon(
                Icons.favorite_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '$lives',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
