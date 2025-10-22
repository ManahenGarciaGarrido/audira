import '../models/song_model.dart';
import '../models/album_model.dart';
import '../models/genre_model.dart';
import '../models/playlist_model.dart';
import '../models/review_model.dart';

class MockDataRepository {
  // Datos mock de géneros
  final List<GenreModel> _genres = [
    const GenreModel(id: '1', name: 'Rock'),
    const GenreModel(id: '2', name: 'Pop'),
    const GenreModel(id: '3', name: 'Jazz'),
    const GenreModel(id: '4', name: 'Electronic'),
    const GenreModel(id: '5', name: 'Hip Hop'),
    const GenreModel(id: '6', name: 'Classical'),
    const GenreModel(id: '7', name: 'Indie'),
    const GenreModel(id: '8', name: 'Alternative'),
  ];

  // Datos mock de canciones con imágenes reales
  final List<SongModel> _songs = [
    SongModel(
      id: '1',
      title: 'Midnight Dreams',
      artistId: 'artist1',
      artistName: 'Luna Rivers',
      albumId: 'album1',
      albumTitle: 'Echoes of Tomorrow',
      genres: const ['1', '7'], // Rock, Indie
      duration: const Duration(minutes: 3, seconds: 45),
      releaseDate: DateTime(2024, 10, 1),
      price: 1.99,
      audioUrl: 'https://example.com/audio/song1.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=800&h=800&fit=crop',
      trendingPosition: 1,
      rating: 4.8,
      playCount: 12500,
    ),
    SongModel(
      id: '2',
      title: 'Electric Soul',
      artistId: 'artist2',
      artistName: 'Neon Pulse',
      genres: const ['4'], // Electronic
      duration: const Duration(minutes: 4, seconds: 20),
      releaseDate: DateTime(2024, 9, 15),
      price: 2.49,
      audioUrl: 'https://example.com/audio/song2.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=800&h=800&fit=crop',
      trendingPosition: 2,
      rating: 4.6,
      playCount: 9800,
    ),
    SongModel(
      id: '3',
      title: 'Sunset Boulevard',
      artistId: 'artist3',
      artistName: 'The Wanderers',
      albumId: 'album2',
      albumTitle: 'Road Stories',
      genres: const ['2', '8'], // Pop, Alternative
      duration: const Duration(minutes: 3, seconds: 30),
      releaseDate: DateTime(2024, 8, 20),
      price: 1.49,
      audioUrl: 'https://example.com/audio/song3.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=800&fit=crop',
      rating: 4.7,
      playCount: 7600,
    ),
    SongModel(
      id: '4',
      title: 'Urban Jungle',
      artistId: 'artist4',
      artistName: 'MC Flow',
      genres: const ['5'], // Hip Hop
      duration: const Duration(minutes: 3, seconds: 15),
      releaseDate: DateTime(2024, 10, 5),
      price: 1.99,
      audioUrl: 'https://example.com/audio/song4.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&h=800&fit=crop',
      trendingPosition: 3,
      rating: 4.9,
      playCount: 15200,
    ),
    SongModel(
      id: '5',
      title: 'Serenity Now',
      artistId: 'artist5',
      artistName: 'Calm Waters',
      genres: const ['3', '6'], // Jazz, Classical
      duration: const Duration(minutes: 5, seconds: 10),
      releaseDate: DateTime(2024, 7, 10),
      price: 2.99,
      audioUrl: 'https://example.com/audio/song5.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=800&h=800&fit=crop',
      rating: 4.5,
      playCount: 5400,
    ),
    SongModel(
      id: '6',
      title: 'Neon Nights',
      artistId: 'artist6',
      artistName: 'Synthwave Dreams',
      genres: const ['4'], // Electronic
      duration: const Duration(minutes: 4, seconds: 5),
      releaseDate: DateTime(2024, 9, 1),
      price: 2.29,
      audioUrl: 'https://example.com/audio/song6.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&h=800&fit=crop',
      rating: 4.7,
      playCount: 8900,
    ),
    SongModel(
      id: '7',
      title: 'Acoustic Dreams',
      artistId: 'artist7',
      artistName: 'Forest Echo',
      genres: const ['7'], // Indie
      duration: const Duration(minutes: 3, seconds: 55),
      releaseDate: DateTime(2024, 8, 15),
      price: 1.79,
      audioUrl: 'https://example.com/audio/song7.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=800&h=800&fit=crop',
      rating: 4.8,
      playCount: 11200,
    ),
    SongModel(
      id: '8',
      title: 'Bass Drop',
      artistId: 'artist8',
      artistName: 'DJ Thunder',
      genres: const ['4', '5'], // Electronic, Hip Hop
      duration: const Duration(minutes: 3, seconds: 20),
      releaseDate: DateTime(2024, 10, 10),
      price: 2.49,
      audioUrl: 'https://example.com/audio/song8.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=800&fit=crop',
      rating: 4.6,
      playCount: 9500,
    ),
  ];

