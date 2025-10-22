import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../data/models/song_model.dart';
import '../../../data/models/album_model.dart';
import '../../../blocs/player/player_bloc.dart';
import '../../../blocs/player/player_event.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/cart/cart_event.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/song_card.dart';
import '../../../core/widgets/album_card.dart';
import '../../../data/models/cart_item_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _repository = MockDataRepository();
  final _searchController = TextEditingController();
  late TabController _tabController;

  List<SongModel> _songResults = [];
  List<AlbumModel> _albumResults = [];
  String? _selectedGenre;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _songResults = [];
        _albumResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simular delay de búsqueda
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      var songs = _repository.searchSongs(query);
      var albums = _repository.getAlbums().where((album) {
        return album.title.toLowerCase().contains(query.toLowerCase()) ||
            album.artistNames.any(
                (name) => name.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      // Aplicar filtro de género si existe
      if (_selectedGenre != null) {
        songs = songs.where((s) => s.genres.contains(_selectedGenre)).toList();
        albums =
            albums.where((a) => a.genres.contains(_selectedGenre)).toList();
      }

      setState(() {
        _songResults = songs;
        _albumResults = albums;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(),

            // Genre Filter
            if (_searchController.text.isNotEmpty) _buildGenreFilter(),

            // Tabs
            if (_searchController.text.isNotEmpty)
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Todo'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_songResults.length + _albumResults.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Canciones'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_songResults.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Álbumes'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_albumResults.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            // Results
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar canciones, artistas, álbumes...',
                  prefixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _performSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreFilter() {
    final genres = _repository.getGenres();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Todos
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Todos'),
              selected: _selectedGenre == null,
              onSelected: (selected) {
                setState(() {
                  _selectedGenre = null;
                });
                _performSearch(_searchController.text);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.3),
              backgroundColor: AppColors.surface,
            ),
          ),
          // Géneros
          ...genres.map((genre) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(genre.name),
                selected: _selectedGenre == genre.id,
                onSelected: (selected) {
                  setState(() {
                    _selectedGenre = selected ? genre.id : null;
                  });
                  _performSearch(_searchController.text);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                backgroundColor: AppColors.surface,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_songResults.isEmpty && _albumResults.isEmpty) {
      return _buildNoResults();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllResults(),
        _buildSongResults(),
        _buildAlbumResults(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 100,
            color: AppColors.textDisabled.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Busca tu música favorita',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora canciones, álbumes y artistas',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 100,
            color: AppColors.textDisabled.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAllResults() {
    return ListView(
      children: [
        if (_songResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Canciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ..._songResults.take(5).map(_buildSongItem),
          if (_songResults.length > 5)
            TextButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: const Text('Ver todas las canciones'),
            ),
        ],
        if (_albumResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Álbumes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _albumResults.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 160,
                  child: _buildAlbumItem(_albumResults[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildSongResults() {
    return ListView.builder(
      itemCount: _songResults.length,
      itemBuilder: (context, index) => _buildSongItem(_songResults[index]),
    );
  }

  Widget _buildAlbumResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
      ),
      itemCount: _albumResults.length,
      itemBuilder: (context, index) => _buildAlbumItem(_albumResults[index]),
    );
  }

  Widget _buildSongItem(SongModel song) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isGuest = authState.user == null;

        return SongCard(
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
        );
      },
    );
  }

  Widget _buildAlbumItem(AlbumModel album) {
    return AlbumCard(
      album: album,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.albumDetail,
          arguments: album,
        );
      },
    );
  }
}
