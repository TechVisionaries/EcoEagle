import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'package:trashtrek/src/reward_management/add_rating_service.dart';
import 'package:trashtrek/src/reward_management/admin_driver_profile.dart';
import 'package:trashtrek/src/user_management_feature/driverRegistration.dart';
import 'admin_driver_dashboard_service.dart';
import 'rating_model.dart';

class AdminDriverDashboard extends StatefulWidget {
  final String driverId;

  const AdminDriverDashboard({super.key, required this.driverId});

  static const routeName = '/rewards_driverDashboard';

  @override
  _AdminDriverDashboardState createState() => _AdminDriverDashboardState();
}

class _AdminDriverDashboardState extends State<AdminDriverDashboard> {
  late Future<List<Rating>> futureDriverRatings;
  String driverName = 'Loading...';
  final RatingService ratingService = RatingService(); 
  @override
  void initState() {
    super.initState();
    _fetchDriverName();
    futureDriverRatings = _fetchDriverRatings();
  }

  Future<void> _fetchDriverName() async {
    try {
      String name = await ratingService.fetchDriverName(widget.driverId); 
      setState(() {
        driverName = name;
      });
    } catch (e) {
      setState(() {
        driverName = 'Unknown Driver';
      });
    }
  }

  Future<List<Rating>> _fetchDriverRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No authentication token found.');
    }

    return await AdminDriverDashboardService().fetchDriverRatings(token);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Rating>>(
          future: futureDriverRatings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No drivers found.'));
            } else {
              final driverRatings = snapshot.data!;
              final topDrivers = driverRatings.take(5).toList();
              final allDrivers = driverRatings.skip(5).toList();

              return Column(
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
                          // Implement reset functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Report'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        for (var driver in topDrivers)
                          buildDriverCard(
                            '${driver.rank}. ${driver.driverId}', 
                            driver.totalPoints,
                            'assets/images/profile.png',
                            context,
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
                        for (var driver in allDrivers)
                          buildDriverCard(
                            '${driver.rank}. ${driver.driverId}', 
                            driver.totalPoints,
                            'assets/images/profile.png',
                            context,
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
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
        Navigator.restorablePushNamed(
          context, 
          AdminDriverProfile.routeName,
          arguments: {'driverId': widget.driverId},
        );
      },
    );
  }
}
