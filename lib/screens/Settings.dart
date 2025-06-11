import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileCard(),

            const SizedBox(height: 24),

            _buildSettingTile(
              title: 'Dark Mode',
              trailing: FlutterSwitch(
                width: 50.0,
                height: 25.0,
                valueFontSize: 12.0,
                toggleSize: 20.0,
                value: isDarkMode,
                borderRadius: 30.0,
                padding: 4.0,
                activeColor: Colors.deepPurple,
                onToggle: (val) {
                  setState(() {
                    isDarkMode = val;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildSettingTile(
              title: 'Enable Notifications',
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildSettingTile(
              title: 'Change Password',
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // navigate to change password page
              },
            ),

            const SizedBox(height: 16),

            _buildSettingTile(
              title: 'About NoteNest',
              trailing: const Icon(Icons.info_outline_rounded),
              onTap: () {
                // show about dialog
                showAboutDialog(
                  context: context,
                  applicationName: 'NoteNest',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 Vidhi',
                );
              },
            ),

            const SizedBox(height: 24),

            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple.shade100,
            child: const Icon(
              Icons.person,
              color: Colors.deepPurple,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Your Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'your.email@example.com',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // handle logout
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
