import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';

enum PlayerStatus { stopped, playing, paused, loading }

class PlayerState extends Equatable {
  final PlayerStatus status;
  final SongModel? currentSong;
  final Duration currentPosition;
  final bool isPreview;
  final Duration? previewLimit;

  const PlayerState({
    this.status = PlayerStatus.stopped,
    this.currentSong,
    this.currentPosition = Duration.zero,
    this.isPreview = false,
    this.previewLimit,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    SongModel? currentSong,
    Duration? currentPosition,
    bool? isPreview,
    Duration? previewLimit,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentSong: currentSong ?? this.currentSong,
      currentPosition: currentPosition ?? this.currentPosition,
      isPreview: isPreview ?? this.isPreview,
      previewLimit: previewLimit ?? this.previewLimit,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentSong,
    currentPosition,
    isPreview,
    previewLimit,
  ];
}
