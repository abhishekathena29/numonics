import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../state/app_state.dart';
import '../models/challenge.dart';
import '../data/challenges.dart';
import 'quiz_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Text('Courses', style: AppText.h1),
            const SizedBox(height: 4),
            Text('Pick a topic and practice at your own pace.',
                style: AppText.body.copyWith(fontSize: 13.5)),
            const SizedBox(height: 20),
            for (final c in kChallenges) ...[
              _CourseRow(
                challenge: c,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => QuizScreen(challenge: c)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({required this.challenge, required this.onTap});
  final Challenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = AppState.instance.progressFor(challenge.id);
    final diff = challenge.difficulty;
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: diff.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(challenge.icon, color: diff.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title, style: AppText.h2.copyWith(fontSize: 16)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Pill(text: diff.label, color: diff.color),
                    const SizedBox(width: 8),
                    Text('$done/${challenge.total}',
                        style: AppText.label.copyWith(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                ProgressBar(
                  value: challenge.total == 0 ? 0 : done / challenge.total,
                  color: diff.color,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.inkFaint),
        ],
      ),
    );
  }
}
