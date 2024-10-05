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

  // get all appointments
  Future<List<Appointment>> fetchAllAppointments() async {
    final response = await http.get(Uri.parse('$baseUrl/appointments'));

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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        // Handle success
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to create appointment. Status code: ${response
                .statusCode}');
      }
    } catch (e) {
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
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to cancel appointment. Status code: ${response
                .statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  Future<List<Appointment>> fetchDriverAppointments(String userId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/appointments/driver/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return Appointment.listFromJson(data);
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/appointments/complete/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to cancel appointment. Status code: ${response
                .statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  Future<String?> getTownFromCoordinates(double latitude, double longitude) async {
    final apiKey = dotenv.env[Constants.googleApiKey];
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Print the full API response for debugging
      print('Google API Response: $data');

      if (data['results'].isNotEmpty) {
        // Loop through each result
        for (var result in data['results']) {
          for (var component in result['address_components']) {
            if (component['types'].contains('locality')) {
              print('Fetched City/Town: ${component['long_name']}');
              return component['long_name']; // Return the found locality
            }
          }
        }
      }
    } else {
      print('Failed to fetch data from Google API, Status Code: ${response.statusCode}');
    }

    return null; // Return null if no locality is found
  }

//   get driver id based on city
  Future<String> fetchDriverIDByCity(String city) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$city'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> usersResponse = json.decode(response.body);
      final List<dynamic> usersInCity = usersResponse['users'];

      if (usersInCity.isNotEmpty) {
        // Assuming you want to return the first user's _id
        return usersInCity[0]['_id'];
      } else {
        throw Exception('No drivers found in this city');
      }
    } else {
      throw Exception('Failed to load users');
    }
  }







}
