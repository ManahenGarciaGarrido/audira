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
      add(const PlayerStop());
      return;
    }

    emit(state.copyWith(currentPosition: event.position));
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
