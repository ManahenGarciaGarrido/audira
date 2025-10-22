import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';

enum PlayerStatus { stopped, playing, paused, loading }

enum RepeatMode { off, one, all }

class PlayerState extends Equatable {
  final PlayerStatus status;
  final SongModel? currentSong;
  final Duration currentPosition;
  final bool isPreview;
  final Duration? previewLimit;
  final bool isShuffled;
  final RepeatMode repeatMode;
  final List<SongModel> playlist;
  final int currentIndex;

  const PlayerState({
    this.status = PlayerStatus.stopped,
    this.currentSong,
    this.currentPosition = Duration.zero,
    this.isPreview = false,
    this.previewLimit,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.off,
    this.playlist = const [],
    this.currentIndex = 0,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    SongModel? currentSong,
    Duration? currentPosition,
    bool? isPreview,
    Duration? previewLimit,
    bool? isShuffled,
    RepeatMode? repeatMode,
    List<SongModel>? playlist,
    int? currentIndex,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentSong: currentSong ?? this.currentSong,
      currentPosition: currentPosition ?? this.currentPosition,
      isPreview: isPreview ?? this.isPreview,
      previewLimit: previewLimit ?? this.previewLimit,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentSong,
        currentPosition,
        isPreview,
        previewLimit,
        isShuffled,
        repeatMode,
        playlist,
        currentIndex,
      ];
}
