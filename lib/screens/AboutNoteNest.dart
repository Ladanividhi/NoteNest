import 'package:flutter/material.dart';
import 'package:NoteNest/utils/Constants.dart';

class AboutNoteNestPage extends StatelessWidget {
  const AboutNoteNestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'About NoteNest',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary_color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              icon: Icons.lightbulb,
              title: 'What is NoteNest?',
              content:
              'NoteNest is a simple, clean, and intuitive app designed to help you manage your notes, daily tasks, and reminders efficiently. Stay productive and organized with a delightful user experience.',
              textTheme: textTheme,
            ),
            _buildCard(
              icon: Icons.star,
              title: 'Features',
              content:
              '• Create and manage daily tasks\n• Organize notes in a neat interface\n• Light/Dark mode support\n• Secure Google sign-in\n• Customizable settings\n• Responsive modern design',
              textTheme: textTheme,
            ),
            _buildCard(
              icon: Icons.tips_and_updates,
              title: 'Version',
              content: '1.0.0',
              textTheme: textTheme,
            ),
            _buildCard(
              icon: Icons.verified_user_rounded,
              title: 'Credits',
              content:
              'Designed and developed with ❤️ by Vidhi.\n© 2025 Codecrafters79. All rights reserved.',
              textTheme: textTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String content,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primary_color, size: 26),
              const SizedBox(width: 12),
              Text(
                title,
                style: textTheme.titleMedium!.copyWith(
                  color: primary_color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: textTheme.bodyMedium!.copyWith(
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
