import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audira/data/models/album_model.dart';
import 'package:audira/data/models/song_model.dart';
import 'library_event.dart';
import 'library_state.dart';
import '../../data/repositories/mock_data_repository.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final MockDataRepository repository;

  LibraryBloc(this.repository) : super(const LibraryState()) {
    on<LibraryLoad>(_onLoad);
    on<LibraryAddSong>(_onAddSong);
    on<LibraryAddAlbum>(_onAddAlbum);
  }

  Future<void> _onLoad(LibraryLoad event, Emitter<LibraryState> emit) async {
    emit(state.copyWith(status: LibraryStatus.loading));

    await Future.delayed(const Duration(milliseconds: 500));

    // Mock: obtener primeras 2 canciones como compradas
    final mockSongs = repository.getSongs().take(2).toList();
    final mockAlbums = repository.getAlbums().take(1).toList();

    emit(
      state.copyWith(
        status: LibraryStatus.loaded,
        songs: mockSongs,
        albums: mockAlbums,
      ),
    );
  }

  Future<void> _onAddSong(
    LibraryAddSong event,
    Emitter<LibraryState> emit,
  ) async {
    final song = repository.getSongById(event.songId);
    if (song != null && !state.songs.any((s) => s.id == song.id)) {
      final updatedSongs = List<SongModel>.from(state.songs)..add(song);
      emit(state.copyWith(songs: updatedSongs));
    }
  }

  Future<void> _onAddAlbum(
    LibraryAddAlbum event,
    Emitter<LibraryState> emit,
  ) async {
    final album = repository.getAlbumById(event.albumId);
    if (album != null && !state.albums.any((a) => a.id == album.id)) {
      final updatedAlbums = List<AlbumModel>.from(state.albums)..add(album);
      emit(state.copyWith(albums: updatedAlbums));
    }
  }
}
