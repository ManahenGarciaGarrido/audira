import 'package:flutter_bloc/flutter_bloc.dart';
import 'library_event.dart';
import 'library_state.dart';
import '../../data/models/album_model.dart';
import '../../data/models/song_model.dart';
// Por ahora usar mock data hasta que el backend esté corriendo
import '../../data/repositories/mock_data_repository.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final MockDataRepository _repository;

  LibraryBloc({MockDataRepository? repository})
      : _repository = repository ?? MockDataRepository(),
        super(const LibraryState()) {
    on<LibraryLoad>(_onLoad);
    on<LibraryAddSong>(_onAddSong);
    on<LibraryAddAlbum>(_onAddAlbum);
  }

  Future<void> _onLoad(LibraryLoad event, Emitter<LibraryState> emit) async {
    emit(state.copyWith(status: LibraryStatus.loading));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Integrar con backend cuando esté disponible
      // final userId = await _authService.getUserId();
      // final library = await _libraryService.getLibrary(userId);

      // Por ahora usar mock data
      final mockSongs = _repository.getSongs().take(2).toList();
      final mockAlbums = _repository.getAlbums().take(1).toList();

      emit(
        state.copyWith(
          status: LibraryStatus.loaded,
          songs: mockSongs,
          albums: mockAlbums,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        status: LibraryStatus.error,
        errorMessage: 'Error cargando biblioteca: $e',
      ));
    }
  }

  Future<void> _onAddSong(
    LibraryAddSong event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final song = _repository.getSongById(event.songId);
      if (song != null && !state.songs.any((s) => s.id == song.id)) {
        final updatedSongs = List<SongModel>.from(state.songs)..add(song);
        emit(state.copyWith(songs: updatedSongs));
      }
    } catch (e) {
      print('Error añadiendo canción a biblioteca: $e');
    }
  }

  Future<void> _onAddAlbum(
    LibraryAddAlbum event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final album = _repository.getAlbumById(event.albumId);
      if (album != null && !state.albums.any((a) => a.id == album.id)) {
        final updatedAlbums = List<AlbumModel>.from(state.albums)..add(album);
        emit(state.copyWith(albums: updatedAlbums));
      }
    } catch (e) {
      print('Error añadiendo álbum a biblioteca: $e');
    }
  }
}
