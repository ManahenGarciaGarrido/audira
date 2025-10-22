import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String songId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.songId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, songId, userId, userName, rating, comment, createdAt];
}
