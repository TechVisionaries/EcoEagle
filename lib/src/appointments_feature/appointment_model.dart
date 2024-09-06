class Appointment {
  final String? id; // Optional, typically assigned by backend
  final String date;
  final Map<String, String> address; // Address field as a Map
  final String status;

  Appointment({
    this.id,
    required this.date,
    required this.address,
    required this.status,
  });

  // Method to convert JSON data to an Appointment object
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String?,
      date: json['date'] as String,
      address: Map<String, String>.from(
          json['address'] as Map), // Convert to Map<String, String>
      status: json['status'] as String,
    );
  }

  // Method to convert an Appointment object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
