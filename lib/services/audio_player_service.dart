import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  AudioPlayer audioPlayer;
  AudioCache audioCache;
  String audioUuid;
  String audioName;
  String audioPath;
  String description;
  Duration lastDur;
  Duration lastPos;
  bool isPlaying;

  StreamController<bool> _audioPlayerController;
  Stream<bool> get isOn => _audioPlayerController.stream;

  StreamController<AudioPlayerState> _audioPlayerStateController;

  Stream<AudioPlayerState> get audioPlayerState =>
      _audioPlayerStateController.stream;

  AudioPlayerService() {
    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.setVolume(1);
    AudioPlayer.logEnabled = true;
    _audioPlayerController = StreamController<bool>.broadcast();
    _audioPlayerStateController =
        StreamController<AudioPlayerState>.broadcast();
    _audioPlayerController.add(false);
    isPlaying = false;
  }

  setAudioDetails(String path, String description, String name, String uuid) {
    this.description = description;
    this.audioName = name;
    this.audioUuid = uuid;
    this.audioPath = path;
  }

  resetAudioPlayerService() {
    audioUuid = null;
    audioName = null;
    audioPath = null;
    description = null;
    lastDur = null;
    lastPos = null;
    isPlaying = false;
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    this.audioPlayer.seek(newDuration);
  }

  Stream<Duration> get audioCurrentPosition =>
      this.audioPlayer.onAudioPositionChanged;

  Stream<Duration> get audioDuration => this.audioPlayer.onDurationChanged;

  void onCompletion() {
    resetAudioPlayerService();
    _audioPlayerController.add(false);
    _audioPlayerStateController.add(AudioPlayerState.COMPLETED);
  }

  void onPlay(String path, String uuid, String name) {
    setAudioDetails("Description", path, name, uuid);
    isPlaying = true;
    _audioPlayerController.add(true);
    _audioPlayerStateController.add(AudioPlayerState.PLAYING);
    // this.audioCache.play(audioPath);
    this.audioPlayer.play(path, isLocal: true);
  }

  void onPause() {
    isPlaying = false;
    _audioPlayerStateController.add(AudioPlayerState.PAUSED);
    this.audioPlayer.pause();
  }

  void onStop() {
    resetAudioPlayerService();
    _audioPlayerController.add(false);
    _audioPlayerStateController.add(AudioPlayerState.STOPPED);
    this.audioPlayer.stop();
  }
}
