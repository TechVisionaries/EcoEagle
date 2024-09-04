import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userProfile.dart'; // Make sure to import your UserProfile page

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  _ResidentDashboardState createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
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

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $_username!'),
            const SizedBox(height: 10),
            const Text('Resident dashboard'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Handle home button press
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _navigateToProfile, // Navigate to UserProfile
            ),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () {
                // Handle location button press
              },
            ),
          ],
        ),
      ),
    );
  }
}
