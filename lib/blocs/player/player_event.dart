import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerPlaySong extends PlayerEvent {
  final SongModel song;
  final bool isPreview;

  const PlayerPlaySong(this.song, {this.isPreview = false});

  @override
  List<Object?> get props => [song, isPreview];
}

class PlayerPause extends PlayerEvent {
  const PlayerPause();
}

class PlayerResume extends PlayerEvent {
  const PlayerResume();
}

class PlayerStop extends PlayerEvent {
  const PlayerStop();
}

class PlayerSeek extends PlayerEvent {
  final Duration position;

  const PlayerSeek(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerUpdateProgress extends PlayerEvent {
  final Duration position;

  const PlayerUpdateProgress(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerNext extends PlayerEvent {
  const PlayerNext();
}

class PlayerPrevious extends PlayerEvent {
  const PlayerPrevious();
}

class PlayerToggleShuffle extends PlayerEvent {
  const PlayerToggleShuffle();
}

class PlayerToggleRepeat extends PlayerEvent {
  const PlayerToggleRepeat();
}

class PlayerSetPlaylist extends PlayerEvent {
  final List<SongModel> songs;

  const PlayerSetPlaylist(this.songs);

  @override
  List<Object?> get props => [songs];
}
