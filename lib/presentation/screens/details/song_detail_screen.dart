import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/song_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../blocs/player/player_bloc.dart';
import '../../../blocs/player/player_event.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/cart/cart_event.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/music_player_bar.dart';

class SongDetailScreen extends StatefulWidget {
  const SongDetailScreen({super.key});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
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
    final repository = MockDataRepository();
    final reviews = repository.getReviewsBySong(song.id);
    final user = context.read<AuthBloc>().state.user;
    final hasReviewed = user != null
        ? repository.hasUserReviewedSong(user.id, song.id)
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Valoraciones (${reviews.length})',
                style: Theme.of(context).textTheme.titleLarge),
            if (user != null && !hasReviewed)
              TextButton.icon(
                onPressed: () => _showAddReviewDialog(context, song),
                icon: const Icon(Icons.rate_review),
                label: const Text('Agregar'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.rate_review,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Aún no hay valoraciones',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text('¡Sé el primero en valorar esta canción!'),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: reviews.take(3).map((review) {
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          child: Text(review.userName[0].toUpperCase()),
                        ),
                        title: Text(review.userName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(review.comment),
                            const SizedBox(height: 4),
                            Text(
                              _formatReviewDate(review.createdAt),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (review != reviews.take(3).last) const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        if (reviews.length > 3)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => _showAllReviewsDialog(context, song, reviews),
                child: Text('Ver todas las ${reviews.length} valoraciones'),
              ),
            ),
          ),
      ],
    );
  }

  void _showAddReviewDialog(BuildContext context, SongModel song) {
    double rating = 5.0;
    final commentController = TextEditingController();
    final repository = MockDataRepository();
    final user = context.read<AuthBloc>().state.user;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Valoración'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Calificación:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        rating = (index + 1).toDouble();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comentario',
                  hintText: '¿Qué te pareció esta canción?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor escribe un comentario')),
                  );
                  return;
                }

                final newReview = ReviewModel(
                  id: 'review_${DateTime.now().millisecondsSinceEpoch}',
                  songId: song.id,
                  userId: user?.id ?? '',
                  userName: user?.name ?? 'Usuario',
                  rating: rating,
                  comment: commentController.text,
                  createdAt: DateTime.now(),
                );

                repository.addReview(newReview);
                Navigator.pop(dialogContext);
                setState(() {}); // Refresh UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Valoración agregada!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllReviewsDialog(
      BuildContext context, SongModel song, List<ReviewModel> reviews) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Valoraciones de ${song.title}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(review.userName[0].toUpperCase()),
                    ),
                    title: Text(review.userName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(review.comment),
                        const SizedBox(height: 4),
                        Text(
                          _formatReviewDate(review.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (index < reviews.length - 1) const Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} minutos';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
