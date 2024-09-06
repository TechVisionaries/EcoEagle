import 'dart:convert';
import 'package:http/http.dart' as http;
import 'appointment_model.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8080/api';

  Future<List<Appointment>> fetchAppointments() async {
    final response = await http.get(Uri.parse('$baseUrl/appointments'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Appointment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<Appointment> createAppointment(Appointment appointment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(appointment.toJson()),
    );

    if (response.statusCode == 201) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create appointment');
    }
  }
}
