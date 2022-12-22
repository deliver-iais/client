import 'package:flutter/cupertino.dart';

class Player {
  int id;

  void setRate(_) {}

  void pause() {}

  void seek(_) {}

  List<String> commandlineArguments = <String>[];

  /// State of the current & opened [MediaSource] in [Player] instance.
  CurrentState current = CurrentState();

  /// Stream to listen to current & opened [MediaSource] state of the [Player] instance.
  late Stream<CurrentState> currentStream;

  /// Position & duration state of the [Player] instance.
  PositionState position = PositionState();

  /// Stream to listen to position & duration state of the [Player] instance.
  late Stream<PositionState> positionStream;

  /// Playback state of the [Player] instance.
  PlaybackState playback = PlaybackState();

  /// Stream to listen to playback state of the [Player] instance.
  late Stream<PlaybackState> playbackStream;

  /// Volume & Rate state of the [Player] instance.
  GeneralState general = GeneralState();

  /// Stream to listen to volume & rate state of the [Player] instance.
  late Stream<GeneralState> generalStream;

  /// Explicit video dimensions according to which the pixel buffer will be retrieved & rendered inside the [Video] widget.
  VideoDimensions? preferredVideoDimensions;

  /// Dimensions of the currently playing video.
  VideoDimensions videoDimensions = const VideoDimensions(0, 0);

  /// Stream to listen to dimensions of currently playing video.
  late Stream<VideoDimensions> videoDimensionsStream;

  Player({required this.id});

  void stop() {}

  void open(_) {}

  void play() {}

  void dispose() {}
}

class VideoDimensions {
  /// Width of the video.
  final int width;

  /// Height of the video.
  final int height;

  const VideoDimensions(this.width, this.height);

  @override
  String toString() => 'VideoDimensions($width, $height)';
}

class CurrentState {
  /// Index of currently playing [Media].
  int? index;

  /// Currently playing [Media].
  Media? media;

  /// [List] of [Media] currently opened in the [Player] instance.
  List<Media> medias = <Media>[];

  /// Whether a [Playlist] is opened or a [Media].
  bool isPlaylist = false;
}

/// Position & duration state of a [Player] instance.
class PositionState {
  /// Position of playback in [Duration] of currently playing [Media].
  Duration? position = Duration.zero;

  /// Length of currently playing [Media] in [Duration].
  Duration? duration = Duration.zero;
}

/// Playback state of a [Player] instance.
class PlaybackState {
  /// Whether [Player] instance is playing or not.
  bool isPlaying = false;

  /// Whether [Player] instance is seekable or not.
  bool isSeekable = true;

  /// Whether the current [Media] has ended playing or not.
  bool isCompleted = false;
}

/// Volume & Rate state of a [Player] instance.
class GeneralState {
  /// Volume of [Player] instance.
  double volume = 1.0;

  /// Rate of playback of [Player] instance.
  double rate = 1.0;
}

class Playlist {
  List<Media> medias;

  Playlist({required this.medias});
}

class Media {
  Media.file(_);
}

class DartVLC {
  DartVLC.initialize();
}

class Video extends StatelessWidget {
  final dynamic player;
  final double width;
  final double height;
  final dynamic volumeThumbColor;
  final dynamic volumeActiveColor;

  const Video({
    super.key,
    required this.player,
    required this.width,
    required this.height,
    required this.volumeThumbColor,
    required this.volumeActiveColor,
  });

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
