import 'package:flutter/material.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
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
                  buildDriverCard('1. Allen Smith', 200, 'assets/images/driver1.webp'),
                  buildDriverCard(
                      '2. Laura Johnson', 180, 'assets/driver1.png'),
                  buildDriverCard(
                      '3. Jaxson Williams', 150, 'assets/driver1.png'),
                  buildDriverCard('4. Lila Brown', 140, 'assets/driver1.png'),
                  buildDriverCard('5. Olivia Davis', 130, 'assets/driver1.png'),
                  const Divider(),
                  const Text(
                    'All Drivers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildDriverCard('6. Emma Miller', 100, 'assets/driver1.png'),
                  buildDriverCard('7. Liam Wilson', 90, 'assets/driver1.png'),
                  buildDriverCard('8. Ava Taylor', 80, 'assets/driver1.png'),
                  buildDriverCard('9. Noah Lee', 70, 'assets/driver1.png'),
                  buildDriverCard(
                      '10. James Martinez', 60, 'assets/driver1.png'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping), label: 'Drivers'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget buildDriverCard(String name, int points, String imagePath) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imagePath),
      ),
      title: Text(name),
      subtitle: Text('Total Points: $points'),
    );
  }
}

