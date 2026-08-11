import 'package:flutter/material.dart';
import '../theme.dart';

enum Difficulty { beginner, intermediate, advanced }

extension DifficultyMeta on Difficulty {
  String get label => switch (this) {
        Difficulty.beginner => 'Beginner Challenge',
        Difficulty.intermediate => 'Intermediate Challenge',
        Difficulty.advanced => 'Advanced Challenge',
      };

  Color get color => switch (this) {
        Difficulty.beginner => AppColors.primary,
        Difficulty.intermediate => AppColors.amber,
        Difficulty.advanced => AppColors.coral,
      };
}

/// An optional diagram to render above a question (e.g. the right triangle in
/// the trigonometry example).
enum Diagram { none, rightTriangle }

class Question {
  const Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.diagram = Diagram.none,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final Diagram diagram;
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.icon,
    required this.questions,
    this.locked = false,
  });

  final String id;
  final String title;
  final Difficulty difficulty;
  final IconData icon;
  final List<Question> questions;
  final bool locked;

  int get total => questions.length;
}
