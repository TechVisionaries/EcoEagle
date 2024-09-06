class Appointment {
  final String id;
  final String date;
  final String description;
  final String status;

  Appointment({
    required this.id,
    required this.date,
    required this.description,
    required this.status,
  });

  // Method to convert JSON data to an Appointment object
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      date: json['date'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
    );
  }

  // Method to convert an Appointment object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'status': status,
    };
  }

  // Optionally, a method to create a list of appointments from JSON
  static List<Appointment> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Appointment.fromJson(json)).toList();
  }
}
