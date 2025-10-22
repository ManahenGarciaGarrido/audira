import 'package:equatable/equatable.dart';

class AlbumModel extends Equatable {
  final String id;
  final String title;
  final List<String> artistIds;
  final List<String> artistNames;
  final List<String> songIds;
  final List<String> genres;
  final Duration totalDuration;
  final int year;
  final double price;
  final String coverUrl;
  final double rating;
  final int salesCount;

  const AlbumModel({
    required this.id,
    required this.title,
    required this.artistIds,
    required this.artistNames,
    required this.songIds,
    required this.genres,
    required this.totalDuration,
    required this.year,
    required this.price,
    required this.coverUrl,
    this.rating = 0.0,
    this.salesCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    artistIds,
    artistNames,
    songIds,
    genres,
    totalDuration,
    year,
    price,
    coverUrl,
    rating,
    salesCount,
  ];
}
