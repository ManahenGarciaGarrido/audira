import 'package:flutter/material.dart';
import '../../data/models/song_model.dart';
import '../constants/app_colors.dart';

class AnimatedSongCard extends StatefulWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onAddToCart;
  final bool showPrice;
  final int index;

  const AnimatedSongCard({
    super.key,
    required this.song,
    this.onTap,
    this.onPlayTap,
    this.onAddToCart,
    this.showPrice = true,
    this.index = 0,
  });

  @override
  State<AnimatedSongCard> createState() => _AnimatedSongCardState();
}

class _AnimatedSongCardState extends State<AnimatedSongCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Cover Image with Hero Animation
                    Hero(
                      tag: 'song_${widget.song.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.song.coverUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: AppColors.primary,
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Song Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.song.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.song.artistName,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.showPrice) ...[
                            const SizedBox(height: 4),
                            Text(
                              '\$${widget.song.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Action Buttons
                    if (widget.onPlayTap != null)
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline),
                        onPressed: widget.onPlayTap,
                        color: AppColors.primary,
                      ),
                    if (widget.onAddToCart != null)
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: widget.onAddToCart,
                        color: AppColors.secondary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
