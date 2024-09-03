import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Residentdashboard extends StatefulWidget {
  const Residentdashboard({super.key});

  @override
  _ResidentDashboardState createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<Residentdashboard> {
  String? _username;
  // Add other fields as needed

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('userID');
      // Load other fields as needed
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
            // Display other fields as needed
          ],
        ),
      ),
    );
  }
}
