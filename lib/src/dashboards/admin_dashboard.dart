import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';

/// Displays a list of options for navigation with a beautified UI for the admin dashboard.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  static const routeName = Constants.adminDashboardRoute;

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
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
          child: Expanded(
            child: Container(
                color: Colors
                    .transparent, // Keep it transparent to show the gradient
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
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
                        Navigator.pushNamed(context, Constants.userReportRoute);
                      },
                      child: Text(
                        'Get Started!',
                        softWrap: true,
                        style: GoogleFonts.alike(),
                      ),
                    )
                  ],
                )),
          ),
        ),
        bottomNavigationBar:
            CustomBottomNavigation.dynamicNav(context, 0, 'Admin'));
  }
}
