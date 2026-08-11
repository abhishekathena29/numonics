import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../state/app_state.dart';
import '../models/challenge.dart';
import 'explanation_sheet.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.challenge});
  final Challenge challenge;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  Question get _q => widget.challenge.questions[_index];
  int get _total => widget.challenge.total;

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      if (i == _q.correctIndex) {
        _correct++;
        AppState.instance.recordCorrect(challengeId: widget.challenge.id);
      }
    });
    AppState.instance
        .setChallengeProgress(widget.challenge.id, _index + 1);
  }

  void _next() {
    if (_index < _total - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _finished ? _buildSummary() : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final isCorrect = _selected == _q.correctIndex;
    return Column(
      children: [
        _TopBar(
          progress: (_index + 1) / _total,
          label: '${_index + 1}/$_total',
          onClose: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            children: [
              _MathyBubble(text: _q.prompt),
              if (_q.diagram == Diagram.rightTriangle) ...[
                const SizedBox(height: 20),
                const _RightTriangleDiagram(),
              ],
              const SizedBox(height: 24),
              ...List.generate(_q.options.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OptionTile(
                    letter: String.fromCharCode(65 + i),
                    text: _q.options[i],
                    state: _stateFor(i),
                    onTap: () => _select(i),
                  ),
                );
              }),
            ],
          ),
        ),
        if (_answered)
          _FeedbackBar(
            correct: isCorrect,
            onExplain: () => showExplanationSheet(context, _q),
            onNext: _next,
            isLast: _index == _total - 1,
          ),
      ],
    );
  }

  _OptionState _stateFor(int i) {
    if (!_answered) return _OptionState.idle;
    if (i == _q.correctIndex) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  Widget _buildSummary() {
    final pct = _total == 0 ? 0.0 : _correct / _total;
    final great = pct >= 0.6;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              gradient: AppGradients.hero,
              shape: BoxShape.circle,
            ),
            child: Icon(great ? Icons.emoji_events : Icons.school_rounded,
                size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 26),
          Text(great ? 'Challenge complete!' : 'Nice effort!',
              style: AppText.h1, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'You got $_correct out of $_total correct and earned '
            '${_correct * 10} XP.',
            style: AppText.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          PrimaryButton(
            label: 'Back to home',
            icon: Icons.check,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar(
      {required this.progress, required this.label, required this.onClose});
  final double progress;
  final String label;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          ),
          Expanded(child: ProgressBar(value: progress, height: 10)),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _MathyBubble extends StatelessWidget {
  const _MathyBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: const [
            MathyAvatar(size: 46),
            SizedBox(height: 6),
            Text('Mathy',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(text,
                style: AppText.body
                    .copyWith(color: AppColors.ink, fontSize: 15.5, height: 1.4)),
          ),
        ),
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });
  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    late final Color border;
    late final Color bg;
    late final Color fg;
    switch (state) {
      case _OptionState.idle:
        border = AppColors.stroke;
        bg = AppColors.surface;
        fg = AppColors.ink;
        break;
      case _OptionState.correct:
        border = AppColors.primary;
        bg = AppColors.primaryTint;
        fg = AppColors.primaryDark;
        break;
      case _OptionState.wrong:
        border = AppColors.coral;
        bg = AppColors.coralTint;
        fg = AppColors.coral;
        break;
      case _OptionState.dimmed:
        border = AppColors.stroke;
        bg = AppColors.surface;
        fg = AppColors.inkFaint;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: border,
              width: state == _OptionState.idle || state == _OptionState.dimmed
                  ? 1
                  : 1.8),
        ),
        child: Row(
          children: [
            Text('$letter. ',
                style: TextStyle(
                    color: fg, fontWeight: FontWeight.w800, fontSize: 15)),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: fg, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            if (state == _OptionState.correct)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
            if (state == _OptionState.wrong)
              const Icon(Icons.cancel, color: AppColors.coral, size: 22),
          ],
        ),
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({
    required this.correct,
    required this.onExplain,
    required this.onNext,
    required this.isLast,
  });
  final bool correct;
  final VoidCallback onExplain;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.primary : AppColors.coral;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: (correct ? AppColors.primaryTint : AppColors.coralTint),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(correct ? Icons.celebration : Icons.lightbulb_outline,
                    color: color, size: 24),
                const SizedBox(width: 8),
                Text(correct ? 'Correct' : 'Not quite',
                    style: AppText.h2.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              correct
                  ? "Great job! You're improving fast. Keep it up!"
                  : 'Review the explanation and try the next one.',
              style: AppText.body.copyWith(fontSize: 13.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SoftButton(
                    label: 'Explanation',
                    icon: Icons.lightbulb_outline,
                    expand: true,
                    onPressed: onExplain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: isLast ? 'Finish' : 'Next Question',
                    height: 48,
                    onPressed: onNext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A minimal right-triangle sketch echoing the reference trig question.
class _RightTriangleDiagram extends StatelessWidget {
  const _RightTriangleDiagram();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
      ),
      child: CustomPaint(
        painter: _TrianglePainter(),
        child: const Center(),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pad = 26.0;
    final bl = Offset(pad, size.height - pad);
    final br = Offset(size.width - pad, size.height - pad);
    final top = Offset(size.width - pad, pad);

    final line = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Hypotenuse (rabbit -> eagle)
    canvas.drawLine(bl, top, line);
    // Base (dashed-ish ground) and vertical (height) in a softer tone.
    final soft = Paint()
      ..color = AppColors.inkFaint
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(bl, br, soft);
    canvas.drawLine(br, top, soft);

    // Right-angle marker at bottom-right.
    const m = 12.0;
    final rp = Path()
      ..moveTo(br.dx - m, br.dy)
      ..lineTo(br.dx - m, br.dy - m)
      ..lineTo(br.dx, br.dy - m);
    canvas.drawPath(rp, soft);

    // Labels.
    _text(canvas, '18 m', Offset((bl.dx + top.dx) / 2 - 34, (bl.dy + top.dy) / 2 - 8),
        AppColors.primary);
    _text(canvas, '60°', Offset(bl.dx + 12, bl.dy - 22), AppColors.ink);
    _text(canvas, 'x', Offset(br.dx + 4, (br.dy + top.dy) / 2), AppColors.inkSoft);
  }

  void _text(Canvas canvas, String s, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
