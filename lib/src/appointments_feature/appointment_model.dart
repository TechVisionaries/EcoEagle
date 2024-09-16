import 'package:google_maps_flutter/google_maps_flutter.dart';

class Appointment {
  final String? id;
  final String? userId;
  final String date;
  final LatLng location;  // Updated field
  String status;
  String? driver; // Updated field

  Appointment({
    this.id,
    required this.userId,
    required this.date,
    required this.location, // Updated field
    required this.status,
    this.driver, // Updated field
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      date: json['date'] as String,
      location: json['location'] as LatLng, // Updated field
      status: json['status'] as String,
      driver: json['driver'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'location': location, // Updated field
      'status': status,
      'driver': driver, // Updated field
    };
  }

  static List<Appointment> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
