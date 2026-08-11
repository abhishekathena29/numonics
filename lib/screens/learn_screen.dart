import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/ascii_view.dart';
import '../art/pattern_engine.dart';

class _Lesson {
  const _Lesson(this.title, this.summary, this.body);
  final String title;
  final String summary;
  final String body;
}

const _lessons = [
  _Lesson(
    'Squaring a number',
    'What a² really means',
    'To square a number you multiply it by itself. So a² = a × a. '
        'For example 5² = 5 × 5 = 25. Squares grow quickly — that is why they '
        'make dramatic changes in the patterns you draw.',
  ),
  _Lesson(
    'Sum of squares',
    'a² + b²',
    'Square each number on its own, then add the two results. '
        'For a = 3 and b = 4: 3² + 4² = 9 + 16 = 25. This is also the heart of '
        'the Pythagorean theorem, c² = a² + b².',
  ),
  _Lesson(
    'Difference of squares',
    'a² − b²',
    'Square both numbers, then subtract the second from the first: '
        'a² − b². For a = 6 and b = 2: 36 − 4 = 32. It also factors neatly as '
        '(a + b)(a − b).',
  ),
  _Lesson(
    'Order of operations',
    'Why a × b + c is not (a × b) then guesswork',
    'Operations follow a set order: brackets first, then powers, then '
        'multiply/divide, then add/subtract. In a × b + c you multiply before '
        'you add. For a = 4, b = 5, c = 2: 4 × 5 + 2 = 20 + 2 = 22.',
  ),
  _Lesson(
    'Square of a sum',
    '(a + b)²',
    'The brackets come first, so add before you square: (a + b)². '
        'For a = 2 and b = 3: (2 + 3)² = 5² = 25. Expanded, it equals '
        'a² + 2ab + b².',
  ),
];

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Lessons', style: AppText.h2),
        leading: const BackButton(color: AppColors.ink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text('Bite-size math', style: AppText.h1.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text('Quick refreshers behind every formula you can draw.',
              style: AppText.body.copyWith(fontSize: 13.5)),
          const SizedBox(height: 18),
          for (final l in _lessons) ...[
            _LessonTile(lesson: l),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          const SectionHeader('Pattern gallery',
              subtitle: 'Every shape an answer can draw.'),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
            children: [
              for (final name in PatternEngine.names)
                _GalleryCard(name: name),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});
  final _Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.inkFaint,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: AppColors.primary, size: 20),
          ),
          title: Text(lesson.title, style: AppText.h2.copyWith(fontSize: 15.5)),
          subtitle: Text(lesson.summary,
              style: AppText.body.copyWith(fontSize: 12.5)),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(lesson.body,
                  style: AppText.body.copyWith(fontSize: 14, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: AsciiView(
              lines: PatternEngine.render(name, 4),
              background: AppColors.surface,
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: AppText.label.copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }
}
