import 'package:NoteNest/screens/Settings.dart';
import 'package:NoteNest/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;

  String userId = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  String? gender;
  String mobileNumber = '';
  String address = '';
  String pincode = '';

  final _formKey = GlobalKey<FormState>();

  List<String> genderOptions = ['Male', 'Female', 'Others'];

  @override
  void initState() {
    super.initState();
    _loadGoogleUserData();
  }

  Future<void> _loadGoogleUserData() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final account = await googleSignIn.signInSilently();
      if (account != null) {
        String email = account.email;
        nameController.text = account.displayName ?? '';
        emailController.text = email;

        var snapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .where('Email', isEqualTo: email)
                .limit(1)
                .get();

        if (snapshot.docs.isNotEmpty) {
          var doc = snapshot.docs.first;
          userId = doc.id;

          var data = doc.data();
          setState(() {
            genderController.text = data['Gender'] ?? '';
            mobileController.text = data['Mobile'] ?? '';
            addressController.text = data['Address'] ?? '';
            pincodeController.text = data['Pincode'] ?? '';
            gender = data['Gender'] ?? '';
            mobileNumber = data['Mobile'] ?? '';
            address = data['Address'] ?? '';
            pincode = data['Pincode'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Google Sign-In error: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bg_color,
        appBar: AppBar(
          backgroundColor: primary_color,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        backgroundColor: bg_color,
        appBar: AppBar(
          backgroundColor: primary_color,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileCard('Name', nameController, readOnly: true),
                _buildProfileCard('Email', emailController, readOnly: true),
                _buildDropdownCard('Gender', genderOptions),
                _buildProfileCard(
                  'Mobile Number',
                  mobileController,
                  hint: 'Enter 10-digit number',
                  maxLength: 10,
                ),
                _buildProfileCard(
                  'Address',
                  addressController,
                  hint: 'Enter your address',
                  maxLines: 2,
                ),
                _buildProfileCard(
                  'Pincode',
                  pincodeController,
                  hint: 'Enter pincode',
                  maxLength: 6,
                ),
                const SizedBox(height: 15),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userId)
                              .update({
                                'Gender': gender,
                                'Mobile': mobileController.text.trim(),
                                'Address': addressController.text.trim(),
                                'Pincode': pincodeController.text.trim(),
                              });
                          Fluttertoast.showToast(msg: 'Profile Updated!');
                          Navigator.pop(context);
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: 'Update failed, try again.',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary_color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildProfileCard(
    String label,
    TextEditingController controller, {
    String? hint,
    bool readOnly = false,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5), // reduced from 10 to 6
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType:
                (label == 'Mobile Number' || label == 'Pincode')
                    ? TextInputType.number
                    : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500]),
              counterText: '',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) {
              if (!readOnly && (value == null || value.isEmpty)) {
                return 'Please enter $label';
              }
              if (label == 'Mobile Number' && value!.length != 10) {
                return 'Enter 10-digit number';
              }
              if (label == 'Pincode' && value!.length != 6) {
                return 'Enter 6-digit pincode';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCard(String label, List<String> options) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6), // reduced from 10 to 6
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: options.contains(gender) ? gender : null,
            items:
                options
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, style: const TextStyle(fontSize: 15)),
                      ),
                    )
                    .toList(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            hint: Text(
              "Select your gender",
              style: TextStyle(color: Colors.grey[500]),
            ),
            onChanged: (value) {
              setState(() {
                gender = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
