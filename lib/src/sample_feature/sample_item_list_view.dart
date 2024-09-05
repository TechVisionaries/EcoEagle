import 'package:flutter/material.dart';

import '../reward_management/screens/add_rating_view.dart';
import '../reward_management/screens/admin_driver_dashboard.dart';
import '../reward_management/screens/admin_driver_profile.dart';
import '../reward_management/screens/driver_profile.dart';
import '../reward_management/screens/view_reviews.dart';
import '../settings/settings_view.dart';
import '../appointments_feature/schedule_appointment_view.dart'; // Import ScheduleAppointmentView
import '../appointments_feature/my_appointments_view.dart'; // Import MyAppointmentsView

/// Displays a list of options for navigation.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({super.key});

  static const routeName = '/ddasad';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Options'),
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
      body: ListView(
        restorationId: 'sampleItemListView',
        children: [
          ListTile(
            title: const Text('Schedule Appointment'),
            leading: const Icon(Icons.schedule),
            onTap: () {
              // Navigate to the ScheduleAppointmentView.
              Navigator.restorablePushNamed(
                context,
                ScheduleAppointmentView.routeName,
              );
            },
          ),
          ListTile(
            title: const Text('My Appointments'),
            leading: const Icon(Icons.assignment),
            onTap: () {
              // Navigate to the MyAppointmentsView.
              Navigator.restorablePushNamed(
                context,
                MyAppointmentsView.routeName,
              );
            },
          ),
          ListTile(
            title: const Text('Rate Driver'),
            leading: const Icon(Icons.rate_review),
            onTap: () {
              // Navigate to the RateDriverScreen.
              Navigator.restorablePushNamed(
                context,
                RateDriverScreen.routeName,
              );
            },
          ),
          ListTile(
            title: const Text('My Reviews'),
            leading: const Icon(Icons.reviews),
            onTap: () {
              // Navigate to the MyReviewsScreen.
              Navigator.restorablePushNamed(
                context,
                MyReviewsScreen.routeName,
              );
            },
          ),
          ListTile(
            title: const Text('Admin Driver Profile'),
            leading: const Icon(Icons.person),
            onTap: () {
              // Navigate to the AdminDriverProfile.
              Navigator.restorablePushNamed(
                context,
                AdminDriverProfile.routeName,
              );
            },
          ),
          ListTile(
            title: const Text('Driver Dashboard'),
            leading: const Icon(Icons.dashboard),
            onTap: () {
              // Navigate to the DriverDashboard.
              Navigator.restorablePushNamed(
                context,
                AdminDriverDashboard.routeName,
              );
            },
          ),
          ListTile(
            title: const Text('Driver Profile'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              // Navigate to the DriverProfile.
              Navigator.restorablePushNamed(
                context,
                DriverProfile.routeName,
              );
            },
          ),
        ],
      ),
    );
  }
}
