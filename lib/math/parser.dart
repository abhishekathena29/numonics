/// A tiny arithmetic expression parser: tokenizer → shunting-yard → RPN
/// evaluator. Supports + - * / ^, parentheses, unary minus, decimals and
/// single-letter variables (a, b, c, …) supplied at evaluation time.
///
/// Pure Dart, no dependencies — so the whole feature builds offline.
class ExpressionParser {
  ExpressionParser(this.source);
  final String source;

  static const _precedence = {'+': 1, '-': 1, '*': 2, '/': 2, '^': 3};
  static const _rightAssoc = {'^'};

  /// Evaluate the expression with the given variable values.
  double evaluate(Map<String, num> vars) {
    final rpn = _toRpn(_tokenize());
    final stack = <double>[];
    for (final t in rpn) {
      switch (t.type) {
        case _TokType.number:
          stack.add(t.value!);
          break;
        case _TokType.variable:
          final v = vars[t.text];
          if (v == null) {
            throw FormatException('Unknown variable "${t.text}"');
          }
          stack.add(v.toDouble());
          break;
        case _TokType.op:
          final b = stack.removeLast();
          final a = stack.removeLast();
          stack.add(_apply(t.text, a, b));
          break;
        default:
          throw const FormatException('Malformed expression');
      }
    }
    if (stack.length != 1) throw const FormatException('Malformed expression');
    return stack.single;
  }

  double _apply(String op, double a, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return a / b;
      case '^':
        return _pow(a, b);
    }
    throw FormatException('Unknown operator "$op"');
  }

  double _pow(double a, double b) {
    // Integer exponents are the common case (squared terms); do them exactly.
    if (b == b.roundToDouble()) {
      var result = 1.0;
      final n = b.toInt().abs();
      for (var i = 0; i < n; i++) {
        result *= a;
      }
      return b < 0 ? 1 / result : result;
    }
    // Fall back for the rare fractional exponent.
    return _expApprox(b * _ln(a));
  }

  // Small self-contained exp/ln so we avoid dart:math (keeps the engine pure).
  double _ln(double x) {
    if (x <= 0) return double.nan;
    var y = (x - 1) / (x + 1);
    final y2 = y * y;
    var term = y, sum = 0.0;
    for (var k = 1; k < 60; k += 2) {
      sum += term / k;
      term *= y2;
    }
    return 2 * sum;
  }

  double _expApprox(double x) {
    var term = 1.0, sum = 1.0;
    for (var n = 1; n < 60; n++) {
      term *= x / n;
      sum += term;
    }
    return sum;
  }

  List<_Token> _tokenize() {
    final tokens = <_Token>[];
    var i = 0;
    _TokType? prev;
    while (i < source.length) {
      final ch = source[i];
      if (ch.trim().isEmpty) {
        i++;
        continue;
      }
      if (_isDigit(ch) || ch == '.') {
        final start = i;
        while (i < source.length &&
            (_isDigit(source[i]) || source[i] == '.')) {
          i++;
        }
        tokens.add(_Token.number(double.parse(source.substring(start, i))));
        prev = _TokType.number;
        continue;
      }
      if (_isLetter(ch)) {
        tokens.add(_Token.variable(ch));
        prev = _TokType.variable;
        i++;
        continue;
      }
      if (ch == '(') {
        tokens.add(_Token.lparen());
        prev = _TokType.lparen;
        i++;
        continue;
      }
      if (ch == ')') {
        tokens.add(_Token.rparen());
        prev = _TokType.rparen;
        i++;
        continue;
      }
      if ('+-*/^'.contains(ch)) {
        // Unary minus: a leading '-' or one after an operator / '(' becomes 0 - x.
        if (ch == '-' &&
            (prev == null || prev == _TokType.op || prev == _TokType.lparen)) {
          tokens.add(_Token.number(0));
        }
        tokens.add(_Token.op(ch));
        prev = _TokType.op;
        i++;
        continue;
      }
      throw FormatException('Unexpected character "$ch"');
    }
    return tokens;
  }

  List<_Token> _toRpn(List<_Token> tokens) {
    final output = <_Token>[];
    final ops = <_Token>[];
    for (final t in tokens) {
      switch (t.type) {
        case _TokType.number:
        case _TokType.variable:
          output.add(t);
          break;
        case _TokType.op:
          while (ops.isNotEmpty && ops.last.type == _TokType.op) {
            final top = ops.last.text;
            final higher = _precedence[top]! > _precedence[t.text]!;
            final equalLeft = _precedence[top]! == _precedence[t.text]! &&
                !_rightAssoc.contains(t.text);
            if (higher || equalLeft) {
              output.add(ops.removeLast());
            } else {
              break;
            }
          }
          ops.add(t);
          break;
        case _TokType.lparen:
          ops.add(t);
          break;
        case _TokType.rparen:
          while (ops.isNotEmpty && ops.last.type != _TokType.lparen) {
            output.add(ops.removeLast());
          }
          if (ops.isEmpty) throw const FormatException('Mismatched parentheses');
          ops.removeLast();
          break;
      }
    }
    while (ops.isNotEmpty) {
      if (ops.last.type == _TokType.lparen) {
        throw const FormatException('Mismatched parentheses');
      }
      output.add(ops.removeLast());
    }
    return output;
  }

  static bool _isDigit(String c) {
    final u = c.codeUnitAt(0);
    return u >= 0x30 && u <= 0x39;
  }

  static bool _isLetter(String c) {
    final u = c.toLowerCase().codeUnitAt(0);
    return u >= 0x61 && u <= 0x7a;
  }
}

enum _TokType { number, variable, op, lparen, rparen }

class _Token {
  _Token(this.type, this.text, this.value);
  _Token.number(double v) : this(_TokType.number, v.toString(), v);
  _Token.variable(String name) : this(_TokType.variable, name, null);
  _Token.op(String op) : this(_TokType.op, op, null);
  _Token.lparen() : this(_TokType.lparen, '(', null);
  _Token.rparen() : this(_TokType.rparen, ')', null);

  final _TokType type;
  final String text;
  final double? value;
}
