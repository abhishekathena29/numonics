import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../state/app_state.dart';
import '../models/challenge.dart';
import '../data/challenges.dart';
import 'quiz_screen.dart';
import 'solve_screen.dart';
import 'learn_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final app = AppState.instance;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _Greeting(name: app.name, streak: app.streak),
            const SizedBox(height: 18),
            _StreakStrip(streak: app.streak),
            const SizedBox(height: 24),
            // Signature features headline the home screen.
            _SolveHero(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SolveScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _ExploreCard(
              icon: Icons.menu_book_rounded,
              title: 'Lessons',
              subtitle: 'Bite-size refreshers + pattern gallery.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LearnScreen()),
              ),
            ),
            const SizedBox(height: 28),
            SectionHeader(
              'Daily Challenge',
              subtitle: 'Keep your streak alive with a quick set.',
            ),
            const SizedBox(height: 14),
            _ChallengeGrid(
              onOpen: (c) => _openChallenge(context, c),
            ),
          ],
        );
      },
    );
  }

  void _openChallenge(BuildContext context, Challenge c) {
    if (c.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete earlier challenges to unlock this.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizScreen(challenge: c)),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.streak});
  final String name;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello $name', style: AppText.h1),
              const SizedBox(height: 4),
              Text('Complete the daily set and earn extra XP!',
                  style: AppText.body.copyWith(fontSize: 13.5)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$streak',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
              const SizedBox(width: 5),
              const Icon(Icons.local_fire_department,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakStrip extends StatelessWidget {
  const _StreakStrip({required this.streak});
  final int streak;

  static const _days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed'];

  @override
  Widget build(BuildContext context) {
    // Highlight today (index 1 to echo the reference) and fill earned days.
    const today = 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_days.length, (i) {
        final earned = i <= today && i < streak + 1;
        final isToday = i == today;
        return Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary
                    : earned
                        ? AppColors.primaryTint
                        : AppColors.fill,
                shape: BoxShape.circle,
                border: isToday
                    ? null
                    : Border.all(color: AppColors.stroke),
              ),
              child: Icon(
                Icons.favorite,
                size: 20,
                color: isToday
                    ? Colors.white
                    : earned
                        ? AppColors.primary
                        : AppColors.inkFaint,
              ),
            ),
            const SizedBox(height: 6),
            Text(_days[i],
                style: AppText.label.copyWith(
                    fontSize: 12,
                    color: isToday ? AppColors.primary : AppColors.inkFaint)),
          ],
        );
      }),
    );
  }
}

/// The signature feature, front and centre: turn equations into scalable art.
class _SolveHero extends StatelessWidget {
  const _SolveHero({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('SIGNATURE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                ),
                const Spacer(),
                const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Solve & Draw',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4)),
            const SizedBox(height: 6),
            Text('Turn any equation into scalable ASCII art — math that draws.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                    height: 1.4)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Start solving',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeGrid extends StatelessWidget {
  const _ChallengeGrid({required this.onOpen});
  final ValueChanged<Challenge> onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.86,
      children: [
        for (final c in kChallenges)
          _ChallengeCard(
            challenge: c,
            onTap: () => onOpen(c),
          ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h2.copyWith(fontSize: 16)),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.body.copyWith(fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.inkFaint),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.onTap});
  final Challenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = AppState.instance.progressFor(challenge.id);
    final diff = challenge.difficulty;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(text: diff.label, color: diff.color),
          const SizedBox(height: 12),
          Text(challenge.title,
              style: AppText.h2.copyWith(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$done/${challenge.total}',
                  style: AppText.label.copyWith(color: AppColors.inkSoft)),
              Icon(challenge.icon, color: diff.color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(
            value: challenge.total == 0 ? 0 : done / challenge.total,
            color: diff.color,
          ),
        ],
      ),
    );
  }
}
