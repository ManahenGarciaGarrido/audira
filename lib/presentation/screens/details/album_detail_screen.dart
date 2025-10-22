import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/album_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/cart/cart_event.dart';
import '../../../core/constants/app_colors.dart';

class AlbumDetailScreen extends StatelessWidget {
  const AlbumDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final album = ModalRoute.of(context)!.settings.arguments as AlbumModel;

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
                    album.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary,
                        child: const Icon(
                          Icons.album,
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
                    album.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    album.artistNames.join(', '),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${album.year} • ${album.songIds.length} canciones',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Rating and Sales
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        album.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.shopping_bag, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${album.salesCount} ventas',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Buy Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final cartItem = CartItemModel(
                          id: 'cart_${album.id}',
                          itemId: album.id,
                          type: CartItemType.album,
                          title: album.title,
                          artistName: album.artistNames.join(', '),
                          price: album.price,
                          coverUrl: album.coverUrl,
                        );

                        context.read<CartBloc>().add(CartAddItem(cartItem));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Añadido al carrito')),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        'Comprar por \$${album.price.toStringAsFixed(2)}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Album Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Álbum',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Duración total',
                            _formatDuration(album.totalDuration),
                          ),
                          _buildInfoRow(
                            'Año de lanzamiento',
                            album.year.toString(),
                          ),
                          _buildInfoRow(
                            'Géneros',
                            album.genres.map((g) => 'Género $g').join(', '),
                          ),
                          _buildInfoRow(
                            'Número de canciones',
                            '${album.songIds.length}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tracklist
                  Text(
                    'Lista de canciones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: List.generate(
                        album.songIds.length,
                        (index) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text('${index + 1}'),
                          ),
                          title: Text('Canción ${index + 1}'),
                          subtitle: const Text('3:45'),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_outline),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Compra el álbum para escuchar',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}
