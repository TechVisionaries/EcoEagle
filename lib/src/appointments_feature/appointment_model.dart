import 'package:google_maps_flutter/google_maps_flutter.dart';

class Appointment {
  final String? id;
  final String? userId;
  final String date;
  final LatLng location;
  String status;
  String? driver;
  List<String> garbageTypes;

  Appointment({
    this.id,
    required this.userId,
    required this.date,
    required this.location,
    required this.status,
    this.driver,
    List<String>? garbageTypes, // Nullable list
  }) : garbageTypes = garbageTypes ?? []; // Default to an empty list if null

  // Factory method to convert JSON into an Appointment object
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      date: json['date'] as String,
      location: LatLng(
        json['location']['latitude'] as double,
        json['location']['longitude'] as double,
      ),
      status: json['status'] as String,
      driver: json['driver'] as String?,
      garbageTypes: json['garbageTypes'] != null
          ? List<String>.from(json['garbageTypes'] as List<dynamic>)
          : [],
    );
  }

  // Method to convert an Appointment object into JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'status': status,
      'driver': driver,
      'garbageTypes': garbageTypes, // Properly include garbageTypes in the request
    };
  }

  // Static method to create a list of Appointment objects from a JSON list
  static List<Appointment> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
