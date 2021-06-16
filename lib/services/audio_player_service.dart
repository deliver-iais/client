import 'dart:async';

import 'package:audioplayer/audioplayer.dart';

import 'package:deliver_flutter/theme/constants.dart';

import 'package:open_file/open_file.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerService {
  AudioPlayer audioPlayer = AudioPlayer();

  String audioUuid;
  String audioName;
  String audioPath;


  BehaviorSubject<AudioPlayerState> currentState = BehaviorSubject.seeded(AudioPlayerState.STOPPED);

  BehaviorSubject<bool> isOn = BehaviorSubject.seeded(false);


  String CURRENT_AUDIO_ID = "";

  Stream<AudioPlayerState> audioPlayerState(String audioId) {
      return currentState.stream;
  }



  setAudioDetails(String path,String name, String uuid) {
    this.audioPath = path;
    this.audioName = name;
    this.audioUuid = uuid;
  }


  void seekToSecond(int second) {
    this.audioPlayer.seek(second.toDouble());
  }

  BehaviorSubject<Duration> audioCurrentPosition =
      BehaviorSubject.seeded(Duration(seconds: 0));

  void onPlay(String path, String uuid, String name) async {
    setAudioDetails(path, name, uuid);
    currentState.add(AudioPlayerState.PLAYING);
     isOn.add(true);
    if(!uuid.contains(CURRENT_AUDIO_ID))
    await audioPlayer.stop();
    if (isDesktop()) {
      OpenFile.open(path);
    } else {
      CURRENT_AUDIO_ID = uuid;
      audioPlayer.onAudioPositionChanged.listen((event) {
        audioCurrentPosition.add(event);
      });

      audioPlayer.play(path, isLocal: false);
    }
  }

  onPause(String audioId,{bool hideAppBar = false}) {
    if(hideAppBar)
      isOn.add(false);
    currentState.add(AudioPlayerState.PAUSED);
    CURRENT_AUDIO_ID = audioId;
    this.audioPlayer.pause();
  }

  onStop(String audioId) {
    isOn.add(false);
    currentState.add(AudioPlayerState.STOPPED);
    CURRENT_AUDIO_ID = audioId;
    this.audioPlayer.stop();
  }
}
