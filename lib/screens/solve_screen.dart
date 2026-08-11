import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../math/formulas.dart';
import '../art/pattern_engine.dart';
import '../widgets/ascii_view.dart';
import 'results_screen.dart';

/// Numonics' signature creative tool: pick a formula, enter numbers, and the
/// answer draws a scalable ASCII pattern.
class SolveScreen extends StatefulWidget {
  const SolveScreen({super.key});

  @override
  State<SolveScreen> createState() => _SolveScreenState();
}

class _SolveScreenState extends State<SolveScreen> {
  Formula _formula = kFormulas.first;
  final Map<String, TextEditingController> _controllers = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  void _syncControllers() {
    // Seed each variable with a small default so first-time users see art fast.
    const seeds = {'a': '3', 'b': '4', 'c': '2'};
    for (final v in _formula.vars) {
      _controllers.putIfAbsent(
          v, () => TextEditingController(text: seeds[v] ?? '2'));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _solve() {
    final values = <String, num>{};
    for (final v in _formula.vars) {
      final raw = _controllers[v]!.text.trim();
      final parsed = num.tryParse(raw);
      if (parsed == null) {
        setState(() => _error = 'Enter a valid number for "$v".');
        return;
      }
      values[v] = parsed;
    }
    setState(() => _error = null);
    final answer = _formula.evaluate(values);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          formula: _formula,
          values: values,
          answer: answer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A tiny live preview so the tool feels alive before solving.
    final previewName = PatternEngine.names.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Solve & Draw', style: AppText.h2),
        leading: const BackButton(color: AppColors.ink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text('Math that draws',
              style: AppText.h1.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text('Pick a formula, enter your numbers, and watch the answer '
              'turn into a scalable pattern.',
              style: AppText.body.copyWith(fontSize: 13.5)),
          const SizedBox(height: 20),
          const SectionHeader('Choose a formula'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final f in kFormulas)
                _FormulaChip(
                  formula: f,
                  selected: f.id == _formula.id,
                  onTap: () {
                    setState(() {
                      _formula = f;
                      _error = null;
                      _syncControllers();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_formula.display,
                          style: AppText.mono.copyWith(
                              fontSize: 18,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_formula.blurb, style: AppText.body.copyWith(fontSize: 13.5)),
                const SizedBox(height: 16),
                for (final v in _formula.vars) ...[
                  _VarField(name: v, controller: _controllers[v]!),
                  const SizedBox(height: 12),
                ],
                if (_error != null) ...[
                  Text(_error!,
                      style: const TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(
                  label: 'Solve & Draw',
                  icon: Icons.auto_awesome,
                  onPressed: _solve,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Preview', style: AppText.label),
          const SizedBox(height: 10),
          AsciiView(lines: PatternEngine.render(previewName, 5)),
        ],
      ),
    );
  }
}

class _FormulaChip extends StatelessWidget {
  const _FormulaChip(
      {required this.formula, required this.selected, required this.onTap});
  final Formula formula;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.stroke),
        ),
        child: Text(
          formula.display,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _VarField extends StatelessWidget {
  const _VarField({required this.name, required this.controller});
  final String name;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(name,
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.primaryDark)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true, signed: true),
            style: const TextStyle(color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'Value for $name',
              hintStyle: const TextStyle(color: AppColors.inkFaint),
              filled: true,
              fillColor: AppColors.fill,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
