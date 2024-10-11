import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'package:trashtrek/src/user_management_feature/userProfile.dart'; // Import the user profile page

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  static const routeName = '/rewards';

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  String? _username;

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('userID');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfile()),
    );
  }

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
              Navigator.pushNamed(context, Constants.userProfileRoute);
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
                        Navigator.pushNamed(
                            context, Constants.wasteMapDriverRoute);
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
            CustomBottomNavigation.dynamicNav(context, 0, 'Driver'));
  }

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
