import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../state/app_state.dart';
import 'info_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final app = AppState.instance;
        final initials = _initials(app.name);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Text('Profile', style: AppText.h1),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(app.name, style: AppText.h1),
                  const SizedBox(height: 2),
                  Text(app.email, style: AppText.body.copyWith(fontSize: 13.5)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _MiniStat(value: '${app.xp}', label: 'XP'),
                  _divider(),
                  _MiniStat(value: '${app.streak}', label: 'Streak'),
                  _divider(),
                  _MiniStat(value: '${app.solved}', label: 'Solved'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _MenuTile(
              icon: Icons.lock_outline,
              label: 'Privacy & security',
              onTap: () => _open(context, buildPrivacyScreen()),
            ),
            _MenuTile(
              icon: Icons.help_outline,
              label: 'Help & support',
              onTap: () => _open(context, buildHelpScreen()),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              label: 'About Numonics',
              onTap: () => _open(context, buildAboutScreen()),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Sign out',
              icon: Icons.logout,
              color: AppColors.coral,
              onPressed: () => _confirmSignOut(context),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const _DeleteAccountDialog(),
                ),
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.coral, size: 20),
                label: const Text('Delete account',
                    style: TextStyle(
                        color: AppColors.coral, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _divider() => Container(width: 1, height: 34, color: AppColors.divider);

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?', style: AppText.h2),
        content: Text('You can sign back in any time.', style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.inkSoft)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppState.instance.signOut();
            },
            child: const Text('Sign out',
                style: TextStyle(
                    color: AppColors.coral, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_password.text.isEmpty) {
      setState(() => _error = 'Enter your password to continue.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AppState.instance.deleteAccount(password: _password.text);
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _busy = false;
        _error = switch (e.code) {
          'wrong-password' || 'invalid-credential' => 'Incorrect password.',
          'too-many-requests' => 'Too many attempts. Try again later.',
          'network-request-failed' => 'No internet connection.',
          _ => e.message ?? 'Could not delete account.',
        };
      });
    } catch (_) {
      setState(() {
        _busy = false;
        _error = 'Could not delete account. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete account?', style: AppText.h2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This permanently deletes your account, XP, streak and progress. '
            'This cannot be undone.',
            style: AppText.body,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            enabled: !_busy,
            style: const TextStyle(color: AppColors.ink),
            onSubmitted: (_) => _delete(),
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              hintStyle: const TextStyle(color: AppColors.inkFaint),
              filled: true,
              fillColor: AppColors.fill,
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.inkSoft)),
        ),
        TextButton(
          onPressed: _busy ? null : _delete,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.coral))
              : const Text('Delete',
                  style: TextStyle(
                      color: AppColors.coral, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppText.h2),
          const SizedBox(height: 2),
          Text(label, style: AppText.label.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: AppText.body
                        .copyWith(color: AppColors.ink, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: AppColors.inkFaint),
          ],
        ),
      ),
    );
  }
}
