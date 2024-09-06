import 'dart:convert';
import 'package:http/http.dart' as http;
import 'appointment_model.dart';

class ApiService {
  final String baseUrl =
      'http://10.0.2.2:8080/api'; // Consider moving this to a config file

  Future<List<Appointment>> fetchAppointments() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/appointments'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Appointment.fromJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load appointments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the error or handle it appropriately
      throw Exception('Failed to fetch appointments: $e');
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
}
