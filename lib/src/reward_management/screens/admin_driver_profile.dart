import 'package:flutter/material.dart';

class AdminDriverProfile extends StatelessWidget {
  const AdminDriverProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/ramon.jpg'), // replace with actual image asset
              ),
              SizedBox(height: 16),
              Text(
                "Ramon Watson",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Driver",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Ranking: 1st, Points: 1234',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle assign action
                },
                child: Text('Assign'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Replaces `primary`
                  foregroundColor: Colors.white, // Replaces `onPrimary`
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),

              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
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
        items: [
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
        "image": "assets/mia.jpg" // replace with actual image asset
      },
      {
        "name": "Noah White",
        "date": "Mar 12, 2023",
        "rating": 4,
        "review": "Very professional and on time.",
        "image": "assets/noah.jpg" // replace with actual image asset
      },
      {
        "name": "Ava Moore",
        "date": "Apr 22, 2023",
        "rating": 5,
        "review": "Excellent service, will use again.",
        "image": "assets/ava.jpg" // replace with actual image asset
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review['date'],
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.black,
                      size: 20,
                    );
                  }),
                ),
                SizedBox(height: 4),
                Text(review['review']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
