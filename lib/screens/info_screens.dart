import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// A simple, reusable content page for Privacy, Help and About.
class InfoScreen extends StatelessWidget {
  const InfoScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(title, style: AppText.h2),
        leading: const BackButton(color: AppColors.ink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(intro, style: AppText.body),
          const SizedBox(height: 20),
          for (final s in sections) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(s.icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(s.heading,
                              style: AppText.h2.copyWith(fontSize: 16))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(s.body,
                      style: AppText.body.copyWith(fontSize: 14, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class InfoSection {
  const InfoSection(this.icon, this.heading, this.body);
  final IconData icon;
  final String heading;
  final String body;
}

// --- Concrete pages --------------------------------------------------------

Widget buildPrivacyScreen() => const InfoScreen(
      title: 'Privacy & Security',
      intro:
          'Your learning data belongs to you. Here is how Numonics handles it.',
      sections: [
        InfoSection(
          Icons.person_outline,
          'What we store',
          'Your display name, email and learning stats (XP, streak, questions '
              'solved) are kept in your private Cloud Firestore profile, tied to '
              'your account only.',
        ),
        InfoSection(
          Icons.lock_outline,
          'How it is protected',
          'Sign-in is handled by Firebase Authentication. Firestore security '
              'rules ensure only you can read or write your own profile document.',
        ),
        InfoSection(
          Icons.auto_awesome,
          'Mathy conversations',
          'Messages you send to Mathy are forwarded to the Groq API to generate '
              'a reply. They are not stored by the app after your session ends.',
        ),
        InfoSection(
          Icons.delete_outline,
          'Deleting your data',
          'Signing out clears this session. To permanently remove your account '
              'and profile, contact support and we will erase your records.',
        ),
      ],
    );

Widget buildHelpScreen() => const InfoScreen(
      title: 'Help & Support',
      intro: 'Stuck on something? These pointers cover the common questions.',
      sections: [
        InfoSection(
          Icons.play_circle_outline,
          'Getting started',
          'Open a Daily Challenge from Home, answer the multiple-choice '
              'questions, and tap Explanation any time you want a step-by-step '
              'breakdown.',
        ),
        InfoSection(
          Icons.auto_awesome,
          'Using Mathy',
          'Tap the Mathy tab and ask any math question in plain language. Mathy '
              'explains it step by step. If Mathy says it is not connected, an '
              'admin needs to add the Groq API key and model in Firestore.',
        ),
        InfoSection(
          Icons.brush_outlined,
          'Solve & Draw',
          'On Home, open Solve & Draw, pick a formula, enter your numbers, and '
              'the answer generates a scalable pattern you can swipe through.',
        ),
        InfoSection(
          Icons.mail_outline,
          'Contact us',
          'Still need a hand? Email support@numonics.app and we will get back '
              'to you.',
        ),
      ],
    );

Widget buildAboutScreen() => const InfoScreen(
      title: 'About Numonics',
      intro:
          'Numonics is a calm, modern way to practice math every day — with an '
          'AI tutor in your pocket.',
      sections: [
        InfoSection(
          Icons.school_rounded,
          'Our mission',
          'Make daily math practice feel light and rewarding: short challenges, '
              'clear explanations, and gentle streaks that keep you coming back.',
        ),
        InfoSection(
          Icons.auto_awesome,
          'Meet Mathy',
          'Mathy is your built-in AI math tutor, powered by fast Groq language '
              'models, ready to explain any concept step by step.',
        ),
        InfoSection(
          Icons.info_outline,
          'Version',
          'Numonics 1.0.0 — built with Flutter and Firebase.',
        ),
      ],
    );
