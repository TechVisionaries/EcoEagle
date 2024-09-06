import 'dart:convert';
import 'package:http/http.dart' as http;
import 'appointment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl =
      'http://10.0.2.2:8080/api'; // Consider moving this to a config file

  Future<List<Appointment>> fetchAppointments(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/appointments/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return Appointment.listFromJson(data);
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/appointments'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(appointment.toJson()),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 201) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to create appointment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the error or handle it appropriately
      throw Exception('Failed to create appointment: $e');
    }
  }

  Future<bool> hasAppointment(String date) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/appointments?date=$date'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.isNotEmpty;
      } else {
        throw Exception(
            'Failed to check appointment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to check appointment: $e');
    }
  }

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userID');
    return userId;
  }

  Future<void> cancelAppointment(int appointmentId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/appointments/$appointmentId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': 'cancelled'}),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to cancel appointment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }
}
