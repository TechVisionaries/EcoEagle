import 'package:flutter/material.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'package:trashtrek/src/appointments_feature/AppointmentReportPage.dart';
import 'package:trashtrek/src/user_management_feature/userReport.dart';

// Make sure to import your UserProfile page

/// Displays a list of options for navigation with a beautified UI.
class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  ReportViewState createState() => ReportViewState();
}

class ReportViewState extends State<ReportView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar('Reports'),
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
              title: 'User Reports',
              icon: Icons.report,
              color: Colors.purple,
              routeName: UserReport.routeName,
            ),
          //   add appointment report here
            _buildNavigationTile(context,
                title: "Appointment Reports",
                icon: Icons.report, 
                color: Colors.purple,
                routeName: AppointmentReportPage.routeName
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation.dynamicNav(context, 2, 'Admin')
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
