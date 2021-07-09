import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:rxdart/rxdart.dart';

enum AudioPlayerState {
  /// Player is stopped. No file is loaded to the player. Calling [resume] or
  /// [pause] will result in exception.
  STOPPED,

  /// Currently playing a file. The user can [pause], [resume] or [stop] the
  /// playback.
  PLAYING,

  /// Paused. The user can [resume] the playback without providing the URL.
  PAUSED,

  /// The playback has been completed. This state is the same as [STOPPED],
  /// however we differentiate it because some clients might want to know when
  /// the playback is done versus when the user has stopped the playback.
  COMPLETED,
}

class AudioService {
  String _audioUuid;
  String _audioName;
  String _audioPath;

  // ignore: close_sinks
  BehaviorSubject<bool> _isOn = BehaviorSubject.seeded(false);

  // ignore: close_sinks
  BehaviorSubject<AudioPlayerState> _currentState =
      BehaviorSubject.seeded(AudioPlayerState.STOPPED);

  // ignore: close_sinks
  BehaviorSubject<Duration> _audioCurrentPosition =
      BehaviorSubject.seeded(Duration(seconds: 0));

  String get audioUuid => _audioUuid;

  String get audioName => _audioName;

  String get audioPath => _audioPath;

  Stream<bool> get isOn => _isOn.stream;

  Stream<AudioPlayerState> get currentState => _currentState.stream;

  Stream<Duration> get audioCurrentPosition => _audioCurrentPosition.stream;

  AudioPlayer _audioPlayer = AudioPlayer();

  AudioCache _fastAudioPlayer = AudioCache(prefix: 'assets/audios/');

  void play(String path, String uuid, String name) async {
    _audioPath = path;
    _audioUuid = uuid;
    _audioName = name;


  }

  void seekToSecond(int second) {}

  void pause() {}

  void close() {}

  void playAckSound() {
    _fastAudioPlayer.play("ack.mp3", mode: PlayerMode.LOW_LATENCY);
  }

  void playReceivedSound() {
    _fastAudioPlayer.play("r.mp3", mode: PlayerMode.LOW_LATENCY);
  }
}
