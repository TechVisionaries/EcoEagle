class Rating {
  final String id;
  final String? driverId; 
  final String residentId;
  final int points;
  final String reviewText;
  final DateTime createdAt;

  Rating({
    required this.id,
    this.driverId, // Optional driverId
    required this.residentId,
    required this.points,
    required this.reviewText,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      driverId: json['driverId'], 
      residentId: json['userId']?['_id'] ?? '', // Extracting from userId
      points: json['rating'] ?? 0,
      reviewText: json['comment'] ?? '',
      createdAt: DateTime.parse(json['date'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'driverId': driverId, // Nullable
      'userId': {'_id': residentId}, // Assuming userId is an object
      'rating': points,
      'comment': reviewText,
      'date': createdAt.toIso8601String(),
    };
  }
}