  // Datos mock de álbumes con imágenes reales
  final List<AlbumModel> _albums = [
    const AlbumModel(
      id: 'album1',
      title: 'Echoes of Tomorrow',
      artistIds: ['artist1'],
      artistNames: ['Luna Rivers'],
      songIds: ['1'],
      genres: ['1', '7'],
      totalDuration: Duration(minutes: 45, seconds: 30),
      year: 2024,
      price: 9.99,
      coverUrl:
          'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=800&h=800&fit=crop',
      rating: 4.8,
      salesCount: 450,
    ),
    const AlbumModel(
      id: 'album2',
      title: 'Road Stories',
      artistIds: ['artist3'],
      artistNames: ['The Wanderers'],
      songIds: ['3'],
      genres: ['2', '8'],
      totalDuration: Duration(minutes: 38, seconds: 15),
      year: 2024,
      price: 8.99,
      coverUrl:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=800&fit=crop',
      rating: 4.7,
      salesCount: 320,
    ),
    const AlbumModel(
      id: 'album3',
      title: 'Neon Paradise',
      artistIds: ['artist2'],
      artistNames: ['Neon Pulse'],
      songIds: ['2', '6'],
      genres: ['4'],
      totalDuration: Duration(minutes: 52, seconds: 45),
      year: 2024,
      price: 11.99,
      coverUrl:
          'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=800&h=800&fit=crop',
      rating: 4.9,
      salesCount: 580,
    ),
    const AlbumModel(
      id: 'album4',
      title: 'Urban Tales',
      artistIds: ['artist4'],
      artistNames: ['MC Flow'],
      songIds: ['4'],
      genres: ['5'],
      totalDuration: Duration(minutes: 41, seconds: 20),
      year: 2024,
      price: 10.49,
      coverUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&h=800&fit=crop',
      rating: 4.8,
      salesCount: 620,
    ),
    const AlbumModel(
      id: 'album5',
      title: 'Peaceful Moments',
      artistIds: ['artist5'],
      artistNames: ['Calm Waters'],
      songIds: ['5'],
      genres: ['3', '6'],
      totalDuration: Duration(minutes: 65, seconds: 30),
      year: 2024,
      price: 12.99,
      coverUrl:
          'https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=800&h=800&fit=crop',
      rating: 4.6,
      salesCount: 280,
    ),
    const AlbumModel(
      id: 'album6',
      title: 'Indie Spirit',
      artistIds: ['artist7'],
      artistNames: ['Forest Echo'],
      songIds: ['7'],
      genres: ['7'],
      totalDuration: Duration(minutes: 39, seconds: 50),
      year: 2024,
      price: 9.49,
      coverUrl:
          'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=800&h=800&fit=crop',
      rating: 4.7,
      salesCount: 410,
    ),
  ];

  // Métodos para obtener datos
  List<GenreModel> getGenres() => _genres;

  List<SongModel> getSongs() => _songs;

