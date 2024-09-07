class Appointment {
  final String? id; // Optional, typically assigned by backend
  final String? userId; // Optional, typically assigned by backend
  final String date;
  final Map<String, String> address; // Address field as a Map
  String status;

  Appointment({
    this.id,
    required this.userId,
    required this.date,
    required this.address,
    required this.status,
  });

  // Method to convert JSON data to an Appointment object
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] as String?, // Use '_id' instead of 'id'
      userId: json['userId'] as String?,
      date: json['date'] as String,
      address: json['address'] != null
          ? Map<String, String>.from(json['address'] as Map)
          : {},
      status: json['status'] as String,
    );
  }

  // Method to convert an Appointment object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
