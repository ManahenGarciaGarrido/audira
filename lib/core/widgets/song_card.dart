import 'package:flutter/material.dart';
import '../../data/models/song_model.dart';
import '../constants/app_colors.dart';

class SongCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onAddToCart;
  final bool showPrice;

  const SongCard({
    super.key,
    required this.song,
    this.onTap,
    this.onPlayTap,
    this.onAddToCart,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cover Image
              ClipRRect(
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
                      child: const Icon(Icons.music_note, color: Colors.white),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Song Info
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
                    if (showPrice) ...[
                      const SizedBox(height: 4),
                      Text(
                        '\$${song.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              if (onPlayTap != null)
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: onPlayTap,
                  color: AppColors.primary,
                ),
              if (onAddToCart != null)
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: onAddToCart,
                  color: AppColors.secondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
