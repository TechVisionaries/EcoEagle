import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_rating_service.dart';
import 'rating_model.dart'; // Adjust the path as per your folder structure

class RateDriverScreen extends StatefulWidget {
  const RateDriverScreen({Key? key}) : super(key: key);

  static const routeName = '/rewards';

  @override
  _RateDriverScreenState createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  int ratingPoints = 0;
  final TextEditingController _reviewController = TextEditingController();
  final RatingService ratingService = RatingService();

  Future<void> _submitRating() async {
    // Dummy IDs for driver and resident; replace with actual IDs from your app logic
    final prefs = await SharedPreferences.getInstance();
    final residentId = prefs.getString("userID") ?? 'defaultResidentId';
    const String driverId = 'driver123';

    Rating rating = Rating(
      id: '', 
      driverId: driverId,
      residentId: residentId,
      points: ratingPoints,
      reviewText: _reviewController.text,
      createdAt: DateTime.now(),
    );

    try {
      await ratingService.submitRating(rating);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted successfully!')),
      );
      setState(() {
        ratingPoints = 0;
        _reviewController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Rate Your Driver',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://via.placeholder.com/150'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ramon Watson',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Text(
                'Driver',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < ratingPoints ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        ratingPoints = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your pickup experience',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation based on the tapped item
        },
      ),
    );
  }
}
