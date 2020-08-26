import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  AudioPlayer audioPlayer;
  AudioCache audioCache;
  String audioName;
  String description;
  AudioPlayerState state;

  AudioPlayerService() {
    print('constructor of audioPlayerService');
    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    AudioPlayer.logEnabled = true;
    state = AudioPlayerState.COMPLETED;
  }

  setAudioDetails(String audioName, String description) {
    this.audioName = audioName;
    this.description = description;
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    this.audioPlayer.seek(newDuration);
  }

  Stream<Duration> audioCurrentPosition() {
    return this.audioPlayer.onAudioPositionChanged;
  }

  Stream<Duration> audioDuration() {
    return this.audioPlayer.onDurationChanged;
  }

  AudioPlayerState get audioPlayerState => this.state;

  void setAudioPlayerState(AudioPlayerState newState) {
    this.state = newState;
  }

  void playAudio() {
    this.state = AudioPlayerState.PLAYING;
    this.audioCache.play("audios/r.mp3");
  }

  void pauseAudio() {
    audioPlayer.pause();
    this.state = AudioPlayerState.PAUSED;
  }
}
