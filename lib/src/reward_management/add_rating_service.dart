import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'rating_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingService {
  final String baseUrl;

  RatingService()
      : baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

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
        return Rating.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to submit rating. Status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
