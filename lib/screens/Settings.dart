import 'package:NoteNest/screens/AboutNoteNest.dart';
import 'package:NoteNest/screens/ContactUs.dart';
import 'package:NoteNest/screens/EditTasks.dart';
import 'package:NoteNest/screens/FAQs.dart';
import 'package:NoteNest/screens/LoginPage.dart';
import 'package:NoteNest/screens/ProfilePAge.dart';
import 'package:NoteNest/screens/TermsAndCondition.dart';
import 'package:NoteNest/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  signout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Dangerous Operation ⚠️",
              style: TextStyle(color: Colors.red, fontSize: 21),
            ),
            content: const Text(
              "This operation will permanently delete all your notes and tasks saved till now. "
              "We will not be responsible for any data loss. Once deleted, your data cannot be recovered. "
              "Please proceed with caution.",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _showFinalResetWarning(context);
                },
                child: const Text(
                  "Okay",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showFinalResetWarning(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Final Warning ⚠️",
              style: TextStyle(color: Colors.red),
            ),
            content: const Text(
              "Are you absolutely sure you want to delete all your notes and tasks saved till now? "
              "This action is irreversible and will permanently wipe your task records.",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("No"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteAllUserData();
                  Fluttertoast.showToast(
                    msg: "All your data has been permanently deleted",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                  );
                },
                child: const Text(
                  "Yes, Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAllUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final firestore = FirebaseFirestore.instance;

    try {
      // Delete from Users collection
      final userDocs = await firestore
          .collection('Users')
          .where('Id', isEqualTo: userId)
          .get();

      for (var doc in userDocs.docs) {
        await doc.reference.delete();
      }

      // Delete from Tasks collection
      final taskDocs = await firestore
          .collection('Tasks')
          .where('Id', isEqualTo: userId)
          .get();

      for (var doc in taskDocs.docs) {
        await doc.reference.delete();
      }

      // Delete from TasksCompleted collection
      final completedTaskDocs = await firestore
          .collection('TasksCompleted')
          .where('Id', isEqualTo: userId)
          .get();

      for (var doc in completedTaskDocs.docs) {
        await doc.reference.delete();
      }

      // Optionally show confirmation toast or snackbar here
      Fluttertoast.showToast(msg: 'All your data has been successfully deleted.');

    } catch (e) {
      print('Error deleting user data: $e');
      Fluttertoast.showToast(msg: 'Failed to delete data. Try again.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        backgroundColor: primary_color,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle("General"),
          _buildTile(
            title: 'Manage Profile',
            icon: Icons.account_circle,
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
          _buildTile(
            title: 'Manage Tasks',
            icon: Icons.folder_open_rounded,
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditTaskPage(),
                ),
              );
            },
          ),
          _buildTile(
            title: 'Terms & Conditions',
            icon: Icons.policy_rounded,
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsAndConditionsPage(),
                ),
              );
            },
          ),
          _buildTile(
            title: 'FAQs',
            icon: Icons.question_answer_rounded,
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FAQsPage()),
              );
            },
          ),
          _buildTile(
            title: 'Contact Us',
            icon: Icons.chat_rounded,
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsPage()),
              );
            },
          ),
          _buildTile(
            title: 'About NoteNest',
            icon: Icons.info_outline_rounded,
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutNoteNestPage()),
              );
            },
          ),
          const SizedBox(height: 15),
          _buildSectionTitle("Preferences"),
          _buildSwitchTile(
            title: 'Dark Mode',
            value: isDarkMode,
            onToggle: (val) {
              setState(() {
                isDarkMode = val;
              });
            },
          ),
          _buildSwitchTile2(
            title: 'Enable Notifications',
            value: notificationsEnabled,
            onToggle: (val) {
              setState(() {
                notificationsEnabled = val;
              });
            },
          ),
          const SizedBox(height: 15),
          _buildSectionTitle("Data & Security"),
          _buildTile(
            title: 'Reset All Data',
            icon: Icons.delete_outline,
            iconColor: Colors.redAccent,
            onTap: () {
              _showResetConfirmation(context);
            },
          ),
          const SizedBox(height: 30),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.dark_mode, color: Colors.deepPurple),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          FlutterSwitch(
            width: 50.0,
            height: 26.0,
            toggleSize: 20.0,
            value: value,
            borderRadius: 30.0,
            padding: 4.0,
            activeColor: Colors.deepPurple,
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile2({
    required String title,
    required bool value,
    required Function(bool) onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.deepPurple),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          FlutterSwitch(
            width: 50.0,
            height: 26.0,
            toggleSize: 20.0,
            value: value,
            borderRadius: 30.0,
            padding: 4.0,
            activeColor: Colors.deepPurple,
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }
  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Logout"),
              content: const Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Yes"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    signout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      icon: const Icon(Icons.logout),
      label: const Text(
        'Logout',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
