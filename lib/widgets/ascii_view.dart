import 'package:flutter/material.dart';
import '../theme.dart';

/// Renders ASCII-art grid lines inside a soft, centered card. The text scales
/// down to fit the available width so any pattern size stays on screen.
class AsciiView extends StatelessWidget {
  const AsciiView({
    super.key,
    required this.lines,
    this.color = AppColors.primary,
    this.background,
  });

  final List<String> lines;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final text = lines.join('\n');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background ?? AppColors.bgSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontFamilyFallback: const ['Menlo', 'Courier', 'monospace'],
              fontSize: 16,
              height: 1.15,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
