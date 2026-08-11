import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/firebase_service.dart';

enum AppFlow { splash, onboarding, auth, home }

/// Global app state. Bridges Firebase auth/profile into the widget tree and
/// keeps a little local quiz progress so the Home dashboard feels alive.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  final _fb = FirebaseService.instance;

  AppFlow flow = AppFlow.splash;
  String? initError;

  User? _user;
  UserProfile? _profile;
  bool _onboarded = false;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserProfile>? _profileSub;

  // Per-challenge completion counts (in-memory for this session).
  final Map<String, int> _progress = {};

  GroqConfig? _groqConfig;
  bool _groqFetched = false;

  UserProfile? get profile => _profile;
  bool get isAuthed => _user != null;
  String get name => _profile?.name ?? _user?.displayName ?? 'Explorer';
  String get email => _profile?.email ?? _user?.email ?? '';
  int get xp => _profile?.xp ?? 0;
  int get streak => _profile?.streak ?? 0;
  int get solved => _profile?.solved ?? 0;

  int progressFor(String challengeId) => _progress[challengeId] ?? 0;

  /// Called once Firebase has initialized successfully.
  void bind() {
    _authSub = _fb.authStateChanges().listen(_onAuthChanged);
  }

  void failInit(String message) {
    initError = message;
    // Let the user at least reach the auth screen; most features degrade
    // gracefully and show their own errors.
    flow = AppFlow.onboarding;
    notifyListeners();
  }

  void _onAuthChanged(User? user) {
    _user = user;
    _profileSub?.cancel();
    _profileSub = null;

    if (user != null) {
      _profileSub = _fb.profileStream(user).listen((p) {
        _profile = p;
        notifyListeners();
      });
      flow = AppFlow.home;
    } else {
      _profile = null;
      _progress.clear();
      flow = _onboarded ? AppFlow.auth : AppFlow.onboarding;
    }
    notifyListeners();
  }

  void completeOnboarding() {
    _onboarded = true;
    flow = AppFlow.auth;
    notifyListeners();
  }

  Future<void> signOut() async {
    _onboarded = true;
    await _fb.signOut();
  }

  /// Records a correct answer: bumps local challenge progress and awards XP in
  /// Firestore. Fire-and-forget on the network side so the UI stays snappy.
  void recordCorrect({required String challengeId, int xp = 10}) {
    final uid = _user?.uid;
    if (uid != null) {
      _fb.addXpAndSolve(uid: uid, xp: xp).catchError((_) {});
    }
    notifyListeners();
  }

  /// Marks how many questions of a challenge the user has completed.
  void setChallengeProgress(String challengeId, int completed) {
    final prev = _progress[challengeId] ?? 0;
    if (completed > prev) {
      _progress[challengeId] = completed;
      notifyListeners();
    }
  }

  /// Lazily loads (and caches) the Groq config from Firestore.
  Future<GroqConfig?> groqConfig({bool force = false}) async {
    if (_groqFetched && !force) return _groqConfig;
    try {
      _groqConfig = await _fb.fetchGroqConfig();
    } catch (_) {
      _groqConfig = null;
    }
    _groqFetched = true;
    return _groqConfig;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
