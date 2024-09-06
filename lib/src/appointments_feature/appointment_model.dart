class Appointment {
  final String? userId; // Optional, typically assigned by backend
  final String date;
  final Map<String, String> address; // Address field as a Map
  String status;

  Appointment({
    required this.userId,
    required this.date,
    required this.address,
    required this.status,
  });

  // Method to convert JSON data to an Appointment object
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      userId: json['userId'] as String?, // Safely cast userId
      date: json['date'] as String, // Safely cast date
      address: json['address'] != null
          ? Map<String, String>.from(
              json['address'] as Map) // Convert to Map<String, String>
          : {}, // Default to empty map if address is null
      status: json['status'] as String, // Safely cast status
    );
  }

  // Method to convert an Appointment object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date,
      'address': address, // Convert Map<String, String> to JSON map
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
