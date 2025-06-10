import 'package:NoteNest/screens/CreatePassword.dart';
import 'package:NoteNest/utils/Constants.dart';
import 'package:NoteNest/utils/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  void _submitForm() async {
    if ((_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _mobileController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      //Check if user already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User with this email already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User with this email already exists')),
        );
        return;
      }

      // If user doesn't exist, proceed
      final user = UserModel(
        fullName: _fullNameController.text.trim(),
        email: email,
        mobile: _mobileController.text.trim(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreatePasswordPage(user: user)),
      );
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
      return InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg_color,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            child: Container(
              width: size.width,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: text_color,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration('Full Name', Icons.person_outline),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email', Icons.email_outlined),
                    ),
                    const SizedBox(height: 20),

                    // Mobile Number
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: _inputDecoration('Mobile Number', Icons.phone),
                      validator: (value) {
                        if (value == null || value.length != 10) {
                          return 'Enter a valid 10-digit number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary_color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
