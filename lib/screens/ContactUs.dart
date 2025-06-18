import 'package:NoteNest/utils/Constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'About Us',
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
                icon: Icons.description,
                title: 'Our Vision',
                content:
                'At NoteNest, our vision is to help you stay organized, productive, and stress-free by managing your daily tasks and notes effortlessly in a clean, modern, and intuitive interface.',
                color: primary_color,
                textTheme: textTheme,
              ),

              _buildCard(
                icon: Icons.people_outline,
                title: 'Our Team',
                content:
                'We are a passionate team of creators, developers, and designers dedicated to delivering the best task management experience through simplicity, speed, and reliability.',
                color: primary_color,
                textTheme: textTheme,
              ),

              _buildCard(
                icon: Icons.email_outlined,
                title: 'Contact Us',
                contentWidget: RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium!.copyWith(
                        color: Colors.black87),
                    children: [
                      const TextSpan(
                        text: 'For any queries, suggestions, or support, feel free to reach out to us anytime at:\n\n',
                      ),
                      TextSpan(
                        text: 'codecrafters79@gmail.com',
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'codecrafters79@gmail.com',
                            );
                            if (await canLaunchUrl(emailLaunchUri)) {
                              await launchUrl(emailLaunchUri);
                            } else {
                              // Optionally show a snackbar or error message
                            }
                          },
                      ),
                    ],
                  ),
                ),
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
    String? content, // optional now
    Widget? contentWidget, // new optional param
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
          contentWidget ??
              Text(
                content ?? '',
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
