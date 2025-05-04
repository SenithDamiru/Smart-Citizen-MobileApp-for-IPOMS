import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Complaint Screen/api_service.dart';

class UserProfileDrawer extends StatefulWidget {
  UserProfileDrawer({Key? key}) : super(key: key);

  @override
  _UserProfileDrawerState createState() => _UserProfileDrawerState();
}

class _UserProfileDrawerState extends State<UserProfileDrawer> {
  final _storage = FlutterSecureStorage();
  String _name = "Loading...";
  String _email = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Method to fetch user profile from API
  Future<void> _loadUserProfile() async {
    String? citizenId = await _storage.read(key: 'citizenId'); // Get citizen ID from secure storage

    if (citizenId != null) {
      try {
        final response = await http.get(Uri.parse("${ApiService.getCitizen}/$citizenId"));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _name = data['fullName']; // Assuming 'fullName' is the field name
            _email = data['email'];   // Assuming 'email' is the field name
          });
        } else {
          setState(() {
            _name = "Error fetching data";
            _email = "";
          });
        }
      } catch (e) {
        setState(() {
          _name = "Error fetching data";
          _email = "";
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.delete(key: 'citizen_id'); // Clear stored data
      Navigator.pushReplacementNamed(context, '/login'); // Go to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85, // Set drawer width to 85% of screen width
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.light_mode),
                      onPressed: () {
                        // Toggle theme logic here
                      },
                    ),
                  ],
                ),
              ),

              // Profile section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 2)
                      ),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/boy.png'),
                        radius: 50,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _name, // Display fetched name
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _email, // Display fetched email
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Upgrade button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Upgrade logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Upgrade to PRO'),
                ),
              ),

              SizedBox(height: 24),

              // Menu options
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileOption(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.history,
                      title: 'Purchase History',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.person_add_outlined,
                      title: 'Invite a Friend',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Logout button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => _logout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
