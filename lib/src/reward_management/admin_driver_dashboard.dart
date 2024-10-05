import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'package:trashtrek/src/reward_management/admin_driver_profile.dart';
import 'package:trashtrek/src/user_management_feature/driverRegistration.dart';
import 'admin_driver_dashboard_service.dart';
import 'rating_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

    return await ratingService.fetchDriverRatings(token);
  }

  void _generateReport(List<Rating> topDrivers) async {
    final pdf = pw.Document();

    // Adding a title and top drivers table
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Top 5 Drivers Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Rank', 'Driver Name', 'Total Points'],
              data: topDrivers.map((driver) {
                // Fetch the driver name instead of using driverId
                return [
                  driver.rank.toString(),
                  driver.driverId
                      .toString(), // Replace with driverName if available
                  driver.totalPoints.toString(),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );

    // Save the PDF to the Downloads directory
    final outputDir =
        await getExternalStorageDirectory(); // Get external directory
    final downloadsDir = Directory("${outputDir!.path}/Download");
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    final file = File(
        '${downloadsDir.path}/top_drivers_report.pdf'); // Specify the filename
    await file.writeAsBytes(await pdf.save());

    print("PDF saved to: ${file.path}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF Report Generated: ${file.path}')),
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
                          backgroundColor: const Color.fromARGB(
                              255, 69, 189, 71), // Change button color here
                          foregroundColor:
                              Colors.white, // Change text color here
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
                          FutureBuilder<String?>(
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
                                final driverName =
                                    snapshot.data ?? 'Unknown Driver';
                                return buildDriverCard(
                                  '${driver.rank}. $driverName',
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
                          FutureBuilder<String?>(
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
                                final driverName =
                                    snapshot.data ?? 'Unknown Driver';
                                return buildDriverCard(
                                  '${driver.rank}. $driverName',
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
