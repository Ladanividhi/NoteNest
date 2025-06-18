import 'package:NoteNest/utils/Constants.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'Terms and Condition',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary_color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                icon: Icons.info_outline,
                title: 'Welcome to NoteNest!',
                content:
                'Please read these Terms and Conditions carefully before using our application. By accessing or using the app, you agree to be bound by these terms.',
                color: primary_color,
                textTheme: textTheme,
              ),

              _buildCard(
                icon: Icons.rule,
                title: 'Usage',
                content:
                '- Use the app for lawful purposes only.\n- Do not misuse or disrupt the services.',
                color: primary_color,
                textTheme: textTheme,
              ),

              _buildCard(
                icon: Icons.lock_outline,
                title: 'Privacy',
                content:
                '- Your personal data is securely stored.\n- We do not share your data with third parties without your consent.',
                color: primary_color,
                textTheme: textTheme,
              ),

              _buildCard(
                icon: Icons.security,
                title: 'Account Security',
                content:
                '- Keep your login credentials confidential.\n- Notify us immediately if you detect unauthorized use.',
                color: primary_color,
                textTheme: textTheme,
              ),

              _buildCard(
                icon: Icons.notes,
                title: 'Content',
                content:
                '- You are responsible for the content you add.\n- Inappropriate or offensive content is prohibited.',
                color: primary_color,
                textTheme: textTheme,
              ),

              _buildCard(
                icon: Icons.update,
                title: 'Modifications',
                content:
                '- We may update these terms occasionally.\n- Users will be notified of any major changes.',
                color: primary_color,
                textTheme: textTheme,
              ),

              _buildCard(
                icon: Icons.cancel,
                title: 'Termination',
                content:
                '- We reserve the right to suspend or terminate accounts found violating our terms.',
                color: primary_color,
                textTheme: textTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 10),
              Text(
                title,
                style: textTheme.titleMedium!.copyWith(
                  color: color,
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
