import 'dart:convert';
import 'package:http/http.dart' as http;
import 'appointment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trashtrek/common/constants.dart';

class ApiService {
  final baseUrl =
      dotenv.env[Constants.baseURL]; // Consider moving this to a config file

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
    if (appointment.latitude == null || appointment.longitude == null) {
      throw Exception('Latitude and longitude must not be null');
    }

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

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userID');
    return userId;
  }

  Future<bool> hasAppointment(String date) async {
    final userId = await getUserId();
    final response =
        await http.get(Uri.parse('$baseUrl/appointments/$userId?date=$date'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Appointment> appointments = Appointment.listFromJson(data);

      return appointments.any((appointment) => appointment.date == date);
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/appointments/$appointmentId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': 'cancelled'}),
          )
          .timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to cancel appointment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }
}
