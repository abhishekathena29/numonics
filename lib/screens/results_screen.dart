import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/ascii_view.dart';
import '../math/formulas.dart';
import '../art/pattern_engine.dart';

/// Shows the computed answer, a step-by-step breakdown, and the ASCII pattern
/// the answer draws — swipe to redraw the same answer as any other pattern.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.formula,
    required this.values,
    required this.answer,
  });

  final Formula formula;
  final Map<String, num> values;
  final double answer;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final PageController _page;
  late final int _startIndex;
  late final int _size;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _size = PatternEngine.sizeFor(widget.answer);
    _startIndex = PatternEngine.names.indexOf(
      PatternEngine.patternFor(widget.answer),
    );
    _current = _startIndex;
    _page = PageController(initialPage: _startIndex);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  String get _answerText {
    final a = widget.answer;
    return a == a.roundToDouble()
        ? a.toInt().toString()
        : a.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.formula.steps(widget.values);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Result', style: AppText.h2),
        leading: const BackButton(color: AppColors.ink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          // Answer hero.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text('${widget.formula.display}  =',
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(_answerText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader('How we got there'),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  _StepRow(index: i, text: steps[i], isLast: i == steps.length - 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(
            'Your pattern',
            subtitle: 'The answer drew this. Swipe to redraw it.',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _page,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: PatternEngine.names.length,
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AsciiView(
                    lines: PatternEngine.render(PatternEngine.names[i], _size),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.brush_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${PatternEngine.names[_current]}  ·  size $_size',
                style: AppText.label.copyWith(color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(PatternEngine.names.length, (i) {
              final active = i == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : AppColors.primaryTintStrong,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Solve another',
            icon: Icons.refresh,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow(
      {required this.index, required this.text, required this.isLast});
  final int index;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Text('${index + 1}',
                style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: AppText.mono.copyWith(fontSize: 17, color: AppColors.ink)),
          ),
        ],
      ),
    );
  }
}
