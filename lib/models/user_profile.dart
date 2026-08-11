/// The user's learning profile, mirrored from `users/{uid}` in Firestore.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.xp = 0,
    this.streak = 0,
    this.solved = 0,
  });

  final String uid;
  final String name;
  final String email;
  final int xp;
  final int streak;
  final int solved;

  /// Rough level curve: every 100 XP is a level.
  int get level => (xp ~/ 100) + 1;
  double get levelProgress => (xp % 100) / 100.0;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? map['name'] as String
          : 'Explorer',
      email: (map['email'] as String?) ?? '',
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      solved: (map['solved'] as num?)?.toInt() ?? 0,
    );
  }
}
