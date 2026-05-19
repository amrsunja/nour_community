import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerState extends Equatable {
  final String? currentUrl;
  final ProcessingState processingState;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final String? errorMessage;

  const AudioPlayerState({
    required this.currentUrl,
    required this.processingState,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.errorMessage,
  });

  bool get isLoading =>
      processingState == ProcessingState.loading ||
      processingState == ProcessingState.buffering;

  bool get isCompleted => processingState == ProcessingState.completed;

  bool get isIdle => processingState == ProcessingState.idle;

  bool isCurrent(String url) => currentUrl == url;

  AudioPlayerState copyWith({
    Object? currentUrl = _sentinel,
    ProcessingState? processingState,
    bool? isPlaying,
    Duration? position,
    Object? duration = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AudioPlayerState(
      currentUrl: identical(currentUrl, _sentinel)
          ? this.currentUrl
          : currentUrl as String?,
      processingState: processingState ?? this.processingState,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: identical(duration, _sentinel)
          ? this.duration
          : duration as Duration?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();

  static const AudioPlayerState initial = AudioPlayerState(
    currentUrl: null,
    processingState: ProcessingState.idle,
    isPlaying: false,
    position: Duration.zero,
    duration: null,
    errorMessage: null,
  );

  @override
  List<Object?> get props => [
        currentUrl,
        processingState,
        isPlaying,
        position,
        duration,
        errorMessage,
      ];
}
