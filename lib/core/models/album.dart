import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final int id;
  final int artistId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? category;
  final List<String> imageUrls;
  final List<int> genreIds;
  final DateTime? releaseDate;
  final double discountPercentage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Album({
    required this.id,
    required this.artistId,
    required this.name,
    this.description,
    required this.price,
    this.stock = 0,
    this.category,
    this.imageUrls = const [],
    this.genreIds = const [],
    this.releaseDate,
    this.discountPercentage = 15.0,
    this.createdAt,
    this.updatedAt,
  });

  double get discountedPrice {
    return price * (1 - discountPercentage / 100);
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as int,
      artistId: json['artistId'] as int,
      name: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int? ?? 0,
      category: json['category'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      genreIds:
          (json['genreIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              [],
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'] as String)
          : null,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 15.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artistId': artistId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'imageUrls': imageUrls,
      'genreIds': genreIds,
      'releaseDate': releaseDate?.toIso8601String(),
      'discountPercentage': discountPercentage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Album copyWith({
    int? id,
    int? artistId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    List<String>? imageUrls,
    List<int>? genreIds,
    DateTime? releaseDate,
    double? discountPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Album(
      id: id ?? this.id,
      artistId: artistId ?? this.artistId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      genreIds: genreIds ?? this.genreIds,
      releaseDate: releaseDate ?? this.releaseDate,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        artistId,
        name,
        description,
        price,
        stock,
        category,
        imageUrls,
        genreIds,
        releaseDate,
        discountPercentage,
        createdAt,
        updatedAt,
      ];
}
