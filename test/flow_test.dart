import 'package:flutter_test/flutter_test.dart';

import 'package:numonics/data/challenges.dart';
import 'package:numonics/models/user_profile.dart';
import 'package:numonics/math/parser.dart';
import 'package:numonics/math/formulas.dart';
import 'package:numonics/art/pattern_engine.dart';

void main() {
  test('parser handles squared terms and order of operations', () {
    expect(ExpressionParser('a^2 + b^2').evaluate({'a': 3, 'b': 4}), 25);
    expect(ExpressionParser('a^2 - b^2').evaluate({'a': 6, 'b': 2}), 32);
    expect(ExpressionParser('a * b + c').evaluate({'a': 4, 'b': 5, 'c': 2}), 22);
    expect(ExpressionParser('(a + b)^2').evaluate({'a': 2, 'b': 3}), 25);
    expect(ExpressionParser('-a + 10').evaluate({'a': 3}), 7); // unary minus
  });

  test('every formula evaluates and produces a 3-line breakdown', () {
    for (final f in kFormulas) {
      final vals = {for (final v in f.vars) v: 3};
      expect(() => f.evaluate(vals), returnsNormally);
      expect(f.steps(vals).length, 3);
    }
  });

  test('pattern engine renders every named pattern as a non-empty grid', () {
    for (final name in PatternEngine.names) {
      final lines = PatternEngine.render(name, 6);
      expect(lines, isNotEmpty, reason: '$name produced no lines');
      expect(lines.every((l) => l.isNotEmpty), isTrue,
          reason: '$name produced an empty line');
    }
    // Selection + sizing stay in range for a spread of answers.
    for (final a in [0, 5, 25, 99, 144]) {
      expect(PatternEngine.names.contains(PatternEngine.patternFor(a)), isTrue);
      expect(PatternEngine.sizeFor(a), inInclusiveRange(3, 12));
    }
  });

  test('every challenge question is well-formed', () {
    expect(kChallenges, isNotEmpty);
    for (final c in kChallenges) {
      expect(c.questions, isNotEmpty, reason: '${c.title} has no questions');
      for (final q in c.questions) {
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
            reason: 'bad correctIndex in "${q.prompt}"');
        expect(q.explanation.trim(), isNotEmpty);
      }
    }
  });

  test('UserProfile.fromMap parses fields and derives level', () {
    final p = UserProfile.fromMap('u1', {
      'name': 'Ada',
      'email': 'ada@math.io',
      'xp': 250,
      'streak': 4,
      'solved': 12,
    });
    expect(p.name, 'Ada');
    expect(p.email, 'ada@math.io');
    expect(p.xp, 250);
    expect(p.level, 3); // 250 XP -> level 3
    expect(p.levelProgress, closeTo(0.5, 0.001));
  });

  test('UserProfile.fromMap tolerates missing/blank fields', () {
    final p = UserProfile.fromMap('u2', {});
    expect(p.name, 'Explorer');
    expect(p.xp, 0);
    expect(p.level, 1);
  });
}
