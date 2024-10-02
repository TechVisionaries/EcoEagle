import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AdminDriverDashboardService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

  Future<List<dynamic>> fetchDriverPoints(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reward/drivers/points'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['drivers']; // Return the list of drivers
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      print('Error fetching driver points: $e');
      rethrow;
    }
  }
}
