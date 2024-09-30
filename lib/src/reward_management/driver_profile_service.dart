import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
        print('Fetched driver profile: $data');
        return {
          'points': data['points'],
          'rank': data['rank'],
          'reviews': (data['reviews'] as List).map((json) => Rating.fromJson(json)).toList(),
        };
      } else {
        throw Exception('Failed to load driver profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching driver profile: $e');
      rethrow;
    }
  }
}
