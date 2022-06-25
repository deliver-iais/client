import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

enum AudioPlayerState {
  /// Player is stopped. No file is loaded to the player. Calling [resume] or
  /// [pause] will result in exception.
  stopped,

  /// Currently playing a file. The user can [pause], [resume] or [stop] the
  /// playback.
  playing,

  /// Paused. The user can [resume] the playback without providing the URL.
  paused,

  /// The playback has been completed. This state is the same as [stopped],
  /// however we differentiate it because some clients might want to know when
  /// the playback is done versus when the user has stopped the playback.
  completed,
}

abstract class AudioPlayerModule {
  Stream<AudioPlayerState>? get audioCurrentState;

  Stream<Duration?>? get audioCurrentPosition;

  Stream<Duration?>? get audioDuration;

  Stream get playerCompleteSubscription;

  void play(String path);

  void seek(Duration duration) {}

  void pause() {}

  void stop() {}

  void resume();

  void playSoundOut();

  void playSoundIn();

  void playBeepSound();

  void stopBeepSound();

  void playBusySound();

  void stopBusySound();

  void playIncomingCallSound();

  void stopIncomingCallSound();

  void playEndCallSound();

  void changePlaybackRate(double rate);

  double getPlaybackRate();
}

class AudioService {
  final _playerModule = GetIt.I.get<AudioPlayerModule>();

  // ignore: close_sinks
  final _audioCenterIsOn = BehaviorSubject.seeded(false);

  // ignore: close_sinks
  final _audioCurrentState = BehaviorSubject.seeded(AudioPlayerState.stopped);

  // ignore: close_sinks
  final _audioUuid = BehaviorSubject.seeded("");

  // ignore: close_sinks
  final _audioCurrentPosition = BehaviorSubject.seeded(Duration.zero);

  String _audioName = "";

  String _audioPath = "";

  Duration _audioDuration = Duration.zero;

  String get audioName => _audioName;

  String get audioPath => _audioPath;

  BehaviorSubject<String> get audioUuid => _audioUuid;

  BehaviorSubject<bool> get audioCenterIsOn => _audioCenterIsOn;

  BehaviorSubject<AudioPlayerState> get audioCurrentState => _audioCurrentState;

  Duration get audioDuration => _audioDuration;

  BehaviorSubject<Duration> audioCurrentPosition() => _audioCurrentPosition;

  AudioService() {
    try {
      _playerModule.audioCurrentState!
          .listen((event) => _audioCurrentState.add(event));
      _playerModule.audioCurrentPosition!.listen((position) {
        _audioCurrentPosition.add(position!);
      });
      _playerModule.playerCompleteSubscription.listen((event) {
        _audioCurrentState.add(AudioPlayerState.completed);
        _audioCenterIsOn.add(false);
      });
    } catch (_) {}
  }

  Future<void> play(
    String path,
    String uuid,
    String name,
    double duration,
  ) async {
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
    _audioDuration = Duration(milliseconds: (duration * 1000).toInt());
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

  void resume() {
    _playerModule.resume();
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

  void stopBeepSound() {
    _playerModule.stopBeepSound();
  }

  void playBusySound() {
    _playerModule.playBusySound();
  }

  void stopBusySound() {
    _playerModule.stopBusySound();
  }

  void playIncomingCallSound() {
    _playerModule.playIncomingCallSound();
  }

  void stopIncomingCallSound() {
    _playerModule.stopIncomingCallSound();
  }

  void playEndCallSound() {
    _playerModule.playEndCallSound();
  }

  void changePlayBackRate(double rate) {
    _playerModule.changePlaybackRate(rate);
  }

  double getPlayBackRate() {
    return _playerModule.getPlaybackRate();
  }
}

class NormalAudioPlayer implements AudioPlayerModule {
  final soundOutSource = AssetSource("audios/sound_out.wav");
  final soundInSource = AssetSource("audios/sound_in.wav");
  final beepSoundSource = AssetSource("audios/beep_sound.mp3");
  final busySoundSource = AssetSource("audios/busy_sound.mp3");
  final incomingCallSource = AssetSource("audios/incoming_call.mp3");
  final endCallSource = AssetSource("audios/end_call.mp3");

  final AudioPlayer _audioPlayer = AudioPlayer(playerId: "default-audio");
  final AudioPlayer _fastAudioPlayer = AudioPlayer(playerId: "fast-audio");
  final AudioPlayer _callAudioPlayer = AudioPlayer(playerId: "call-audio");

  double playbackRate = 1.0;

  @override
  Stream<Duration> get audioCurrentPosition => _audioPlayer.onPositionChanged;

  @override
  Stream get playerCompleteSubscription => _audioPlayer.onPlayerComplete;

  @override
  Stream<Duration?>? get audioDuration => _audioPlayer.onDurationChanged;

  @override
  Stream<AudioPlayerState> get audioCurrentState =>
      _audioPlayer.onPlayerStateChanged.map((event) {
        switch (event) {
          case PlayerState.stopped:
            return AudioPlayerState.stopped;
          case PlayerState.playing:
            return AudioPlayerState.playing;
          case PlayerState.paused:
            return AudioPlayerState.paused;
          case PlayerState.completed:
            return AudioPlayerState.completed;
        }
      });

  @override
  void play(String path) {
    _audioPlayer
      ..play(DeviceFileSource(path))
      ..setPlaybackRate(playbackRate);
  }

  @override
  void seek(Duration duration) {
    _audioPlayer.seek(duration);
  }

  @override
  void pause() {
    if (_audioPlayer.state == PlayerState.playing) {
      _audioPlayer.pause();
    }
  }

  @override
  void stop() {
    _audioPlayer.stop();
  }

  @override
  void resume() {
    _audioPlayer.resume();
  }

  @override
  void changePlaybackRate(double playbackRate) {
    this.playbackRate = playbackRate;
    _audioPlayer
      ..resume()
      ..setPlaybackRate(playbackRate);
  }

  @override
  double getPlaybackRate() {
    return playbackRate;
  }

  @override
  void playSoundOut() {
    _fastAudioPlayer.play(soundOutSource, position: Duration.zero);
  }

  @override
  void playSoundIn() {
    _fastAudioPlayer.play(soundInSource, position: Duration.zero);
  }

  @override
  void playBeepSound() {
    _callAudioPlayer.play(beepSoundSource, position: Duration.zero);
  }

  @override
  void stopBeepSound() {
    _callAudioPlayer.stop();
  }

  @override
  void playBusySound() {
    _callAudioPlayer.play(busySoundSource, position: Duration.zero);
  }

  @override
  void stopBusySound() {
    _callAudioPlayer.stop();
  }

  @override
  void playIncomingCallSound() {
    _callAudioPlayer.play(incomingCallSource, position: Duration.zero);
  }

  @override
  void playEndCallSound() {
    _callAudioPlayer.play(endCallSource, position: Duration.zero, volume: 0.1);
  }

  @override
  void stopIncomingCallSound() {
    _callAudioPlayer.stop();
  }
}
