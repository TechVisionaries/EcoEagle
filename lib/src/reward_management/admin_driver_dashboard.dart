import 'package:flutter/material.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'package:trashtrek/src/reward_management/admin_driver_profile.dart';
import 'package:trashtrek/src/user_management_feature/driverRegistration.dart';

class AdminDriverDashboard extends StatelessWidget {
  const AdminDriverDashboard({super.key});

  static const routeName = '/rewards_driverDashboard';

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
              Navigator.pushNamed(
                context,
                DriverRegistraion.routeName
              );
            },
          ),
        ],
      ),
      body: Padding(
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, // Use backgroundColor instead of primary
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  buildDriverCard(
                      '1. Allen Smith', 200, 'assets/images/driver1.webp', context),
                  buildDriverCard(
                      '2. Laura Johnson', 180, 'assets/images/driver1.webp', context),
                  buildDriverCard(
                      '3. Jaxson Williams', 150, 'assets/images/driver1.webp', context),
                  buildDriverCard('4. Lila Brown', 140, 'assets/images/driver1.webp', context),
                  buildDriverCard('5. Olivia Davis', 130, 'assets/images/driver1.webp', context),
                  const Divider(),
                  const Text(
                    'All Drivers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildDriverCard('6. Emma Miller', 100, 'assets/images/driver1.webp', context),
                  buildDriverCard('7. Liam Wilson', 90, 'assets/images/driver1.webp', context),
                  buildDriverCard('8. Ava Taylor', 80, 'assets/images/driver1.webp', context),
                  buildDriverCard('9. Noah Lee', 70, 'assets/images/driver1.webp', context),
                  buildDriverCard(
                      '10. James Martinez', 60, 'assets/images/driver1.webp', context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation.dynamicNav(context, 1, 'Admin')
    );
  }

  Widget buildDriverCard(String name, int points, String imagePath, context) {
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
