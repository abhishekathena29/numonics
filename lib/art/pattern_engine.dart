/// Procedural, scalable ASCII-art patterns.
///
/// The signature idea of Numonics: a solved answer both *selects* a pattern
/// and *sizes* it — so doing math literally draws a picture. Every generator
/// is pure and returns a rectangular grid of equal-length lines.
class PatternEngine {
  PatternEngine._();

  static const List<String> names = [
    'Diamond',
    'Pyramid',
    'Heart',
    'Bullseye',
    'Sunburst',
    'Spiral',
    'Checkerboard',
    'Wave',
    'Cross',
    'Chevron',
    'Lattice',
    'Blossom',
  ];

  /// Map an answer to a drawing size (grid radius), kept in a pleasant range.
  static int sizeFor(num answer) {
    final a = answer.abs().round();
    return 3 + (a % 8); // 3..10
  }

  /// The answer picks which pattern to draw.
  static String patternFor(num answer) {
    final a = answer.abs().round();
    return names[a % names.length];
  }

  /// Render a named pattern at the given size. Returns grid lines.
  static List<String> render(String name, int size) {
    final n = size.clamp(3, 12);
    switch (name) {
      case 'Diamond':
        return _diamond(n);
      case 'Pyramid':
        return _pyramid(n);
      case 'Heart':
        return _heart(n);
      case 'Bullseye':
        return _bullseye(n);
      case 'Sunburst':
        return _sunburst(n);
      case 'Spiral':
        return _spiral(n);
      case 'Checkerboard':
        return _checkerboard(n);
      case 'Wave':
        return _wave(n);
      case 'Cross':
        return _cross(n);
      case 'Chevron':
        return _chevron(n);
      case 'Lattice':
        return _lattice(n);
      case 'Blossom':
        return _blossom(n);
      default:
        return _diamond(n);
    }
  }

  // --- helpers -----------------------------------------------------------

  static List<String> _grid(int w, int h, String Function(int r, int c) cell) {
    return List.generate(h, (r) {
      final b = StringBuffer();
      for (var c = 0; c < w; c++) {
        b.write(cell(r, c));
      }
      return b.toString();
    });
  }

  // --- patterns ----------------------------------------------------------

  static List<String> _diamond(int n) {
    final w = 2 * n - 1;
    return _grid(w, w, (r, c) {
      final dist = (r - (n - 1)).abs() + (c - (n - 1)).abs();
      return dist <= n - 1 ? '● ' : '  ';
    });
  }

  static List<String> _pyramid(int n) {
    final w = 2 * n - 1;
    return List.generate(n, (r) {
      final b = StringBuffer();
      for (var c = 0; c < w; c++) {
        b.write((c >= n - 1 - r && c <= n - 1 + r) ? '▲ ' : '  ');
      }
      return b.toString();
    });
  }

  static List<String> _heart(int n) {
    // The classic implicit heart curve: (x²+y²−1)³ − x²y³ ≤ 0.
    final w = 2 * n + 1;
    final h = 2 * n + 1;
    return _grid(w, h, (r, c) {
      final x = (c - n) / (n * 0.92);
      final y = (n - r) / (n * 0.92) + 0.32;
      final a = x * x + y * y - 1;
      final f = a * a * a - x * x * y * y * y;
      return f <= 0 ? '❤ ' : '  ';
    });
  }

  static List<String> _bullseye(int n) {
    final w = 2 * n - 1;
    return _grid(w, w, (r, c) {
      final ring = ((r - (n - 1)).abs() > (c - (n - 1)).abs())
          ? (r - (n - 1)).abs()
          : (c - (n - 1)).abs();
      return ring.isEven ? '▓ ' : '░ ';
    });
  }

  static List<String> _sunburst(int n) {
    final w = 2 * n - 1;
    final cx = n - 1;
    return _grid(w, w, (r, c) {
      final dr = r - cx, dc = c - cx;
      final onAxis = dr == 0 || dc == 0 || dr == dc || dr == -dc;
      return onAxis ? '✦ ' : '  ';
    });
  }

  static List<String> _spiral(int n) {
    final w = 2 * n - 1;
    // Square spiral by ring parity, opened on one side each ring.
    return _grid(w, w, (r, c) {
      final ring = [
        r,
        c,
        w - 1 - r,
        w - 1 - c,
      ].reduce((a, b) => a < b ? a : b);
      final onRing = r == ring ||
          c == ring ||
          r == w - 1 - ring ||
          c == w - 1 - ring;
      final gap = (r == ring && c == ring + 1); // small opening
      return (onRing && !gap) ? '▪ ' : '  ';
    });
  }

  static List<String> _checkerboard(int n) {
    final w = 2 * n;
    return _grid(w, w, (r, c) => (r + c).isEven ? '■ ' : '□ ');
  }

  static List<String> _wave(int n) {
    final w = 2 * n + 2;
    final h = n + 2;
    // A triangular wave crossing the band.
    List<int> heights = List.generate(w, (c) {
      final period = n;
      final t = c % (2 * period);
      return (t < period ? t : 2 * period - t);
    });
    return _grid(w, h, (r, c) {
      return (h - 1 - r) == heights[c] % h ? '～ ' : '  ';
    });
  }

  static List<String> _cross(int n) {
    final w = 2 * n - 1;
    final arm = n ~/ 2;
    final cx = n - 1;
    return _grid(w, w, (r, c) {
      final onBar = (r - cx).abs() <= arm || (c - cx).abs() <= arm;
      final vertical = (c - cx).abs() <= arm;
      final horizontal = (r - cx).abs() <= arm;
      return (vertical || horizontal) && onBar ? '✚ ' : '  ';
    });
  }

  static List<String> _chevron(int n) {
    final w = 2 * n - 1;
    return _grid(w, n, (r, c) {
      final left = c == r;
      final right = c == w - 1 - r;
      return (left || right) ? '◆ ' : '  ';
    });
  }

  static List<String> _lattice(int n) {
    final w = 2 * n;
    return _grid(w, w, (r, c) => (r.isEven || c.isEven) ? '＋' : '  ');
  }

  static List<String> _blossom(int n) {
    final w = 2 * n - 1;
    final cx = n - 1;
    return _grid(w, w, (r, c) {
      final dr = r - cx, dc = c - cx;
      final d = dr * dr + dc * dc;
      final petal = d <= (n - 1) * (n - 1) &&
          d >= ((n - 1) * (n - 1)) ~/ 4;
      final core = d < ((n - 1) * (n - 1)) ~/ 6;
      if (core) return '❁ ';
      return petal ? '✿ ' : '  ';
    });
  }
}
