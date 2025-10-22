import 'package:equatable/equatable.dart';

enum CartItemType { song, album }

class RatingModel extends Equatable {
  final String id;
  final String userId;
  final String itemId;
  final CartItemType itemType;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    itemId,
    itemType,
    rating,
    comment,
    createdAt,
  ];
}
