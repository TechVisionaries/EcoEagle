import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DeleteReviewService {
  final String baseUrl = dotenv.env['BASE_URL'] ??
      'http://10.0.2.2:8080/api'; // Use 10.0.2.2 for Android emulator

  Future<void> deleteReview(String reviewId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reward/review/$reviewId'), // Correct URL
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Review deleted successfully');
      } else {
        throw Exception('Failed to delete review: ${response.body}');
      }
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }
}
