import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';

import '../reward_management/add_rating_view.dart';
import '../reward_management/view_reviews.dart';
import '../settings/settings_view.dart';
import '../appointments_feature/schedule_appointment_view.dart';
import '../appointments_feature/my_appointments_view.dart';
import '../user_management_feature/userProfile.dart'; // Make sure to import your UserProfile page

/// Displays a list of options for navigation with a beautified UI.
class SampleItemListView extends StatefulWidget {
  const SampleItemListView({super.key});

  static const routeName = '/options';

  @override
  _SampleItemListViewState createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  int _selectedIndex = 0; // Track the selected index

  void _navigateToProfile(BuildContext context) {
    setState(() {
      _selectedIndex = 1; // Set the index for profile
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfile()),
    );
  }

  void _navigateToHome(BuildContext context) {
    setState(() {
      _selectedIndex = 0; // Set the index for home
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SampleItemListView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
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
              title: 'Schedule Appointment',
              icon: Icons.schedule,
              color: Colors.purple,
              routeName: ScheduleAppointmentView.routeName,
            ),
            _buildNavigationTile(
              context,
              title: 'My Appointments',
              icon: Icons.assignment,
              color: Colors.green,
              routeName: MyAppointmentsView.routeName,
            ),
            _buildNavigationTile(
              context,
              title: 'Rate Driver',
              icon: Icons.rate_review,
              color: Colors.orange,
              routeName: RateDriverScreen.routeName,
            ),
            _buildNavigationTile(
              context,
              title: 'My Reviews',
              icon: Icons.reviews,
              color: Colors.redAccent,
              routeName: MyReviewsScreen.routeName,
            ),
            _buildNavigationTile(
              context,
              title: 'Driver Map',
              icon: Icons.map,
              color: Colors.teal,
              routeName: Constants.wasteMapDriverRoute,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, // Increased notch margin for better aesthetics
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Colors.blue // Highlight if selected
                    : Colors.grey,
              ),
              onPressed: () => _navigateToHome(context),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: _selectedIndex == 1
                    ? Colors.blue // Highlight if selected
                    : Colors.grey,
              ),
              onPressed: () => _navigateToProfile(context),
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

  /// Builds a navigation tile with custom styling and animations.
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
          style: TextStyle(
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
