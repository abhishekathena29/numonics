import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../state/app_state.dart';
import '../models/challenge.dart';
import '../data/challenges.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final app = AppState.instance;
        final profile = app.profile;
        final level = profile?.level ?? 1;
        final levelProgress = profile?.levelProgress ?? 0;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Text('Progress', style: AppText.h1),
            const SizedBox(height: 18),
            _LevelCard(level: level, xp: app.xp, progress: levelProgress),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    color: AppColors.amber,
                    value: '${app.streak}',
                    label: 'Day streak',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    color: AppColors.primary,
                    value: '${app.solved}',
                    label: 'Solved',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader('Your challenges'),
            const SizedBox(height: 12),
            for (final c in kChallenges)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(c.icon, color: c.difficulty.color, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: AppText.h2.copyWith(fontSize: 15)),
                            const SizedBox(height: 8),
                            ProgressBar(
                              value: c.total == 0
                                  ? 0
                                  : app.progressFor(c.id) / c.total,
                              color: c.difficulty.color,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${app.progressFor(c.id)}/${c.total}',
                          style: AppText.label),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard(
      {required this.level, required this.xp, required this.progress});
  final int level;
  final int xp;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 26),
              const SizedBox(width: 8),
              Text('Level $level',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('$xp XP',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ProgressBar(
            value: progress,
            height: 10,
            color: Colors.white,
            track: Colors.white.withValues(alpha: 0.28),
          ),
          const SizedBox(height: 8),
          Text('${((1 - progress) * 100).round()} XP to level ${level + 1}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          Text(value, style: AppText.h1),
          const SizedBox(height: 2),
          Text(label, style: AppText.label.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
