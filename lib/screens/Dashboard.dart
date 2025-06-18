import 'package:NoteNest/screens/ContactUs.dart';
import 'package:NoteNest/screens/AddDailyTask.dart';
import 'package:NoteNest/screens/ProfilePAge.dart';
import 'package:NoteNest/screens/Settings.dart';
import 'package:NoteNest/screens/TermsAndCondition.dart';
import 'package:NoteNest/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  int _selectedIndex = 0;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      drawer: _buildSideDrawer(), // <-- add this line
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );

  }

  Widget _buildSideDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: primary_color,
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
            ),
            accountName: Text(
              user?.displayName ?? 'User',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.black87),
            title: const Text('Search'),
            onTap: () {
              Navigator.pop(context);
              // Add your search screen navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.black87),
            title: const Text('Add Task'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDailyTaskPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_page_outlined, color: Colors.black87),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.black87),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black87),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black87),
            title: const Text('Sign Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  /// Builds body content based on selected index
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return Center(
          child: Text("Notes Page", style: TextStyle(fontSize: 22, color: Colors.black)),
        );
      case 3:
        return Center(
          child: Text("Categories Page", style: TextStyle(fontSize: 22, color: Colors.black)),
        );
      case 4:
        return const ProfilePage();
      default:
        return _buildHomeScreen();
    }
  }

  /// Home screen UI
  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              color: primary_color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    Text(
                      'NoteNest',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // to balance space where profile icon was
                  ],
                ),


                const SizedBox(height: 24),
                Text(
                  'Hello, ${user?.displayName ?? 'User'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to capture your thoughts?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // You can add more home widgets / stats cards here
        ],
      ),
    );
  }

  /// Bottom navigation bar
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddDailyTaskPage()),
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          selectedItemColor: primary_color,
          unselectedItemColor: Colors.grey[500],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notes_rounded, size: 26),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary_color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary_color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded, size: 26),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 27),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
