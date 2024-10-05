import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'package:trashtrek/src/reward_management/add_rating_service.dart';
import 'package:trashtrek/src/reward_management/driver_profile_service.dart';
import 'package:trashtrek/src/reward_management/rating_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DriverProfile extends StatefulWidget {
  const DriverProfile(
      {super.key, required this.driverId, required this.residentId});

  final String driverId;
  final String residentId;

  static const routeName = '/rewards_DriverProfile';

  @override
  _DriverProfileState createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  String? _driverid;
  int points = 0;
  int rank = 0;
  List<Rating> reviews = [];
  bool isLoading = true;
  String errorMessage = '';
  String driverName = 'Unknown Driver';
  String residentName = 'Unknown Resident';

  final RatingService _ratingService = RatingService();
  final DriverProfileService _driverProfileService = DriverProfileService();

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
    _fetchDriverName();
    _fetchResidentName();
  }

  Future<void> _fetchDriverName() async {
    final prefs = await SharedPreferences.getInstance();
    _driverid = prefs.getString('userID');
    try {
      String name = await _ratingService.fetchDriverName(_driverid!);
      setState(() {
        driverName = name;
      });
    } catch (e) {
      setState(() {
        driverName = 'Unknown Driver';
      });
    }
  }

  Future<void> _fetchResidentName() async {
    final prefs = await SharedPreferences.getInstance();
    _driverid = prefs.getString('userID');
    try {
      String name = await _driverProfileService.fetchResidentName(_driverid!);
      setState(() {
        residentName = name;
      });
    } catch (e) {
      setState(() {
        residentName = 'Unknown Resident';
      });
    }
  }

  Future<void> _fetchDriverProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found.');
      }

      final profileData = await _driverProfileService.fetchDriverProfile(token);
      setState(() {
        points = profileData['points'];
        rank = profileData['rank'];

        // Retrieve reviews and sort them by createdAt in descending order
        reviews = List<Rating>.from(profileData['reviews'])
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar('My Profile'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/profile.png'),
                        radius: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rank $rank · $points points',
                        style: const TextStyle(
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
                        child: ListView.builder(
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return _buildReviewTile(
                              review.resident_name.toString(),
                              review.createdAt,
                              review.points,
                              review.reviewText,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar:
          CustomBottomNavigation.dynamicNav(context, 2, 'Driver'),
    );
  }

  ListTile _buildReviewTile(
      String reviewer, DateTime createdAt, int stars, String comment) {
    return ListTile(
      title: Text(reviewer),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('dd/MM/yy').format(createdAt)),
          const SizedBox(height: 4),
          RatingBarIndicator(
            rating: stars.toDouble(),
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 20.0,
            direction: Axis.horizontal,
          ),
          const SizedBox(height: 4),
          Text(comment),
        ],
      ),
    );
  }
}
