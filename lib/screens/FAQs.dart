import 'package:flutter/material.dart';
import 'package:NoteNest/utils/Constants.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final List<Map<String, String>> faqs = [
      {
        'question': 'What is NoteNest?',
        'answer': 'NoteNest is a task and note management app designed to help you stay productive, organized, and stress-free with a clean and modern interface.'
      },
      {
        'question': 'Is NoteNest free to use?',
        'answer': 'Yes! NoteNest is completely free to download and use. All core features are available without any charges.'
      },
      {
        'question': 'How do I create a new note or task?',
        'answer': 'On the dashboard, tap the "+" button to quickly add a new note or task. You can set its title, description, and optionally assign a date.'
      },
      {
        'question': 'Can I switch between Light and Dark mode?',
        'answer': 'Absolutely! Head to the Settings page and toggle the Dark Mode switch to suit your preference.'
      },
      {
        'question': 'How do I reset all my data?',
        'answer': 'Go to Settings and tap on "Reset all data". You’ll be asked for confirmation before deleting all notes and tasks.'
      },
      {
        'question': 'Is my data stored securely?',
        'answer': 'Yes. Your data is securely stored and protected. We use Firebase Authentication to ensure your account’s safety.'
      },
      {
        'question': 'Can I back up my notes?',
        'answer': 'Currently, automatic cloud backup isn’t available, but it’s on our roadmap for future updates.'
      },
      {
        'question': 'How do I contact support?',
        'answer': 'You can reach us via email at codecrafters79@gmail.com. Visit the Contact Us page for quick access.'
      },
      {
        'question': 'Do you plan to add reminders and notifications?',
        'answer': 'Yes! Reminder and smart notification features are being developed and will be released in upcoming updates.'
      },
      {
        'question': 'Does NoteNest require an internet connection?',
        'answer': 'NoteNest works offline for managing notes and tasks. Some features like Google Sign-In and data sync require an internet connection.'
      },
      {
        'question': 'Can I sort or search my notes?',
        'answer': 'Yes! You can search notes by title or content. Sorting by date and priority is being added soon.'
      },
      {
        'question': 'How do I log out of my account?',
        'answer': 'Go to Settings and tap the Logout button at the bottom. You’ll be securely signed out of your account.'
      },
    ];

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'FAQs',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return _buildFaqCard(
            icon: Icons.help_outline_rounded,
            question: faq['question']!,
            answer: faq['answer']!,
            textTheme: textTheme,
          );
        },
      ),
    );
  }

  Widget _buildFaqCard({
    required IconData icon,
    required String question,
    required String answer,
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
              Icon(icon, color: primary_color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: textTheme.titleMedium!.copyWith(
                    color: primary_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            answer,
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
