import 'package:equatable/equatable.dart';

class SongModel extends Equatable {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? albumId;
  final String? albumTitle;
  final List<String> genres;
  final Duration duration;
  final DateTime releaseDate;
  final double price;
  final String audioUrl;
  final String coverUrl;
  final int? trendingPosition;
  final double rating;
  final int playCount;
  final List<String> collaborators;

  const SongModel({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.albumId,
    this.albumTitle,
    required this.genres,
    required this.duration,
    required this.releaseDate,
    required this.price,
    required this.audioUrl,
    required this.coverUrl,
    this.trendingPosition,
    this.rating = 0.0,
    this.playCount = 0,
    this.collaborators = const [],
  });

  @override
  List<Object?> get props => [
    id,
    title,
    artistId,
    artistName,
    albumId,
    albumTitle,
    genres,
    duration,
    releaseDate,
    price,
    audioUrl,
    coverUrl,
    trendingPosition,
    rating,
    playCount,
    collaborators,
  ];
}
