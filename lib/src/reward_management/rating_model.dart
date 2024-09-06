import 'package:flutter/foundation.dart';

class Rating {
  final String id;
  final String driverId; // This field might be omitted if not used
  final String residentId;
  final int points;
  final String reviewText;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.driverId,
    required this.residentId,
    required this.points,
    required this.reviewText,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      driverId:
          json['driverId'] ?? '', // This field might be omitted if not used
      residentId: json['userId']['_id'] ?? '', // Extracting from userId
      points: json['rating'] ?? 0,
      reviewText: json['comment'] ?? '',
      createdAt: DateTime.parse(json['date'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'driverId': driverId,
      'userId': {'_id': residentId}, // If needed
      'rating': points,
      'comment': reviewText,
      'date': createdAt.toIso8601String(),
    };
  }
}
