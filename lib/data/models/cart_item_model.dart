import 'package:equatable/equatable.dart';

enum CartItemType { song, album }

class CartItemModel extends Equatable {
  final String id;
  final String itemId;
  final CartItemType type;
  final String title;
  final String artistName;
  final double price;
  final String coverUrl;

  const CartItemModel({
    required this.id,
    required this.itemId,
    required this.type,
    required this.title,
    required this.artistName,
    required this.price,
    required this.coverUrl,
  });

  @override
  List<Object?> get props => [
    id,
    itemId,
    type,
    title,
    artistName,
    price,
    coverUrl,
  ];
}
