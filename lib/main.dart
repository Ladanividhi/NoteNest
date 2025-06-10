import 'package:NoteNest/screens/Login.dart';
import 'package:NoteNest/screens/Dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final rememberMe = prefs.getBool('rememberMe') ?? false;

  runApp(NoteNestApp(rememberMe: rememberMe));
}

class NoteNestApp extends StatelessWidget {
  final bool rememberMe;
  const NoteNestApp({super.key, required this.rememberMe});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteNest',
      debugShowCheckedModeBanner: false,
      home: rememberMe ? DashboardPage() : const LoginPage(),
    );
  }
}
