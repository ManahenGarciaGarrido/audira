import 'package:equatable/equatable.dart';

class PlaylistModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String userId;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverUrl;

  const PlaylistModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.userId,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverUrl,
  });

  @override
  List<Object?> get props =>
      [id, name, description, userId, songIds, createdAt, updatedAt, coverUrl];

  PlaylistModel copyWith({
    String? name,
    String? description,
    List<String>? songIds,
    String? coverUrl,
  }) {
    return PlaylistModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
