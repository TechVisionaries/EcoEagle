import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/utils/notification.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userlogtype');
    final uid = prefs.getString('userID');
    if (uid != null && uid != "") {
      await saveTokenToDatabase(uid);
    }

    await Future.delayed(const Duration(seconds: 4)); // 3-second delay

    if (userType == 'Resident') {
      Navigator.of(context)
          .pushReplacementNamed(Constants.residentDashboardRoute);
    } else if (userType == 'Driver') {
      Navigator.of(context)
          .pushReplacementNamed(Constants.driverDashboardRoute);
    } else if (userType == 'Admin') {
      Navigator.of(context).pushReplacementNamed(Constants.adminDashboardRoute);
    } else {
      Navigator.of(context).pushReplacementNamed(Constants.signInRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text(
              'EcoEagle',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'v.2.1.0',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10), // Spacing before the animation
            Lottie.asset('assets/animations/splashAnimation.json'), // Animation

            const Spacer(), // Push the powered by text to the bottom
            const Text(
              'Powered By',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const Text(
              'TechVisionries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20), // Spacing from the bottom
          ],
        ),
      ),
    );
  }
}
