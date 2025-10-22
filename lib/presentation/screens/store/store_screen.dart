import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../blocs/player/player_bloc.dart';
import '../../../blocs/player/player_event.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/cart/cart_event.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/song_card.dart';
import '../../../core/widgets/album_card.dart';
import '../../../data/models/cart_item_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/music_player_bar.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  final _repository = MockDataRepository();
  late TabController _tabController;
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Canciones', icon: Icon(Icons.music_note)),
            Tab(text: 'Álbumes', icon: Icon(Icons.album)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedGenre = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) {
              final genres = _repository.getGenres();
              return [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('Todos los géneros'),
                ),
                const PopupMenuDivider(),
                ...genres.map((genre) => PopupMenuItem(
                      value: genre.id,
                      child: Text(genre.name),
                    )),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedGenre != null) _buildGenreFilterChip(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSongsTab(),
                _buildAlbumsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MusicPlayerBar(),
          BottomNavBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildGenreFilterChip() {
    final genre =
        _repository.getGenres().firstWhere((g) => g.id == _selectedGenre);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.purple.withValues(alpha: 0.2),
        child: Row(
          children: [
            const Text('Filtro activo: '),
            Chip(
              label: Text(genre.name),
              onDeleted: () {
                setState(() {
                  _selectedGenre = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsTab() {
    var songs = _repository.getSongs();

    if (_selectedGenre != null) {
      songs =
          songs.where((song) => song.genres.contains(_selectedGenre)).toList();
    }

    if (songs.isEmpty) {
      return const Center(
        child: Text('No hay canciones con este filtro'),
      );
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isGuest = authState.user == null;

        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];

            // Animación de aparición escalonada
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 80)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(50 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: SongCard(
                song: song,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.songDetail,
                    arguments: song,
                  );
                },
                onPlayTap: () {
                  context.read<PlayerBloc>().add(
                        PlayerPlaySong(song, isPreview: isGuest),
                      );
                },
                onAddToCart: () {
                  final cartItem = CartItemModel(
                    id: 'cart_${song.id}',
                    itemId: song.id,
                    type: CartItemType.song,
                    title: song.title,
                    artistName: song.artistName,
                    price: song.price,
                    coverUrl: song.coverUrl,
                  );

                  context.read<CartBloc>().add(CartAddItem(cartItem));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${song.title} añadido al carrito'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    var albums = _repository.getAlbums();

    if (_selectedGenre != null) {
      albums = albums
          .where((album) => album.genres.contains(_selectedGenre))
          .toList();
    }

    if (albums.isEmpty) {
      return const Center(
        child: Text('No hay álbumes con este filtro'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];

        // Animación de aparición escalonada con zoom
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
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
  }
}
