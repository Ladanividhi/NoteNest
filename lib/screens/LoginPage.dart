import 'package:NoteNest/screens/Dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color primaryColor = const Color(0xFF6750A4);

  login() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        QuerySnapshot existingUser = await firestore
            .collection('Users')
            .where('Email', isEqualTo: user.email)
            .get();

        if (existingUser.docs.isEmpty) {
          await firestore.collection('Users').doc(user.uid).set({
            'Name': user.displayName,
            'Email': user.email,
            'Gender': null,
            'Mobile': null,
            'Address': null,
            'Pincode': null,
          });
          print('New user added to Firestore');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          print('User already exists in Firestore');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      }
    } catch (e) {
      print('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              CircleAvatar(
                radius: 100,
                backgroundImage: const AssetImage('assets/images/logo.png'),
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 24),
              // Subtitle
              Text(
                'Organize your tasks and simplify your life with NoteNest!',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge!.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),

              // Google Sign-In Button
              GestureDetector(
                onTap: login,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/google.png',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // App Tagline or Footer Text
              Text(
                '© 2025 NoteNest by codecrafters79@gmail.com',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall!.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
