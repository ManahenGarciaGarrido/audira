import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/player/player_bloc.dart';
import '../../../blocs/player/player_state.dart';
import '../../../blocs/player/player_event.dart';
import '../../../data/models/song_model.dart';
import '../../../core/constants/app_colors.dart';

class FullPlayerScreen extends StatefulWidget {
  final SongModel song;

  const FullPlayerScreen({super.key, required this.song});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();

    // Rotación continua del disco (más lenta y suave)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    // Animación de pulse suave
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<PlayerBloc, PlayerState>(
            builder: (context, state) {
              final isPlaying = state.status == PlayerStatus.playing;

              // Controlar animaciones según estado
              if (isPlaying) {
                if (!_rotationController.isAnimating) {
                  _rotationController.repeat();
                }
              } else {
                _rotationController.stop();
              }

              return Column(
                children: [
                  // Header
                  _buildHeader(context),

                  const SizedBox(height: 20),

                  // Album Art con animaciones suaves
                  Expanded(
                    child: Center(
                      child: _buildAlbumArt(isPlaying),
                    ),
                  ),

                  // Song Info
                  _buildSongInfo(),

                  const SizedBox(height: 20),

                  // Progress Bar
                  _buildProgressBar(state),

                  const SizedBox(height: 20),

                  // Controls
                  _buildControls(context, state),

                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Reproduciendo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(bool isPlaying) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ondas de fondo suaves (solo cuando está reproduciendo)
        if (isPlaying)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 280 * _pulseAnimation.value,
                height: 280 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.3 * (2.0 - _pulseAnimation.value),
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),

        // Disco rotatorio con animación suave
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: child,
            );
          },
          child: Hero(
            tag: 'song_${widget.song.id}',
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.song.coverUrl,
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
              ),
            ),
          ),
        ),

        // Centro del disco
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSongInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            widget.song.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.song.artistName,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(PlayerState state) {
    final position = state.currentPosition;
    final duration = state.currentSong?.duration ?? Duration.zero;
    final progress =
        duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.secondary,
              overlayColor: AppColors.secondary.withValues(alpha: 0.3),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                final newPosition = Duration(
                  seconds: (value * duration.inSeconds).round(),
                );
                context.read<PlayerBloc>().add(PlayerSeek(newPosition));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, PlayerState state) {
    final isPlaying = state.status == PlayerStatus.playing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            icon: const Icon(Icons.shuffle, size: 28),
            color: AppColors.textSecondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),

          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 40),
            color: AppColors.textPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Canción anterior')),
              );
            },
          ),

          // Play/Pause con animación
          AnimatedScale(
            scale: isPlaying ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    key: ValueKey(isPlaying),
                    size: 40,
                  ),
                ),
                color: Colors.white,
                onPressed: () {
                  if (isPlaying) {
                    context.read<PlayerBloc>().add(const PlayerPause());
                  } else {
                    context.read<PlayerBloc>().add(const PlayerResume());
                  }
                },
              ),
            ),
          ),

          // Next
          IconButton(
            icon: const Icon(Icons.skip_next, size: 40),
            color: AppColors.textPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Siguiente canción')),
              );
            },
          ),

          // Repeat
          IconButton(
            icon: const Icon(Icons.repeat, size: 28),
            color: AppColors.textSecondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Repetir próximamente')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 26),
            color: AppColors.textSecondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartir')),
              );
            },
          ),
          AnimatedScale(
            scale: _isLiked ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: IconButton(
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                size: 26,
                color: _isLiked ? Colors.red : AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _isLiked = !_isLiked;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add, size: 26),
            color: AppColors.textSecondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Añadir a playlist')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Información de la canción'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Descargar'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Ver artista'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
