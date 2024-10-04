import 'package:flutter/material.dart';

class AdminDriverProfile extends StatelessWidget {
  const AdminDriverProfile({super.key});

  static const routeName = '/rewards_adminDriverProfile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/images/profile.png'), // replace with actual image asset
              ),
              const SizedBox(height: 16),
              const Text(
                "Ramon Watson",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Driver",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ranking: 1st, Points: 1234',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildReviewList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Set the default selected index
        onTap: (index) {
          // Handle navigation
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Drivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildReviewList() {
    final List<Map<String, dynamic>> reviews = [
      {
        "name": "Mia Thompson",
        "date": "Jan 31, 2023",
        "rating": 5,
        "review": "Great driver, very polite.",
        "image": "assets/images/profile.png" // replace with actual image asset
      },
      {
        "name": "Noah White",
        "date": "Mar 12, 2023",
        "rating": 4,
        "review": "Very professional and on time.",
        "image": "assets/images/profile.png" // replace with actual image asset
      },
      {
        "name": "Ava Moore",
        "date": "Apr 22, 2023",
        "rating": 5,
        "review": "Excellent service, will use again.",
        "image": "assets/images/profile.png" // replace with actual image asset
      },
    ];

    return Column(
      children: reviews.map((review) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: AssetImage(review['image']),
              radius: 30,
            ),
            title: Text(
              review['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review['date'],
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.black,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(review['review']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
