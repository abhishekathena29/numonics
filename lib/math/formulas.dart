import 'parser.dart';

/// A solvable formula: a human display, the parseable expression, and the
/// variables the user supplies.
class Formula {
  const Formula({
    required this.id,
    required this.display,
    required this.expression,
    required this.vars,
    required this.blurb,
  });

  final String id;
  final String display; // e.g. 'a² + b²'
  final String expression; // e.g. 'a^2 + b^2'
  final List<String> vars; // e.g. ['a', 'b']
  final String blurb;

  double evaluate(Map<String, num> values) =>
      ExpressionParser(expression).evaluate(values);

  /// A short, readable "how we got there" breakdown for the results screen.
  List<String> steps(Map<String, num> values) {
    String sub = display;
    values.forEach((k, v) {
      sub = sub.replaceAll(k, _fmt(v));
    });
    final result = evaluate(values);
    return [
      display, // the formula
      sub, // with numbers substituted
      '= ${_fmt(result)}', // the answer
    ];
  }

  static String _fmt(num v) {
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toInt().toString();
    return d.toStringAsFixed(2);
  }
}

const List<Formula> kFormulas = [
  Formula(
    id: 'sum_of_squares',
    display: 'a² + b²',
    expression: 'a^2 + b^2',
    vars: ['a', 'b'],
    blurb: 'Square each number, then add them together.',
  ),
  Formula(
    id: 'difference_of_squares',
    display: 'a² − b²',
    expression: 'a^2 - b^2',
    vars: ['a', 'b'],
    blurb: 'Square each number, then subtract the second from the first.',
  ),
  Formula(
    id: 'multiply_add',
    display: 'a × b + c',
    expression: 'a * b + c',
    vars: ['a', 'b', 'c'],
    blurb: 'Multiplication happens before addition (order of operations).',
  ),
  Formula(
    id: 'square_of_sum',
    display: '(a + b)²',
    expression: '(a + b)^2',
    vars: ['a', 'b'],
    blurb: 'Add first because of the brackets, then square the result.',
  ),
];
