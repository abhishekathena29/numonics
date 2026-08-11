import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'state/app_state.dart';
import 'widgets/common.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const NumonicsApp());
}

class NumonicsApp extends StatefulWidget {
  const NumonicsApp({super.key});

  @override
  State<NumonicsApp> createState() => _NumonicsAppState();
}

class _NumonicsAppState extends State<NumonicsApp> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppState.instance.bind();
    } catch (e) {
      // Surface init failures without crashing the splash into a black screen.
      AppState.instance.failInit(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numonics',
      debugShowCheckedModeBanner: false,
      theme: buildNumonicsTheme(),
      home: const _Root(),
    );
  }
}

/// Listens to [AppState] and swaps between the top-level flows with a
/// smooth cross-fade.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final flow = AppState.instance.flow;
        late final Widget child;
        switch (flow) {
          case AppFlow.splash:
            child = const SplashScreen(key: ValueKey('splash'));
            break;
          case AppFlow.onboarding:
            child = const OnboardingScreen(key: ValueKey('onboarding'));
            break;
          case AppFlow.auth:
            child = const AuthScreen(key: ValueKey('auth'));
            break;
          case AppFlow.home:
            child = const AppBackground(
              key: ValueKey('home'),
              child: HomeScreen(),
            );
            break;
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          transitionBuilder: (c, anim) =>
              FadeTransition(opacity: anim, child: c),
          child: SizedBox.expand(key: child.key, child: child),
        );
      },
    );
  }
}
