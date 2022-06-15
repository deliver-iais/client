// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

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
  Stream<AudioPlayerState>? get audioCurrentState;

  Stream<Duration?>? get audioCurrentPosition;

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
    try {
      _playerModule.audioCurrentState!
          .listen((event) => _audioCurrentState.add(event));
      _playerModule.audioCurrentPosition!
          .listen((event) => _audioCurrentPosition.add(event!));
    } catch (_) {}
  }

  Future<void> play(String path, String uuid, String name) async {
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  double playbackRate = 1.0;

  final AudioPlayer _fastAudioPlayer = AudioPlayer();

  final AudioPlayer _callFastAudioPlayer = AudioPlayer();

  @override
  Stream<Duration> get audioCurrentPosition => _audioPlayer.onDurationChanged;

  @override
  Stream<AudioPlayerState> get audioCurrentState =>
      _audioPlayer.onPlayerStateChanged.map((event) {
        switch (event) {
          case PlayerState.stopped:
            return AudioPlayerState.STOPPED;
          case PlayerState.playing:
            return AudioPlayerState.PLAYING;
          case PlayerState.paused:
            return AudioPlayerState.PAUSED;
          case PlayerState.completed:
            return AudioPlayerState.COMPLETED;
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
  void playSoundOut() {
    _fastAudioPlayer.play(AssetSource("audios/sound_out.wav"));
  }

  @override
  void playSoundIn() {
    _fastAudioPlayer.play(AssetSource("audios/sound_in.wav"));
  }

  @override
  void resume() {
    _audioPlayer.resume();
  }

  @override
  void playBeepSound() {
    _callFastAudioPlayer.play(AssetSource("audios/beep_sound.mp3"));
  }

  @override
  void stopBeepSound() {
    _callFastAudioPlayer.stop();
  }

  @override
  void playBusySound() {
    _callFastAudioPlayer.play(AssetSource("audios/busy_sound.mp3"));
  }

  @override
  void stopBusySound() {
    _callFastAudioPlayer.play(AssetSource("audios/busy_sound.mp3"));
  }

  @override
  void playIncomingCallSound() {
    _callFastAudioPlayer.play(AssetSource("audios/incoming_call.mp3"));
  }

  @override
  void playEndCallSound() {
    _callFastAudioPlayer.play(
      AssetSource("audios/end_call.mp3"),
      volume: 0.1,
    );
  }

  @override
  void stopIncomingCallSound() {
    _callFastAudioPlayer.stop();
  }

  @override
  void changePlaybackRate(double playbackRate) {
    this.playbackRate = playbackRate;
    _audioPlayer.setPlaybackRate(playbackRate);
  }

  @override
  double getPlaybackRate() {
    return playbackRate;
  }
}

class VlcAudioPlayer implements AudioPlayerModule {
  // final Player _audioPlayer = Player(id: 0);
  // final Player _fastAudioPlayerOut = Player(id: 1);
  // final Player _fastAudioPlayerIn = Player(id: 1);
  // final Player _fastAudioPlayerBeep = Player(id: 2);
  // final Player _fastAudioPlayerBusy = Player(id: 3);

  @override
  Stream<Duration?>? get audioCurrentPosition => null;

  // _audioPlayer.positionStream.map((event) => event.position!);

  @override
  Stream<AudioPlayerState>? get audioCurrentState => null;

  // _audioPlayer.playbackStream.map((event) {
  //   if (event.isCompleted) {
  //     return AudioPlayerState.COMPLETED;
  //   }
  //   if (event.isPlaying) {
  //     return AudioPlayerState.PLAYING;
  //   }
  //   return AudioPlayerState.PAUSED;
  // });

  VlcAudioPlayer() {
    // _fastAudioPlayerOut.open(Media.asset("assets/audios/sound_out.wav"));
    // _fastAudioPlayerIn.open(Media.asset("assets/audios/sound_in.wav"));
  }

  @override
  void play(String path) {
    // _audioPlayer.open(Media.file(File(path)));
    // _audioPlayer.play();
  }

  @override
  void seek(Duration duration) {
    // _audioPlayer.seek(duration);
  }

  @override
  void pause() {
    // _audioPlayer.pause();
  }

  @override
  void stop() {
    //_audioPlayer.stop();
  }

  @override
  void playSoundOut() {
    // _fastAudioPlayerOut.play();
  }

  @override
  void playSoundIn() {
    //_fastAudioPlayerIn.play();
  }

  @override
  void resume() {
    // _audioPlayer.play();
  }

  @override
  void playBeepSound() {
    // _fastAudioPlayerBeep
    //     .open(Media.asset("assets/audios/beep_ringing_calling_sound.mp3"));
    // _fastAudioPlayerBeep.play();
  }

  @override
  void stopBeepSound() {
    // _fastAudioPlayerBeep.stop();
  }

  @override
  void playBusySound() {
    // _fastAudioPlayerBusy.open(Media.asset("assets/audios/busy_sound.mp3"));
    // _fastAudioPlayerBusy.play();
  }

  @override
  void playIncomingCallSound() {}

  @override
  void stopBusySound() {}

  @override
  void stopIncomingCallSound() {}

  @override
  void playEndCallSound() {}

  @override
  void changePlaybackRate(double rate) {}

  @override
  double getPlaybackRate() {
    return 0.0;
  }
}
