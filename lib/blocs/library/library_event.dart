import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LibraryLoad extends LibraryEvent {
  const LibraryLoad();
}

class LibraryAddSong extends LibraryEvent {
  final String songId;

  const LibraryAddSong(this.songId);

  @override
  List<Object?> get props => [songId];
}

class LibraryAddAlbum extends LibraryEvent {
  final String albumId;

  const LibraryAddAlbum(this.albumId);

  @override
  List<Object?> get props => [albumId];
}