  List<SongModel> getTrendingSongs() {
    final trending = _songs.where((s) => s.trendingPosition != null).toList();
    trending.sort((a, b) => a.trendingPosition!.compareTo(b.trendingPosition!));
    return trending;
  }

  List<AlbumModel> getAlbums() => _albums;

  List<SongModel> searchSongs(String query) {
    final lowerQuery = query.toLowerCase();
    return _songs
        .where((song) =>
            song.title.toLowerCase().contains(lowerQuery) ||
            song.artistName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  SongModel? getSongById(String id) {
    try {
      return _songs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  AlbumModel? getAlbumById(String id) {
    try {
      return _albums.firstWhere((album) => album.id == id);
    } catch (e) {
      return null;
    }
  }

  // Métodos para agregar contenido
  void addSong(SongModel song) {
    _songs.add(song);
  }

  void addAlbum(AlbumModel album) {
    _albums.add(album);
  }

  // Métodos para eliminar contenido
  void removeSong(String id) {
    _songs.removeWhere((song) => song.id == id);
  }

  void removeAlbum(String id) {
    _albums.removeWhere((album) => album.id == id);
  }

  // Métodos para obtener contenido por artista
  List<SongModel> getSongsByArtist(String artistId) {
    return _songs.where((song) => song.artistId == artistId).toList();
  }

  List<AlbumModel> getAlbumsByArtist(String artistId) {
    return _albums
        .where((album) => album.artistIds.contains(artistId))
        .toList();
  }

  // Datos mock de playlists
  final List<PlaylistModel> _playlists = [];

  // Métodos para playlists
  List<PlaylistModel> getPlaylists(String userId) {
    return _playlists.where((playlist) => playlist.userId == userId).toList();
  }

  void addPlaylist(PlaylistModel playlist) {
    _playlists.add(playlist);
  }

  void removePlaylist(String id) {
    _playlists.removeWhere((playlist) => playlist.id == id);
  }

  void updatePlaylist(PlaylistModel playlist) {
    final index = _playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      _playlists[index] = playlist;
    }
  }

  PlaylistModel? getPlaylistById(String id) {
    try {
      return _playlists.firstWhere((playlist) => playlist.id == id);
    } catch (e) {
      return null;
    }
  }

  void addSongToPlaylist(String playlistId, String songId) {
    final playlist = getPlaylistById(playlistId);
    if (playlist != null && !playlist.songIds.contains(songId)) {
      final updatedPlaylist = playlist.copyWith(
        songIds: [...playlist.songIds, songId],
      );
      updatePlaylist(updatedPlaylist);
    }
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final playlist = getPlaylistById(playlistId);
    if (playlist != null) {
      final updatedPlaylist = playlist.copyWith(
        songIds: playlist.songIds.where((id) => id != songId).toList(),
      );
      updatePlaylist(updatedPlaylist);
    }
  }

  // Datos mock de reviews
  final List<ReviewModel> _reviews = [
    ReviewModel(
      id: 'review1',
      songId: '1',
      userId: 'user1',
      userName: 'María García',
      rating: 5.0,
      comment: '¡Increíble canción! Me encanta el ritmo y la producción.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ReviewModel(
      id: 'review2',
      songId: '1',
      userId: 'user2',
      userName: 'Carlos López',
      rating: 4.0,
      comment: 'Muy buena producción. La voz es espectacular.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ReviewModel(
      id: 'review3',
      songId: '2',
      userId: 'user3',
      userName: 'Ana Martínez',
      rating: 5.0,
      comment: 'Perfect para bailar! Me encanta.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Métodos para reviews
  List<ReviewModel> getReviewsBySong(String songId) {
    return _reviews.where((review) => review.songId == songId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addReview(ReviewModel review) {
    _reviews.add(review);
  }

  bool hasUserReviewedSong(String userId, String songId) {
    return _reviews.any(
        (review) => review.userId == userId && review.songId == songId);
  }
}
