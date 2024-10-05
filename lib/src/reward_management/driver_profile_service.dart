import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'rating_model.dart';

class DriverProfileService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

  Future<Map<String, dynamic>> fetchDriverProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reward/driver/points'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'points': data['points'],
          'rank': data['rank'],
          'reviews': (data['reviews'] as List)
              .map((json) => Rating.fromJson(json))
              .toList(),
        };
      } else {
        throw Exception('Failed to load driver profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching driver profile: $e');
      rethrow;
    }
  }

  // Method to fetch driver name by driver ID
  Future<String> fetchResidentName(String driverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/reward/profile/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetch resident Name Status code: ${response.statusCode}');
      print('Fetch resident Name Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('resident data: $data');
        // Assuming the resident's name is structured as follows
        String firstName = data['user']['firstName'] ?? 'Unknown';
        String lastName = data['user']['lastName'] ?? 'Resident';
        return '$firstName $lastName';
      } else {
        throw Exception(
            'Failed to fetch resident name. Status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching resident name: $e');
      rethrow;
    }
  }
}
