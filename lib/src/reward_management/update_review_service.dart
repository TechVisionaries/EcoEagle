import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UpdateReviewService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

  Future<void> updateReview(
      String reviewId, int rating, String comment, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reward/review/$reviewId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        print('Review updated successfully');
      } else {
        throw Exception('Failed to update review: ${response.body}');
      }
    } catch (e) {
      print('Error updating review: $e');
      rethrow;
    }
  }
}
