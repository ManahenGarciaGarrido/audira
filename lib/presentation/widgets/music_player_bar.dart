import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_state.dart';
import '../../blocs/player/player_event.dart';
import '../../core/constants/app_colors.dart';
import '../../core/navigation/app_navigator.dart';
import '../screens/player/full_player_screen.dart';

class MusicPlayerBar extends StatelessWidget {
  const MusicPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state.status == PlayerStatus.stopped || state.currentSong == null) {
          return const SizedBox.shrink();
        }

        final song = state.currentSong!;
        final isPlaying = state.status == PlayerStatus.playing;

        return GestureDetector(
          onTap: () {
            // Abrir reproductor completo al tocar
            AppNavigator.pushModal(
              context,
              FullPlayerScreen(song: song),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: state.currentSong != null
                      ? state.currentPosition.inSeconds /
                          state.currentSong!.duration.inSeconds
                      : 0,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Song Cover (sin Hero para evitar conflictos)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            song.coverUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: AppColors.primary,
                                child: const Icon(Icons.music_note,
                                    color: Colors.white, size: 24),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Song Info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artistName,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Play/Pause Button
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 32,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              context
                                  .read<PlayerBloc>()
                                  .add(const PlayerPause());
                            } else {
                              context
                                  .read<PlayerBloc>()
                                  .add(const PlayerResume());
                            }
                          },
                          color: AppColors.primary,
                        ),

                        // Stop Button
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            context.read<PlayerBloc>().add(const PlayerStop());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
