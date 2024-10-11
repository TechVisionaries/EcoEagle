import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';

/// Displays a list of options for navigation with a beautified UI.
class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  ResidentDashboardState createState() => ResidentDashboardState();
}

class ResidentDashboardState extends State<ResidentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar('Dashboard', actions: [
        IconButton(
          icon: const Icon(
            Icons.person,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(
              context,
              Constants.userProfileRoute,
            );
          },
        ),
      ]),
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
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Welcome to EcoEagle👋',
                  softWrap: true,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.andika(
                    textStyle: const TextStyle(
                      fontSize: 24, // Font size
                      fontWeight: FontWeight.bold, // Font weight
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                Image.asset("assets/images/homescreen.png"),
                const SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Constants.appointmentsRoute);
                  },
                  child: Text(
                    'Get Started!',
                    softWrap: true,
                    style: GoogleFonts.alike(),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 20, // Set it to the bottom right corner
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Constants.wasteAssistantRoute,
                  );
                },
                backgroundColor: Colors.green[700],
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/ai.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          CustomBottomNavigation.dynamicNav(context, 0, 'Resident'),
    );
  }
}
