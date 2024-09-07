import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';

import '../reward_management/add_rating_view.dart';
import '../reward_management/view_reviews.dart';
import '../settings/settings_view.dart';
import '../appointments_feature/schedule_appointment_view.dart';
import '../appointments_feature/my_appointments_view.dart';

/// Displays a list of options for navigation with a beautified UI.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({super.key});

  static const routeName = '/options';

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
            const Color.fromARGB(255, 38, 175, 118), // Header color
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
              Color.fromARGB(255, 133, 224, 125), // Light green top
              Color.fromARGB(255, 187, 251, 201) // Light green bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Navigate to the specified route.
          Navigator.restorablePushNamed(context, routeName);
        },
        splashColor: color.withOpacity(0.3), // Splash effect on tap
        borderRadius: BorderRadius.circular(12.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 6,
          shadowColor: color.withOpacity(0.4), // Subtle shadow color
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                letterSpacing: 0.5, // Slight spacing for better readability
              ),
            ),
            trailing:
                Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.6)),
          ),
        ),
      ),
    );
  }
}
