import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'rating_model.dart'; // Import the Rating model

class AdminDriverDashboardService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

  Future<List<Rating>> fetchDriverRatings(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reward/drivers/points'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Map the JSON response to List<Rating>
        return List<Rating>.from(
            data['drivers'].map((driver) => Rating.fromJson(driver)));
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      print('Error fetching driver points: $e');
      rethrow;
    }
  }

  // Method to fetch driver name by driver ID
  Future<String> fetchDriverName(String driverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile/$driverId'),
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
