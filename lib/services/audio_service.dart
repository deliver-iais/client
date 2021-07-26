import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:deliver_flutter/theme/constants.dart';
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

abstract class AudioPlayerInterface {
  Stream<AudioPlayerState> get audioCurrentState;

  Stream<Duration> get audioCurrentPosition;

  play(String path);

  void seek(Duration duration) {}

  void pause() {}

  void stop() {}

  void playSoundOut();

  void playSoundIn();

  void resume() {}
}

class AudioPlayerOne implements AudioPlayerInterface {
  AudioPlayer _audioPlayer = AudioPlayer();

  AudioCache _fastAudioPlayer = AudioCache(prefix: 'assets/audios/');

  @override
  Stream<Duration> get audioCurrentPosition =>
      _audioPlayer.onAudioPositionChanged;

  @override
  Stream<AudioPlayerState> get audioCurrentState =>
      _audioPlayer.onPlayerStateChanged.map((event) {
        switch (event) {
          case PlayerState.STOPPED:
            return AudioPlayerState.STOPPED;
            break;
          case PlayerState.PLAYING:
            return AudioPlayerState.PLAYING;
            break;
          case PlayerState.PAUSED:
            return AudioPlayerState.PAUSED;
            break;
          case PlayerState.COMPLETED:
            return AudioPlayerState.COMPLETED;
            break;
          default:
            return AudioPlayerState.STOPPED;
        }
      });

  @override
  play(String path) {
    _audioPlayer.play(path, isLocal: false);
  }

  @override
  void seek(Duration duration) {
    _audioPlayer.seek(duration);
  }

  @override
  void pause() {
    _audioPlayer.pause();
  }

  @override
  void stop() {
    _audioPlayer.stop();
  }

  @override
  void playSoundOut() {
    _fastAudioPlayer.play("sound_out.wav", mode: PlayerMode.LOW_LATENCY);
  }

  @override
  void playSoundIn() {
    _fastAudioPlayer.play("sound_in.wav", mode: PlayerMode.LOW_LATENCY);
  }

  @override
  void resume() {
    _audioPlayer.resume();
  }
}

class AudioPlayerTwo implements AudioPlayerInterface {
  Player _audioPlayer = Player(id: 0);
  Player _fastAudioPlayerOut = Player(id: 1);
  Player _fastAudioPlayerIn = Player(id: 1);

  @override
  Stream<Duration> get audioCurrentPosition =>
      _audioPlayer.positionStream.map((event) => event.position);

  @override
  Stream<AudioPlayerState> get audioCurrentState =>
      _audioPlayer.playbackStream.map((event) {
        if (event.isCompleted) {
          return AudioPlayerState.COMPLETED;
        }
        if (event.isPlaying) {
          return AudioPlayerState.PLAYING;
        }
        return AudioPlayerState.PAUSED;
      });

  AudioPlayerTwo() {
    _fastAudioPlayerOut.open(Media.asset("assets/audios/sound_out.wav"));
    _fastAudioPlayerIn.open(Media.asset("assets/audios/sound_in.wav"));
  }

  @override
  play(String path) {
    _audioPlayer.open(Media.file(File(path)));
    _audioPlayer.play();
  }

  @override
  void seek(Duration duration) {
    _audioPlayer.seek(duration);
  }

  @override
  void pause() {
    _audioPlayer.pause();
  }

  @override
  void stop() {
    _audioPlayer.stop();
  }

  @override
  void playSoundOut() {
    _fastAudioPlayerOut.play();
  }

  @override
  void playSoundIn() {
    _fastAudioPlayerIn.play();
  }

  @override
  void resume() {
    _audioPlayer.play();
  }
}

class AudioService {
  // ignore: close_sinks
  BehaviorSubject<String> _audioUuid = BehaviorSubject.seeded("");

  String _audioName;
  String _audioPath;

  // ignore: close_sinks
  BehaviorSubject<bool> _audioCenterIsOn = BehaviorSubject.seeded(false);

  AudioPlayerInterface _player;

  // ignore: close_sinks
  BehaviorSubject<AudioPlayerState> _audioCurrentState =
      BehaviorSubject.seeded(AudioPlayerState.STOPPED);

  // ignore: close_sinks
  BehaviorSubject<Duration> _audioCurrentPosition =
      BehaviorSubject.seeded(Duration.zero);

  String get audioName => _audioName;

  String get audioPath => _audioPath;

  Stream<String> get audioUuid => _audioUuid.stream;

  Stream<bool> get audioCenterIsOn => _audioCenterIsOn.stream;

  Stream<AudioPlayerState> audioCurrentState() => _audioCurrentState.stream;

  Stream<Duration> audioCurrentPosition() => _audioCurrentPosition.stream;

  AudioService() {
    if (isLinux() || isWindows()) {
      _player = AudioPlayerTwo();
    } else {
      _player = AudioPlayerOne();
    }
    _player.audioCurrentState.listen((event) => _audioCurrentState.add(event));
    _player.audioCurrentPosition
        .listen((event) => _audioCurrentPosition.add(event));
  }

  void play(String path, String uuid, String name) async {
    // check if this the current audio which is playing or paused recently
    if (_audioUuid.value == uuid) {
      _audioCenterIsOn.add(true);
      _player.resume();
      return;
    }
    _audioUuid.add(uuid);
    _audioPath = path;
    _audioName = name;
    _audioCenterIsOn.add(true);
    _player.play(path);
  }

  void seek(Duration duration) {
    _player.seek(duration);
  }

  void pause() {
    _player.pause();
  }

  void stop() {
    _player.stop();
  }

  void close() {
    _player.pause();
    _audioCenterIsOn.add(false);
  }

  void playSoundOut() {
    _player.playSoundOut();
  }

  void playSoundIn() {
    _player.playSoundIn();
  }

  void resume() {
    _player.resume();
  }
}
