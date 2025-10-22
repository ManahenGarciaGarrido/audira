import 'package:equatable/equatable.dart';

class PlaylistModel extends Equatable {
  final String id;
  final String name;
  final String userId;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, userId, songIds, createdAt, updatedAt];

  PlaylistModel copyWith({String? name, List<String>? songIds}) {
    return PlaylistModel(
      id: id,
      name: name ?? this.name,
      userId: userId,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
