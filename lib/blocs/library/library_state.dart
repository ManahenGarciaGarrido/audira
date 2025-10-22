import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';
import '../../data/models/album_model.dart';

enum LibraryStatus { initial, loading, loaded, error }

class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final String? errorMessage;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.songs = const [],
    this.albums = const [],
    this.errorMessage,
  });

  LibraryState copyWith({
    LibraryStatus? status,
    List<SongModel>? songs,
    List<AlbumModel>? albums,
    String? errorMessage,
  }) {
    return LibraryState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, songs, albums, errorMessage];
}
