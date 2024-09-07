import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../sample_feature/sample_item_list_view.dart';
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
      _username = prefs.getString('userID') ?? 'User';
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

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SampleItemListView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Portal'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeMessage(),
            const SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.home,
              title: 'Home',
              onTap: _navigateToHome,
            ),
            const SizedBox(height: 15),
            _buildActionButton(
              icon: Icons.person,
              title: 'Profile',
              onTap: _navigateToProfile,
            ),
            const SizedBox(height: 15),
            _buildActionButton(
              icon: Icons.location_on,
              title: 'Location',
              onTap: () {
                // Handle location button press
              },
            ),
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
              onPressed: _navigateToHome,
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _navigateToProfile,
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

  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $_username!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'We’re glad to have you back!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
