import 'package:NoteNest/screens/Dashboard.dart';
import 'package:NoteNest/screens/LoginPage.dart';
import 'package:NoteNest/utils/Wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(NoteNestApp());
}

class NoteNestApp extends StatelessWidget {
  const NoteNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteNest',
      debugShowCheckedModeBanner: false,
      home: Wrapper(),
    );
  }
}
