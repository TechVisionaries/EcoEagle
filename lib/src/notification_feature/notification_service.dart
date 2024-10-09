import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/notification_feature/notification_model.dart';

class NotificationService {
  final baseUrl =
  dotenv.env[Constants.baseURL];


  Future<bool> notify(PushNotification notification) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/notify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(notification.toJson()),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        // Handle success
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

}
