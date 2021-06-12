import 'dart:async';


import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/models/AudioPlayerState.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:open_file/open_file.dart';

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

  Map<String, StreamController<AudioPlayerState>> _audioPlayerStateController;

  // TODO, why we can access variable of class directly!!
  String CURRENT_AUDIO_ID = "";

  Stream<AudioPlayerState> audioPlayerState(String audioId) {
    try {
      return _audioPlayerStateController[audioId].stream;
    } catch (e) {
      onCompletion(audioId);
    }
  }

  AudioPlayerService() {
    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.setVolume(1);
    AudioPlayer.logEnabled = true;
    _audioPlayerController =
        _audioPlayerController = StreamController<bool>.broadcast();
    _audioPlayerStateController = Map();
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

  void onCompletion(String audioId) {
    resetAudioPlayerService();
    _audioPlayerController.add(false);
    StreamController<AudioPlayerState> d =
        StreamController<AudioPlayerState>.broadcast();
    d.add(AudioPlayerState.COMPLETED);
    _audioPlayerStateController[audioId] = d;
  }

  void onPlay(String path, String uuid, String name) {
    if (isDesktop()) {
      OpenFile.open(path);
    } else {
      CURRENT_AUDIO_ID = uuid;
      _audioPlayerStateController.keys.forEach((element) {
        _audioPlayerStateController[element].add(AudioPlayerState.STOPPED);
      });
      setAudioDetails("Description", path, name, uuid);
      isPlaying = true;
      _audioPlayerController.add(true);
      _audioPlayerStateController[uuid].add(AudioPlayerState.PLAYING);
      this.audioPlayer.play(path, isLocal: true);
    }
  }

  onPause(String audioId) {
    CURRENT_AUDIO_ID = "";
    isPlaying = false;
    _audioPlayerStateController[audioId].add(AudioPlayerState.PAUSED);
    this.audioPlayer.pause();
  }

  onStop(String audioId) {
    CURRENT_AUDIO_ID = "";
    resetAudioPlayerService();
    _audioPlayerController.add(false);
    _audioPlayerStateController[audioId].add(AudioPlayerState.STOPPED);
    this.audioPlayer.stop();
  }
}
