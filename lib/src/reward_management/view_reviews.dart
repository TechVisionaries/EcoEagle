import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'rating_model.dart';
import 'view_reviews_service.dart';
import 'delete_review_service.dart';
import 'update_review_service.dart'; // Import the update review service

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  static const routeName = '/my-reviews';

  @override
  _ViewReviewsScreenState createState() => _ViewReviewsScreenState();
}

class _ViewReviewsScreenState extends State<MyReviewsScreen> {
  final ViewReviewsService _viewReviewsService = ViewReviewsService();
  final DeleteReviewService _deleteReviewService = DeleteReviewService();
  final UpdateReviewService _updateReviewService =
      UpdateReviewService(); // Initialize update review service
  late Future<List<Rating>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
  }

  Future<List<Rating>> _loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw Exception('Token is empty');
      }

      final reviews = await _viewReviewsService.fetchUserReviews(token);
      return reviews;
    } catch (e) {
      print('Error loading reviews: $e');
      return [];
    }
  }

  // Function to show a success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _editReviewDialog(Rating review) {
    final ratingController =
        TextEditingController(text: review.points.toString());
    final commentController = TextEditingController(text: review.reviewText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: review.points.toDouble(),
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                ratingController.text = rating.toInt().toString();
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final rating = int.parse(ratingController.text);
              final comment = commentController.text;

              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token') ?? '';

                if (token.isEmpty) {
                  throw Exception('Token is empty');
                }

                await _updateReviewService.updateReview(
                    review.id, rating, comment, token);
                Navigator.pop(context);
                setState(() {
                  _reviewsFuture =
                      _loadReviews(); // Refresh reviews after update
                });

                // Show success message
                _showSuccessMessage('Review updated successfully!');
              } catch (e) {
                print('Error updating review: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update review: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteReview(Rating review) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel deletion
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteReview(review);
              Navigator.pop(context); // Close the dialog after deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReview(Rating review) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw Exception('Token is empty');
      }

      await _deleteReviewService.deleteReview(review.id, token);
      setState(() {
        _reviewsFuture = _loadReviews(); // Refresh the reviews after deletion
      });

      // Show success message
      _showSuccessMessage('Review deleted successfully!');
    } catch (e) {
      print('Error deleting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar('My Reviews'),
      body: FutureBuilder<List<Rating>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reviews found.'));
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd/MM/yy').format(review.createdAt),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RatingBarIndicator(
                                rating: review.points.toDouble(),
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: index < review.points
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                                direction: Axis.horizontal,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review.reviewText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editReviewDialog(review),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteReview(
                                  review), // Show confirmation dialog
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar:
          CustomBottomNavigation.dynamicNav(context, 2, 'Resident'),
    );
  }
}
