import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'add_rating_service.dart';
import 'rating_model.dart';
import 'package:trashtrek/common/constants.dart'; // Import the constants for route names

class RateDriverScreen extends StatefulWidget {
  final String driverId;

  const RateDriverScreen({
    super.key,
    required this.driverId,
  });

  static const routeName = '/rewards';

  @override
  _RateDriverScreenState createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  int ratingPoints = 0;
  String driverName = 'Fetching...';
  final TextEditingController _reviewController = TextEditingController();
  final RatingService ratingService = RatingService();

  @override
  void initState() {
    super.initState();
    _fetchDriverName();
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

  Future<void> _submitRating() async {
    // Validation
    if (ratingPoints == 0) {
      _showSnackBar('Please select a rating.');
      return;
    }
    if (_reviewController.text.isEmpty) {
      _showSnackBar('Please enter a review.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final residentId = prefs.getString("userID") ?? 'defaultResidentId';

    Rating rating = Rating(
      id: '',
      driverId: widget.driverId,
      residentId: residentId,
      resident_name: null,
      points: ratingPoints,
      reviewText: _reviewController.text,
      createdAt: DateTime.now(),
      rank: null,
      totalPoints: 0,
    );

    try {
      await ratingService.submitRating(rating);
      _showSnackBar('Rating submitted successfully!', success: true);
      setState(() {
        ratingPoints = 0;
        _reviewController.clear();
      });
    } catch (e) {
      _showSnackBar('Failed to submit rating: $e');
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar('Rate Your Driver'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
              const SizedBox(height: 16),
              Text(
                driverName,
                style: const TextStyle(
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
                      Navigator.pushReplacementNamed(
                          context, Constants.residentDashboardRoute);
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
    );
  }
}
