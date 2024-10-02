import 'package:flutter/material.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'package:trashtrek/src/reward_management/admin_driver_profile.dart';
import 'package:trashtrek/src/user_management_feature/driverRegistration.dart';
import 'admin_driver_dashboard_service.dart'; // Import your service

class AdminDriverDashboard extends StatefulWidget {
  const AdminDriverDashboard({super.key});

  static const routeName = '/rewards_driverDashboard';

  @override
  _AdminDriverDashboardState createState() => _AdminDriverDashboardState();
}

class _AdminDriverDashboardState extends State<AdminDriverDashboard> {
  List<dynamic> drivers = [];
  bool isLoading = true;
  String? token; // Assume you will pass the token when navigating

  @override
  void initState() {
    super.initState();
    fetchDriverPoints();
  }

  Future<void> fetchDriverPoints() async {
    final service = AdminDriverDashboardService();
    // Retrieve your token from the context or shared preferences
    token = 'YOUR_TOKEN_HERE'; // Replace this with actual token retrieval logic

    try {
      final driverData = await service.fetchDriverPoints(token!);
      setState(() {
        drivers = driverData; // Store the fetched drivers
        isLoading = false; // Update loading status
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
      print('Error fetching drivers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar(
        'Drivers',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_box_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, DriverRegistraion.routeName);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top 5 Drivers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Logic to reset points can be added here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: drivers.length,
                      itemBuilder: (context, index) {
                        // Only show top 5 drivers
                        if (index < 5) {
                          return buildDriverCard(
                            '${drivers[index]['rank']}. ${drivers[index]['firstName']} ${drivers[index]['lastName']}',
                            drivers[index]['totalPoints'],
                            'assets/images/profile.png', // You can change this to actual driver image URL if available
                            context,
                          );
                        }
                        return Container(); // No card for index >= 5
                      },
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'All Drivers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: drivers.length,
                      itemBuilder: (context, index) {
                        // Show remaining drivers starting from rank 6
                        if (index >= 5) {
                          return buildDriverCard(
                            '${drivers[index]['rank']}. ${drivers[index]['firstName']} ${drivers[index]['lastName']}',
                            drivers[index]['totalPoints'],
                            'assets/images/profile.png', // You can change this to actual driver image URL if available
                            context,
                          );
                        }
                        return Container(); // No card for index < 5
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar:
          CustomBottomNavigation.dynamicNav(context, 1, 'Admin'),
    );
  }

  Widget buildDriverCard(
      String name, int points, String imagePath, BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imagePath),
      ),
      title: Text(name),
      subtitle: Text('Total Points: $points'),
      onTap: () {
        Navigator.restorablePushNamed(context, AdminDriverProfile.routeName);
      },
    );
  }
}
