import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';

/// Displays the user reports page.
class UserReport extends StatelessWidget {
  const UserReport({super.key});

  static const routeName = Constants.userReportRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Bold text
            color: Colors.white, // White text color
          ),
        ),
        centerTitle: true, // Center the title in the AppBar
        backgroundColor:
            const Color.fromARGB(255, 65, 168, 125), // Header color
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // White color for the back icon
        ),
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
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report,
                  size: 100.0,
                  color: Colors.purple,
                ),
                SizedBox(height: 20),
                Text(
                  'User Reports Page',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Here you can view and manage user reports.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
