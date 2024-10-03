import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
}
