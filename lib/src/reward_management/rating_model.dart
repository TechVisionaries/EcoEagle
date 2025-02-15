class Rating {
  final String id;
  final String? driverId; // Optional driverId
  final String residentId; // userId in backend
  final int points; // rating in backend
  final String reviewText; // comment in backend
  final DateTime createdAt; // date in backend
  final int? rank; // Optional rank
  final int totalPoints; // totalPoints for the driver
  final String? resident_name;

  Rating({
    required this.id,
    this.driverId,
    required this.residentId,
    required this.points,
    required this.reviewText,
    required this.createdAt,
    this.rank, // Optional rank field
    required this.totalPoints,
    required this.resident_name, // totalPoints for the driver
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      driverId: json['driverId'],
      residentId: json['userId']?['_id'] ?? '',
      resident_name: json['residentName'],
      points: json['rating'] ?? 0, // rating from backend
      reviewText: json['comment'] ?? '', // comment from backend
      createdAt: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      rank: json['rank'], // rank from backend
      totalPoints: json['totalPoints'] ?? 0, // totalPoints from backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'driverId': driverId,
      'userId': residentId,
      'rating': points,
      'comment': reviewText, // Review text as comment
      'date': createdAt.toIso8601String(),
      'rank': rank, // Include rank if available
      'totalPoints': totalPoints, // Include totalPoints
    };
  }
}
