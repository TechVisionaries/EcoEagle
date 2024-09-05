import 'dart:convert';
import 'package:http/http.dart' as http;
import 'rating_model.dart'; // Replace with the actual path to your Rating model

class RatingService {
  final String baseUrl =
      'http://localhost:8080/api/reward/review'; // Update with your actual backend URL


  // Submit a new rating
  Future<Rating> submitRating(Rating rating) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rewards/review'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(rating.toJson()),
    );

    if (response.statusCode == 201) {
      return Rating.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to submit rating');
    }
  }
}
