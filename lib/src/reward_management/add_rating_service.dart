import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'rating_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingService {
  final String baseUrl;

  RatingService()
      : baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

  // Method to submit rating for a driver
  Future<Rating> submitRating(Rating rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/reward/review'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'driverId': rating.driverId,
          'rating': rating.points,
          'comment': rating.reviewText,
          'date': rating.createdAt.toIso8601String(),
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['reward'] != null) {
          return Rating.fromJson(
              data['reward']); 
        } else {
          throw Exception('No reward data found in the response');
        }
      } else {
        throw Exception(
            'Failed to submit rating. Status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // Method to fetch driver name by driver ID
  Future<String> fetchDriverName(String driverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile/$driverId'), // Updated URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetch Driver Name Status code: ${response.statusCode}');
      print('Fetch Driver Name Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Driver data: $data');
        // Assuming the driver's name is structured as follows
        String firstName = data['user']['firstName'] ?? 'Unknown';
        String lastName = data['user']['lastName'] ?? 'Driver';
        return '$firstName $lastName';
      } else {
        throw Exception(
            'Failed to fetch driver name. Status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching driver name: $e');
      rethrow;
    }
  }

}
