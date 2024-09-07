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
        title: const Text('Options'),
        backgroundColor: Color.fromARGB(255, 65, 168, 125),
        elevation: 0,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 133, 224, 125),
              const Color.fromARGB(255, 187, 251, 201)
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
              // Navigate to the ScheduleAppointmentView.
            ),
            _buildNavigationTile(
              context,
              title: 'My Appointments',
              icon: Icons.assignment,
              color: Colors.green,
              routeName: MyAppointmentsView.routeName,
              // Navigate to the MyAppointmentsView.
            ),
            _buildNavigationTile(
              context,
              title: 'Rate Driver',
              icon: Icons.rate_review,
              color: Colors.orange,
              routeName: RateDriverScreen.routeName,
              // Navigate to the RateDriverScreen.
            ),
            _buildNavigationTile(
              context,
              title: 'My Reviews',
              icon: Icons.reviews,
              color: Colors.redAccent,
              routeName: MyReviewsScreen.routeName,
              // Navigate to the MyReviewsScreen.
            ),
            // Uncomment and update routes for these options if needed.
            // _buildNavigationTile(
            //   context,
            //   title: 'Admin Driver Profile',
            //   icon: Icons.person,
            //   color: Colors.blue,
            //   routeName: AdminDriverProfile.routeName,
            //   // Navigate to the AdminDriverProfile.
            // ),
            // _buildNavigationTile(
            //   context,
            //   title: 'Driver Dashboard',
            //   icon: Icons.dashboard,
            //   color: Colors.indigo,
            //   routeName: AdminDriverDashboard.routeName,
            //   // Navigate to the DriverDashboard.
            // ),
            // _buildNavigationTile(
            //   context,
            //   title: 'Driver Profile',
            //   icon: Icons.account_circle,
            //   color: Colors.deepPurple,
            //   routeName: DriverProfile.routeName,
            //   // Navigate to the DriverProfile.
            // ),
            _buildNavigationTile(
              context,
              title: 'Driver Map',
              icon: Icons.map,
              color: Colors.teal,
              routeName: Constants.wasteMapDriverRoute,
              // Navigate to the DriverProfile.
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a navigation tile with custom styling and animations.
  Widget _buildNavigationTile(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required String routeName}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () {
          // Navigate to the specified route.
          Navigator.restorablePushNamed(context, routeName);
        },
      ),
    );
  }
}
