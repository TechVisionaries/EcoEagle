class Appointment {
  final String? id; // Optional, typically assigned by backend
  final String? userId; // Optional, typically assigned by backend
  final String date;
  final double latitude; // Added latitude field
  final double longitude; // Added longitude field
  String status;

  Appointment({
    this.id,
    required this.userId,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  // Method to convert JSON data to an Appointment object
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] as String?, // Use '_id' instead of 'id'
      userId: json['userId'] as String?,
      date: json['date'] as String,
      latitude: json['latitude'] as double, // Parse latitude
      longitude: json['longitude'] as double, // Parse longitude
      status: json['status'] as String,
    );
  }

  // Method to convert an Appointment object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'latitude': latitude, // Convert latitude to JSON
      'longitude': longitude, // Convert longitude to JSON
      'status': status,
    };
  }

  // Optionally, a method to create a list of appointments from JSON
  static List<Appointment> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
