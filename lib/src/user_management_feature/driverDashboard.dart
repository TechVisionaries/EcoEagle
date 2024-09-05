import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek_spm/src/user_management_feature/userProfile.dart'; // Import the user profile page

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  static const routeName = '/rewards';


  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  String? _username;

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('userID');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $_username!'),
            const SizedBox(height: 10),
            const Text('Driver dashboard'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Home button action (optional)
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: _navigateToUserProfile,
            ),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () {
                // Location button action (optional)
              },
            ),
          ],
        ),
      ),
    );
  }
}
