import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import '../appointments_feature/screens/schedule_appointment_view.dart'; // Import ScheduleAppointmentView
import '../appointments_feature/screens/my_appointments_view.dart'; // Import MyAppointmentsView

/// Displays a list of options for navigation.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({super.key});

  static const routeName = '/';

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
        ],
      ),
    );
  }
}
