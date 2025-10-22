import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  Timer? _progressTimer;

  PlayerBloc() : super(const PlayerState()) {
    on<PlayerPlaySong>(_onPlaySong);
    on<PlayerPause>(_onPause);
    on<PlayerResume>(_onResume);
    on<PlayerStop>(_onStop);
    on<PlayerSeek>(_onSeek);
    on<PlayerUpdateProgress>(_onUpdateProgress);
    on<PlayerNext>(_onNext);
    on<PlayerPrevious>(_onPrevious);
    on<PlayerToggleShuffle>(_onToggleShuffle);
    on<PlayerToggleRepeat>(_onToggleRepeat);
    on<PlayerSetPlaylist>(_onSetPlaylist);
  }

  Future<void> _onPlaySong(
    PlayerPlaySong event,
    Emitter<PlayerState> emit,
  ) async {
    _stopProgressTimer();

    emit(
      state.copyWith(
        status: PlayerStatus.loading,
        currentSong: event.song,
        currentPosition: Duration.zero,
        isPreview: event.isPreview,
        previewLimit: event.isPreview ? const Duration(seconds: 10) : null,
      ),
    );

    // Simular carga
    await Future.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(status: PlayerStatus.playing));
    _startProgressTimer();
  }

  void _onPause(PlayerPause event, Emitter<PlayerState> emit) {
    _stopProgressTimer();
    emit(state.copyWith(status: PlayerStatus.paused));
  }

  void _onResume(PlayerResume event, Emitter<PlayerState> emit) {
    emit(state.copyWith(status: PlayerStatus.playing));
    _startProgressTimer();
  }

  void _onStop(PlayerStop event, Emitter<PlayerState> emit) {
    _stopProgressTimer();
    emit(const PlayerState());
  }

  void _onSeek(PlayerSeek event, Emitter<PlayerState> emit) {
    emit(state.copyWith(currentPosition: event.position));
  }

  void _onUpdateProgress(
    PlayerUpdateProgress event,
    Emitter<PlayerState> emit,
  ) {
    if (state.isPreview && state.previewLimit != null) {
      if (event.position >= state.previewLimit!) {
        add(const PlayerStop());
        return;
      }
    }

    if (state.currentSong != null &&
        event.position >= state.currentSong!.duration) {
      // Auto-play next song or stop based on repeat mode
      if (state.repeatMode == RepeatMode.one) {
        add(PlayerPlaySong(state.currentSong!));
      } else if (state.playlist.isNotEmpty &&
          (state.repeatMode == RepeatMode.all ||
              state.currentIndex < state.playlist.length - 1)) {
        add(const PlayerNext());
      } else {
        add(const PlayerStop());
      }
      return;
    }

    emit(state.copyWith(currentPosition: event.position));
  }

  void _onNext(PlayerNext event, Emitter<PlayerState> emit) {
    if (state.playlist.isEmpty) return;

    int nextIndex;
    if (state.isShuffled) {
      // Random next song (excluding current)
      final random = DateTime.now().millisecondsSinceEpoch % state.playlist.length;
      nextIndex = random;
    } else {
      nextIndex = state.currentIndex + 1;
      if (nextIndex >= state.playlist.length) {
        if (state.repeatMode == RepeatMode.all) {
          nextIndex = 0;
        } else {
          return; // No more songs
        }
      }
    }

    final nextSong = state.playlist[nextIndex];
    emit(state.copyWith(currentIndex: nextIndex));
    add(PlayerPlaySong(nextSong));
  }

  void _onPrevious(PlayerPrevious event, Emitter<PlayerState> emit) {
    if (state.playlist.isEmpty) return;

    // If more than 3 seconds into song, restart it
    if (state.currentPosition.inSeconds > 3) {
      add(const PlayerSeek(Duration.zero));
      return;
    }

    int prevIndex;
    if (state.isShuffled) {
      // Random previous song (excluding current)
      final random = DateTime.now().millisecondsSinceEpoch % state.playlist.length;
      prevIndex = random;
    } else {
      prevIndex = state.currentIndex - 1;
      if (prevIndex < 0) {
        if (state.repeatMode == RepeatMode.all) {
          prevIndex = state.playlist.length - 1;
        } else {
          prevIndex = 0; // Stay at first song
        }
      }
    }

    final prevSong = state.playlist[prevIndex];
    emit(state.copyWith(currentIndex: prevIndex));
    add(PlayerPlaySong(prevSong));
  }

  void _onToggleShuffle(PlayerToggleShuffle event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isShuffled: !state.isShuffled));
  }

  void _onToggleRepeat(PlayerToggleRepeat event, Emitter<PlayerState> emit) {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    emit(state.copyWith(repeatMode: nextMode));
  }

  void _onSetPlaylist(PlayerSetPlaylist event, Emitter<PlayerState> emit) {
    emit(state.copyWith(
      playlist: event.songs,
      currentIndex: 0,
    ));
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == PlayerStatus.playing) {
        add(
          PlayerUpdateProgress(
            state.currentPosition + const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  @override
  Future<void> close() {
    _stopProgressTimer();
    return super.close();
  }
}
