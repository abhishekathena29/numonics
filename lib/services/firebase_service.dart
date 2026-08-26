import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

/// Thin wrapper around FirebaseAuth + Cloud Firestore.
///
/// Firestore layout:
///   users/{uid}            -> UserProfile (name, email, xp, streak, ...)
///   config/groq            -> { apiKey: String, model: String }
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  // Resolved lazily: these must not be touched until Firebase.initializeApp
  // has completed (otherwise `[core/no-app]` is thrown).
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  // ---- Auth --------------------------------------------------------------

  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _userDoc(user.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'xp': 0,
      'streak': 1,
      'solved': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });
    return user;
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Touch lastActive; ignore if offline.
    _userDoc(cred.user!.uid)
        .set({'lastActive': FieldValue.serverTimestamp()}, SetOptions(merge: true))
        .catchError((_) {});
    return cred.user!;
  }

  Future<void> signOut() => _auth.signOut();

  // ---- Profile -----------------------------------------------------------

  /// Live profile stream. If the doc is missing (e.g. an older account),
  /// falls back to a minimal profile built from the auth record.
  Stream<UserProfile> profileStream(User user) {
    return _userDoc(user.uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) {
        return UserProfile(
          uid: user.uid,
          name: user.displayName ?? 'Explorer',
          email: user.email ?? '',
        );
      }
      return UserProfile.fromMap(user.uid, data);
    });
  }

  /// Records a correct answer and rolls the daily streak forward:
  /// solving again the same calendar day leaves the streak unchanged,
  /// solving the day after bumps it by one, and any bigger gap resets it.
  Future<void> addXpAndSolve({
    required String uid,
    required int xp,
  }) async {
    final ref = _userDoc(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? const <String, dynamic>{};

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastActiveTs = data['lastActive'];
      DateTime? lastActiveDay;
      if (lastActiveTs is Timestamp) {
        final d = lastActiveTs.toDate();
        lastActiveDay = DateTime(d.year, d.month, d.day);
      }

      final currentStreak = (data['streak'] as num?)?.toInt() ?? 0;
      final int newStreak;
      if (lastActiveDay == null) {
        newStreak = 1;
      } else {
        final gap = today.difference(lastActiveDay).inDays;
        if (gap == 0) {
          newStreak = currentStreak == 0 ? 1 : currentStreak;
        } else if (gap == 1) {
          newStreak = currentStreak + 1;
        } else {
          newStreak = 1;
        }
      }

      tx.set(ref, {
        'xp': FieldValue.increment(xp),
        'solved': FieldValue.increment(1),
        'streak': newStreak,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  // ---- Groq config -------------------------------------------------------

  /// Reads the Groq API key + model from `config/groq`. Returns null if the
  /// document (or its fields) aren't set up yet.
  Future<GroqConfig?> fetchGroqConfig() async {
    final snap = await _db.collection('config').doc('groq').get();
    final data = snap.data();
    if (data == null) return null;
    final key = (data['apiKey'] as String?)?.trim();
    final model = (data['model'] as String?)?.trim();
    if (key == null || key.isEmpty || model == null || model.isEmpty) {
      return null;
    }
    return GroqConfig(apiKey: key, model: model);
  }
}

class GroqConfig {
  const GroqConfig({required this.apiKey, required this.model});
  final String apiKey;
  final String model;
}
