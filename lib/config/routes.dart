import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/main_layout.dart';
import '../features/music/screens/song_detail_screen.dart';
import '../features/music/screens/album_detail_screen.dart';
import '../features/music/screens/artist_detail_screen.dart';
import '../features/music/screens/genre_detail_screen.dart';
import '../features/common/screens/faq_screen.dart';
import '../features/common/screens/contact_screen.dart';
import '../features/playback/screens/playback_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/playlist/screens/create_playlist_screen.dart';
import '../features/playlist/screens/playlist_detail_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/user_stats_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_songs_screen.dart';
import '../features/admin/screens/admin_albums_screen.dart';
import '../features/admin/screens/admin_genres_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/admin/screens/admin_faqs_screen.dart';
import '../features/admin/screens/admin_contacts_screen.dart';
import '../features/admin/screens/admin_orders_screen.dart';
import '../features/admin/screens/admin_stats_screen.dart';
import '../features/studio/screens/studio_dashboard_screen.dart';
import '../features/studio/screens/upload_song_screen.dart';
import '../features/studio/screens/upload_album_screen.dart';
import '../features/studio/screens/studio_stats_screen.dart';
import '../features/studio/screens/studio_catalog_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String song = '/song';
  static const String album = '/album';
  static const String artist = '/artist';
  static const String genre = '/genre';
  static const String faq = '/faq';
  static const String contact = '/contact';
  static const String playback = '/playback';
  static const String playlist = '/playlist';
  static const String createPlaylist = '/playlist/create';
  static const String editPlaylist = '/playlist/edit';
  static const String userStats = '/stats';
  static const String editProfile = '/profile/edit';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String studio = '/studio';
  static const String studioUploadSong = '/studio/upload-song';
  static const String studioUploadAlbum = '/studio/upload-album';
  static const String studioStats = '/studio/stats';
  static const String studioCatalog = '/studio/catalog';
  static const String admin = '/admin';
  static const String adminSongs = '/admin/songs';
  static const String adminAlbums = '/admin/albums';
  static const String adminGenres = '/admin/genres';
  static const String adminUsers = '/admin/users';
  static const String adminFaqs = '/admin/faqs';
  static const String adminContacts = '/admin/contacts';
  static const String adminOrders = '/admin/orders';
  static const String adminStats = '/admin/stats';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainLayout());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case song:
        final songId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => SongDetailScreen(songId: songId),
        );

      case album:
        final albumId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => AlbumDetailScreen(albumId: albumId),
        );

      case artist:
        final artistId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ArtistDetailScreen(artistId: artistId),
        );

      case genre:
        final genreId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => GenreDetailScreen(genreId: genreId),
        );

      case faq:
        return MaterialPageRoute(builder: (_) => const FAQScreen());

      case contact:
        return MaterialPageRoute(builder: (_) => const ContactScreen());

      case playback:
        return MaterialPageRoute(builder: (_) => const PlaybackScreen());

      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case createPlaylist:
        return MaterialPageRoute(builder: (_) => const CreatePlaylistScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case studio:
        return MaterialPageRoute(builder: (_) => const StudioDashboardScreen());

      case admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      // Playlist routes
      case playlist:
        final playlistId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => PlaylistDetailScreen(playlistId: playlistId),
        );

      case editPlaylist:
        ScaffoldMessenger.of(settings.arguments as BuildContext).showSnackBar(
          const SnackBar(content: Text('Edit Playlist - Coming soon')),
        );
        return MaterialPageRoute(builder: (_) => const MainLayout());

      // User statistics
      case userStats:
        return MaterialPageRoute(builder: (_) => const UserStatsScreen());

      // Studio routes
      case studioUploadSong:
        return MaterialPageRoute(builder: (_) => const UploadSongScreen());

      case studioUploadAlbum:
        return MaterialPageRoute(builder: (_) => const UploadAlbumScreen());

      case studioStats:
        return MaterialPageRoute(builder: (_) => const StudioStatsScreen());

      case studioCatalog:
        return MaterialPageRoute(builder: (_) => const StudioCatalogScreen());

      // Admin routes
      case adminSongs:
        return MaterialPageRoute(builder: (_) => const AdminSongsScreen());

      case adminAlbums:
        return MaterialPageRoute(builder: (_) => const AdminAlbumsScreen());

      case adminGenres:
        return MaterialPageRoute(builder: (_) => const AdminGenresScreen());

      case adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());

      case adminFaqs:
        return MaterialPageRoute(builder: (_) => const AdminFaqsScreen());

      case adminContacts:
        return MaterialPageRoute(builder: (_) => const AdminContactsScreen());

      case adminOrders:
        return MaterialPageRoute(builder: (_) => const AdminOrdersScreen());

      case adminStats:
        return MaterialPageRoute(builder: (_) => const AdminStatsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Route not found: ${settings.name}'),
                ],
              ),
            ),
          ),
        );
    }
  }

  static String _getRouteName(String route) {
    final routeNames = {
      playback: 'Playback',
      playlist: 'Playlist',
      createPlaylist: 'Create Playlist',
      editPlaylist: 'Edit Playlist',
      userStats: 'Statistics',
      editProfile: 'Edit Profile',
      search: 'Search',
      notifications: 'Notifications',
      studio: 'Studio',
      studioUploadSong: 'Upload Song',
      studioUploadAlbum: 'Upload Album',
      studioStats: 'Studio Statistics',
      studioCatalog: 'My Catalog',
      admin: 'Admin Panel',
      adminSongs: 'Manage Songs',
      adminAlbums: 'Manage Albums',
      adminGenres: 'Manage Genres',
      adminUsers: 'Manage Users',
      adminFaqs: 'Manage FAQs',
      adminContacts: 'View Contacts',
      adminOrders: 'Manage Orders',
      adminStats: 'Global Statistics',
    };
    return routeNames[route] ?? 'Unknown';
  }
}
