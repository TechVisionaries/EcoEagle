import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';

class MapRoute {
  final String driver;
  final List<LatLng> locations; 
  final List<MapAppointment> appointments;
  final List<Instruction> instructions;
  final String status;

  MapRoute({
    required this.driver,
    required this.locations,
    required this.appointments,
    required this.instructions,
    required this.status,
  });

  // Factory method to convert JSON into MapRoute object
  factory MapRoute.fromJson(Map<String, dynamic> json) {
    // Parsing appointments from JSON
    List<MapAppointment> appts = json['appointments'] as List<MapAppointment>;

    // Extracting locations from appointments
    List<LatLng> locs = [];
    for (var appointment in appts) {
      locs.add(
        appointment.location
      );
    }

    return MapRoute(
      driver: json['driver'] as String,
      locations: locs, // Locations extracted from appointments
      appointments: appts, // Properly parsed appointments
      instructions: json['instructions'] as List<Instruction>,
      status: json['status'] as String,
    );
  }

  // Method to convert MapRoute object into JSON
  Map<String, dynamic> toJson() {
    return {
      'driver': driver,
      'locations': locations
          .map((loc) => {'latitude': loc.latitude, 'longitude': loc.longitude})
          .toList(),
      'instructions': instructions.map((instruction) => instruction.toJson()).toList(),
      'appointments': appointments.map((appointment) => appointment.toJson()).toList(),
      'status': status,
    };
  }
}

class MapAppointment extends Appointment{
  final String address;
  final String duration;
  final String distance;
  final String? comment;
  final int durationValue;
  final int distanceValue;

  MapAppointment({
    required super.userId, 
    required super.date, 
    required super.location, 
    required super.status,
    super.driver,
    super.id,
    required this.address,
    required this.duration,
    required this.distance,
    required this.durationValue,
    required this.distanceValue,
    this.comment,
  });

  factory MapAppointment.fromJson(Map<String, dynamic> json) {
    return MapAppointment(
      userId: json['userId'] as String?,
      id: json['id'] as String?,
      date: json['date'] as String,
      address: json['address'] as String,
      duration: json['duration'] as String,
      distance: json['distance'] as String,
      durationValue: json['durationValue'] as int,
      distanceValue: json['distanceValue'] as int,
      location: LatLng(
        json['location']['latitude'] as double,
        json['location']['longitude'] as double,
      ),
      status: json['status'] as String,
      driver: json['driver'] as String?,
      comment: json['comment'] as String?,
    );
  }

  @override
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
      'address': address,
      'duration': duration,
      'distance': distance,
      'durationValue': durationValue,
      'distanceValue': distanceValue,
      'comment': comment,
    };
  }

  // Static method to create a list of Appointment objects from a JSON list
  static List<MapAppointment> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => MapAppointment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

}

class Instruction {
  final String instruction;
  final LatLng location;
  final String distance;
  final String duration;
  final int distanceValue;
  final int durationValue;
  bool isCompleted;

  Instruction({
    required this.instruction, 
    required this.location, 
    required this.distance, 
    required this.duration, 
    required this.distanceValue, 
    required this.durationValue,
    this.isCompleted = false,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) {
    return Instruction(
      instruction: json['instruction'] as String, 
      location: LatLng(
        json['location']['latitude'] as double,
        json['location']['longitude'] as double,
      ),
      distance: json['distance'] as String,
      duration: json['duration'] as String,
      distanceValue: json['distanceValue'] as int,
      durationValue: json['durationValue'] as int,
      isCompleted: json['isCompleted'] as bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'duration': duration,
      'distance': distance,
      'durationValue': durationValue,
      'distanceValue': distanceValue,
      'isCompleted': isCompleted
    };
  }
}