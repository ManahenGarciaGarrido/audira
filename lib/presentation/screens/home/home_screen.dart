import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/player/player_bloc.dart';
import '../../../blocs/player/player_event.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/cart/cart_event.dart';
import '../../../blocs/cart/cart_state.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/album_card.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/music_player_bar.dart';
import '../search/search_screen.dart';
import '../player/full_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _repository = MockDataRepository();
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeTransition(
          opacity: _headerAnimation,
          child: const Text('Audira'),
        ),
        actions: [
          // Search Button con animación
          ScaleTransition(
            scale: _headerAnimation,
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                AppNavigator.pushModal(context, const SearchScreen());
              },
            ),
          ),

          // Cart Button con badge
          Stack(
            children: [
              ScaleTransition(
                scale: _headerAnimation,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.cart);
                  },
                ),
              ),
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox.shrink();

                  return Positioned(
                    right: 8,
                    top: 8,
                    child: ScaleTransition(
                      scale: _headerAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${state.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'contact':
                  Navigator.pushNamed(context, AppRoutes.contact);
                  break;
                case 'faq':
                  Navigator.pushNamed(context, AppRoutes.faq);
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contact',
                child: Row(
                  children: [
                    Icon(Icons.contact_mail),
                    SizedBox(width: 8),
                    Text('Contacto'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'faq',
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('FAQs'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isGuest = authState.user == null;

          return Column(
            children: [
              // Guest Banner animado
              if (isGuest)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(_headerAnimation),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Navega como invitado. Regístrate para acceder a todas las funciones.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                          child: const Text('Entrar'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(height: 90),

              // Content con scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Trending Section
                      _buildSectionHeader(context, 'Tendencias'),
                      _buildTrendingSongs(isGuest),

                      const SizedBox(height: 32),

                      // Latest Albums
                      _buildSectionHeader(context, 'Últimos Lanzamientos'),
                      _buildLatestAlbums(),

                      const SizedBox(height: 32),

                      // Genres
                      _buildSectionHeader(context, 'Explorar por Género'),
                      _buildGenres(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MusicPlayerBar(),
          BottomNavBar(currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSongs(bool isGuest) {
    final trendingSongs = _repository.getTrendingSongs();

    return Column(
      children: List.generate(
        trendingSongs.length,
        (index) {
          final song = trendingSongs[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
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
            child: _buildSongItem(song, isGuest, index),
          );
        },
      ),
    );
  }

  Widget _buildSongItem(song, bool isGuest, int trendingPos) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.songDetail,
            arguments: song,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Trending Number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${trendingPos + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Cover
              Hero(
                tag: 'song_${song.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.coverUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: AppColors.primary,
                        child:
                            const Icon(Icons.music_note, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artistName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.play_circle,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${song.playCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              IconButton(
                icon: const Icon(Icons.play_circle_filled),
                color: AppColors.primary,
                iconSize: 36,
                onPressed: () {
                  // Navegar al reproductor completo
                  AppNavigator.pushModal(
                    context,
                    FullPlayerScreen(song: song),
                  );

                  context.read<PlayerBloc>().add(
                        PlayerPlaySong(song, isPreview: isGuest),
                      );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () {
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
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestAlbums() {
    final albums = _repository.getAlbums();

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
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
            child: SizedBox(
              width: 160,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenres() {
    final genres = _repository.getGenres();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          genres.length,
          (index) {
            final genre = genres[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 200 + (index * 50)),
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
              child: ActionChip(
                label: Text(genre.name),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.store,
                    arguments: {'genreId': genre.id},
                  );
                },
                backgroundColor: _getGenreColor(genre.name),
                elevation: 4,
                shadowColor: _getGenreColor(genre.name).withValues(alpha: 0.5),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getGenreColor(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'rock':
        return AppColors.genreRock;
      case 'pop':
        return AppColors.genrePop;
      case 'jazz':
        return AppColors.genreJazz;
      case 'electronic':
        return AppColors.genreElectronic;
      case 'hip hop':
        return AppColors.genreHipHop;
      case 'classical':
        return AppColors.genreClassical;
      case 'indie':
        return AppColors.genreIndie;
      case 'alternative':
        return AppColors.genreAlternative;
      default:
        return AppColors.primary;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }
}
