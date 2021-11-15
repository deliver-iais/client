import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:get_it/get_it.dart';
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

abstract class AudioPlayerModule {
  Stream<AudioPlayerState> get audioCurrentState;

  Stream<Duration> get audioCurrentPosition;

  play(String path);

  void seek(Duration duration) {}

  void pause() {}

  void stop() {}

  void playSoundOut();

  void playSoundIn();

  void playBeepSound();

  void resume();

  void stopPlayBeepSound();

  void playBusySound();
}

class AudioService {
  final _playerModule = GetIt.I.get<AudioPlayerModule>();

  // ignore: close_sinks
  final _audioCenterIsOn = BehaviorSubject.seeded(false);

  // ignore: close_sinks
  final _audioCurrentState = BehaviorSubject.seeded(AudioPlayerState.STOPPED);

  // ignore: close_sinks
  final _audioUuid = BehaviorSubject.seeded("");

  // ignore: close_sinks
  final _audioCurrentPosition = BehaviorSubject.seeded(Duration.zero);

  String _audioName = "";

  String _audioPath = "";

  String get audioName => _audioName;

  String get audioPath => _audioPath;

  Stream<String> get audioUuid => _audioUuid.stream;

  Stream<bool> get audioCenterIsOn => _audioCenterIsOn.stream;

  Stream<AudioPlayerState> audioCurrentState() => _audioCurrentState.stream;

  Stream<Duration> audioCurrentPosition() => _audioCurrentPosition.stream;

  AudioService() {
    _playerModule.audioCurrentState
        .listen((event) => _audioCurrentState.add(event));
    _playerModule.audioCurrentPosition
        .listen((event) => _audioCurrentPosition.add(event));
  }

  void play(String path, String uuid, String name) async {
    // check if this the current audio which is playing or paused recently
    // and if played recently, just resume it
    if (_audioUuid.value == uuid) {
      _audioCenterIsOn.add(true);
      _playerModule.resume();
      return;
    }
    _audioUuid.add(uuid);
    _audioPath = path;
    _audioName = name;
    _audioCenterIsOn.add(true);
    _playerModule.play(path);
  }

  void seek(Duration duration) {
    _playerModule.seek(duration);
  }

  void pause() {
    _playerModule.pause();
  }

  void stop() {
    _playerModule.stop();
  }

  void close() {
    _playerModule.pause();
    _audioCenterIsOn.add(false);
  }

  void playSoundOut() {
    _playerModule.playSoundOut();
  }

  void playSoundIn() {
    _playerModule.playSoundIn();
  }

  void playBeepSound() {
    _playerModule.playBeepSound();
  }

  void resume() {
    _playerModule.resume();
  }

  void stopPlayBeepSound() {
    _playerModule.stopPlayBeepSound();
  }

  void playBusySound() {
    _playerModule.playBusySound();
  }
}

class NormalAudioPlayer implements AudioPlayerModule {
  AudioPlayer _audioPlayer = AudioPlayer();

  AudioCache _fastAudioPlayer =
      AudioCache(prefix: 'assets/audios/', fixedPlayer: AudioPlayer());

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

  @override
  void playBeepSound() {
    _fastAudioPlayer.play(
      "beep_ringing_calling_sound.mp3",
    );
  }

  void stopPlayBeepSound() {
    _fastAudioPlayer.fixedPlayer.stop();
  }

  @override
  void playBusySound() {
    _fastAudioPlayer.play(
      "busy_sound.mp3",
    );
  }
}

class VlcAudioPlayer implements AudioPlayerModule {
  Player _audioPlayer = Player(id: 0);
  Player _fastAudioPlayerOut = Player(id: 1);
  Player _fastAudioPlayerIn = Player(id: 1);
  Player _fastAudioPlayerBeep = Player(id: 1);
  Player _fastAudioPlayerBusy = Player(id: 1);

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

  VlcAudioPlayer() {
    _fastAudioPlayerOut.open(Media.asset("assets/audios/sound_out.wav"));
    _fastAudioPlayerIn.open(Media.asset("assets/audios/sound_in.wav"));
    _fastAudioPlayerBeep
        .open(Media.asset("assets/audios/beep_ringing_calling_sound.mp3"));
    _fastAudioPlayerBusy.open(Media.asset("assets/audios/busy_sound.mp3"));
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

  @override
  void playBeepSound() {
    _fastAudioPlayerBeep.play();
  }

  void stopPlayBeepSound() {
    _fastAudioPlayerBeep.stop();
  }

  @override
  void playBusySound() {
    _fastAudioPlayerBusy.play();
  }
}
