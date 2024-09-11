import 'package:flutter/material.dart';

class DriverProfile extends StatelessWidget {
  const DriverProfile({super.key});

  static const routeName = '/rewards_DriverProfile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/driver1.webp'), // Add the correct path to the profile image
              radius: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ethan Warner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Rank 8 · 275 points',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All Reviews',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildReviewTile('Mia Johnson', 'Jan 2023', 5,
                      'Ethan is the best driver!'),
                  _buildReviewTile('Ava Brown', 'Dec 2022', 4,
                      'Fast delivery, great service.'),
                  _buildReviewTile('Olivia Smith', 'Nov 2022', 4,
                      'Great experience, thank you Ethan!'),
                  _buildReviewTile('Sophia Miller', 'Oct 2022', 5,
                      'Delivered on time and very polite.'),
                  _buildReviewTile('Evelyn Davis', 'Sep 2022', 5,
                      'Very professional and fast delivery.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Reviews'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 2, // Profile is selected by default
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  ListTile _buildReviewTile(
      String reviewer, String date, int stars, String comment) {
    return ListTile(
      title: Text(reviewer),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(comment),
        ],
      ),
    );
  }
}
