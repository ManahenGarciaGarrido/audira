import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/song_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../blocs/player/player_bloc.dart';
import '../../../blocs/player/player_event.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/cart/cart_event.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/music_player_bar.dart';

class SongDetailScreen extends StatelessWidget {
  const SongDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final song = ModalRoute.of(context)!.settings.arguments as SongModel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    song.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary,
                        child: const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Artist
                  Text(
                    song.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.artistName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (song.albumTitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Del álbum: ${song.albumTitle}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Rating and Stats
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        song.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.play_circle, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${song.playCount} reproducciones',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            final isGuest = authState.user == null;
                            return ElevatedButton.icon(
                              onPressed: () {
                                context.read<PlayerBloc>().add(
                                  PlayerPlaySong(song, isPreview: isGuest),
                                );
                                if (isGuest) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vista previa de 10 segundos',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: Text(isGuest ? 'Preview' : 'Reproducir'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
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
                              const SnackBar(
                                content: Text('Añadido al carrito'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text('\$${song.price.toStringAsFixed(2)}'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Song Info
                  _buildInfoCard(context, song),

                  const SizedBox(height: 16),

                  // Reviews Section
                  _buildReviewsSection(context, song),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MusicPlayerBar(),
    );
  }

  Widget _buildInfoCard(BuildContext context, SongModel song) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow('Duración', _formatDuration(song.duration)),
            _buildInfoRow(
              'Lanzamiento',
              '${song.releaseDate.day}/${song.releaseDate.month}/${song.releaseDate.year}',
            ),
            _buildInfoRow(
              'Géneros',
              song.genres.map((g) => 'Género $g').join(', '),
            ),
            if (song.collaborators.isNotEmpty)
              _buildInfoRow(
                'Colaboradores',
                song.collaborators.take(2).join(', '),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, SongModel song) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Valoraciones', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text('Usuario Demo'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < 5 ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('¡Increíble canción! Me encanta el ritmo.'),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text('Otro Usuario'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Muy buena producción.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
            child: const Text('Ver todas las valoraciones'),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
