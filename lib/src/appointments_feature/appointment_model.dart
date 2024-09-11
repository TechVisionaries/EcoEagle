class Appointment {
  final String? id;
  final String? userId;
  final String date;
  final Location location; // Updated field
  String status;

  Appointment({
    this.id,
    required this.userId,
    required this.date,
    required this.location, // Updated field
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      date: json['date'] as String,
      location: Location.fromJson(
          json['location'] as Map<String, dynamic>), // Updated field
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'location': location.toJson(), // Updated field
      'status': status,
    };
  }

  static List<Appointment> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
