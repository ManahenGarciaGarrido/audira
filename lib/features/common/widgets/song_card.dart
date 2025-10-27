import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../core/models/song.dart';

class SongCard extends StatelessWidget {
  final Song song;

  const SongCard({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to song detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abrir: ${song.name}')),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppTheme.cardBlack,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: song.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: song.imageUrls.first,
                      width: 160,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 160,
                        height: 120,
                        color: AppTheme.surfaceBlack,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 160,
                        height: 120,
                        color: AppTheme.surfaceBlack,
                        child: const Icon(Icons.music_note, size: 48),
                      ),
                    )
                  : Container(
                      width: 160,
                      height: 120,
                      color: AppTheme.surfaceBlack,
                      child: const Icon(Icons.music_note, size: 48),
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.durationFormatted,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${song.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.primaryBlue,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
