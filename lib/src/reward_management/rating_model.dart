import 'package:flutter/foundation.dart';

class Rating {
  final String id; // ID of the rating record
  final String driverId; // ID of the driver being rated
  final String residentId; // ID of the resident giving the rating
  final int points; // Rating points given to the driver
  final String reviewText; // Review text given by the resident
  final DateTime createdAt; // Timestamp of when the review was created

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
      id: json['_id'] ?? '', // Default to an empty string if not provided
      driverId:
          json['driver'] ?? '', // Default to an empty string if not provided
      residentId:
          json['resident'] ?? '', // Default to an empty string if not provided
      points: json['points'] ?? 0, // Default to 0 if not provided
      reviewText: json['reviewText'] ??
          '', // Default to an empty string if not provided
      createdAt: DateTime.parse(json['createdAt'] ??
          DateTime.now().toString()), // Parse date or use current time
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
