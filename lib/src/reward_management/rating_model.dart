import 'package:flutter/foundation.dart';

class Rating {
  final String id; 
  final String driverId; 
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

  // Factory method to create a Rating instance from a JSON object
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      driverId:
          json['driver'] ?? '', 
      residentId:
          json['resident'] ?? '', 
      points: json['points'] ?? 0, 
      reviewText: json['reviewText'] ??
          '', 
      createdAt: DateTime.parse(json['createdAt'] ??
          DateTime.now().toString()), 
    );
  }

  // Method to convert a Rating instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'driver': driverId,
      'resident': residentId,
      'points': points,
      'reviewText': reviewText,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
