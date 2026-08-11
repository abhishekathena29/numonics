import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/challenge.dart';

Future<void> showExplanationSheet(BuildContext context, Question q) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _ExplanationSheet(q: q),
  );
}

class _ExplanationSheet extends StatelessWidget {
  const _ExplanationSheet({required this.q});
  final Question q;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scroll) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.stroke,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note,
                          color: AppColors.primary, size: 26),
                      const SizedBox(width: 8),
                      const Text('Explanation', style: AppText.h1),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 3,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(q.prompt,
                      style: AppText.body
                          .copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primaryTintStrong),
                    ),
                    child: Text(
                      q.explanation,
                      style: AppText.body.copyWith(
                          color: AppColors.ink, fontSize: 15.5, height: 1.55),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The correct answer is ${q.options[q.correctIndex]}.',
                          style: AppText.body.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
