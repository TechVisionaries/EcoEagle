import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'rating_model.dart';

class ViewReviewsService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

  Future<List<Rating>> fetchUserReviews(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reward/reviews/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['reviews'];
        print('Fetched reviews: $data');
        return (data as List).map((json) => Rating.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      rethrow;
    }
  }
}
