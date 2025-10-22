import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/library/library_bloc.dart';
import '../../../blocs/library/library_state.dart';
import '../../../blocs/library/library_event.dart';
import '../../../blocs/player/player_bloc.dart';
import '../../../blocs/player/player_event.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/song_card.dart';
import '../../../core/widgets/album_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/music_player_bar.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Cargar biblioteca
    context.read<LibraryBloc>().add(const LibraryLoad());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState.status == AuthStatus.authenticated;

        if (!isAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mi Biblioteca')),
            body: _buildUnauthenticatedView(context),
            bottomNavigationBar: const BottomNavBar(currentIndex: 2),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Biblioteca'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Canciones', icon: Icon(Icons.music_note)),
                Tab(text: 'Álbumes', icon: Icon(Icons.album)),
                Tab(text: 'Playlists', icon: Icon(Icons.playlist_play)),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSongsTab(),
                    _buildAlbumsTab(),
                    _buildPlaylistsTab(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MusicPlayerBar(),
              BottomNavBar(currentIndex: 2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_music, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Inicia sesión para acceder a tu biblioteca',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsTab() {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state.status == LibraryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.songs.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.music_note,
            title: 'No tienes canciones en tu biblioteca',
            subtitle: 'Compra música para agregarla aquí',
          );
        }

        return ListView.builder(
          itemCount: state.songs.length,
          itemBuilder: (context, index) {
            final song = state.songs[index];

            // Animación de aparición escalonada
            return TweenAnimationBuilder<double>(
              key: ValueKey(song.id),
              duration: Duration(milliseconds: 300 + (index * 80)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: SongCard(
                song: song,
                showPrice: false,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.songDetail,
                    arguments: song,
                  );
                },
                onPlayTap: () {
                  context.read<PlayerBloc>().add(PlayerPlaySong(song));
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state.status == LibraryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.albums.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.album,
            title: 'No tienes álbumes en tu biblioteca',
            subtitle: 'Compra álbumes para agregarlos aquí',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
          ),
          itemCount: state.albums.length,
          itemBuilder: (context, index) {
            final album = state.albums[index];

            // Animación de aparición con zoom y rotación sutil
            return TweenAnimationBuilder<double>(
              key: ValueKey(album.id),
              duration: Duration(milliseconds: 400 + (index * 120)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.7 + (0.3 * value),
                    child: Transform.rotate(
                      angle: (1 - value) * 0.1,
                      child: child,
                    ),
                  ),
                );
              },
              child: AlbumCard(
                album: album,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.albumDetail,
                    arguments: album,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsTab() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.playlist_play, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Función de playlists próximamente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad en desarrollo'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Playlist'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.store);
              },
              child: const Text('Explorar Tienda'),
            ),
          ],
        ),
      ),
    );
  }
}
