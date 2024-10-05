import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
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
  final AdminDriverDashboardService ratingService =
      AdminDriverDashboardService();

  @override
  void initState() {
    super.initState();
    futureDriverRatings = _fetchDriverRatings();
  }

  Future<List<Rating>> _fetchDriverRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No authentication token found.');
    }

    return await AdminDriverDashboardService().fetchDriverRatings(token);
  }

  // Method to generate report
  void _generateReport(List<Rating> topDrivers) {
    String reportContent = "Top 5 Drivers Report:\n\n";
    for (var driver in topDrivers) {
      reportContent +=
          'Driver Name: ${driver.driverId}, Points: ${driver.totalPoints}\n';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Driver Report"),
        content: SingleChildScrollView(
          child: Text(reportContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
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
                          _generateReport(topDrivers);
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
                          FutureBuilder<String>(
                            future: ratingService
                                .fetchDriverName(driver.driverId.toString()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return buildDriverCard(
                                  'Loading name...',
                                  driver.totalPoints,
                                  'assets/images/profile.png',
                                  context,
                                );
                              } else if (snapshot.hasError) {
                                return buildDriverCard(
                                  'Error loading name',
                                  driver.totalPoints,
                                  'assets/images/profile.png',
                                  context,
                                );
                              } else {
                                return buildDriverCard(
                                  '${driver.rank}. ${snapshot.data}',
                                  driver.totalPoints,
                                  'assets/images/profile.png',
                                  context,
                                );
                              }
                            },
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
                          FutureBuilder<String>(
                            future: ratingService
                                .fetchDriverName(driver.driverId.toString()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return buildDriverCard(
                                  'Loading name...',
                                  driver.totalPoints,
                                  'assets/images/profile.png',
                                  context,
                                );
                              } else if (snapshot.hasError) {
                                return buildDriverCard(
                                  'Error loading name',
                                  driver.totalPoints,
                                  'assets/images/profile.png',
                                  context,
                                );
                              } else {
                                return buildDriverCard(
                                  '${driver.rank}. ${snapshot.data}',
                                  driver.totalPoints,
                                  'assets/images/profile.png',
                                  context,
                                );
                              }
                            },
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
          arguments: widget.driverId,
        );
      },
    );
  }
}
