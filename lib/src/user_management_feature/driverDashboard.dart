import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/reward_management/driver_profile.dart';
import 'package:trashtrek/src/user_management_feature/userProfile.dart'; // Import the user profile page

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 133, 224, 125),
              Color.fromARGB(255, 187, 251, 201),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          children: [
            _buildNavigationTile(
              context,
              title: 'My Reviews',
              icon: Icons.reviews,
              color: Colors.redAccent,
              routeName: DriverProfile.routeName,
            ),
            _buildNavigationTile(
              context,
              title: 'My Route',
              icon: Icons.map,
              color: Colors.teal,
              routeName: Constants.wasteMapDriverRoute,
            ),
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
            const Icon(
              (Icons.home),
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
  
  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String routeName,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0)), // Rounded corners
      elevation: 4, // Slightly lighter elevation
      shadowColor: Colors.black.withOpacity(0.2), // Subtle shadow color
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Margin between cards
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 12.0), // Padding inside ListTile
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            color: Colors.grey[600]), // Slightly darker grey
        onTap: () {
          // Navigate to the specified route.
          Navigator.restorablePushNamed(context, routeName);
        },
      ),
    );
  }
}
