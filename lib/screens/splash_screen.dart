import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Shown while Firebase initializes and the first auth event arrives.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 84),
            const SizedBox(height: 22),
            const Text('Numonics', style: AppText.display),
            const SizedBox(height: 6),
            Text('master math, beautifully',
                style: AppText.label.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 34),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
