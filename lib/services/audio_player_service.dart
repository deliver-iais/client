import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  AudioPlayer audioPlayer;
  AudioCache audioCache;
  String audioUuid;
  String description;
  AudioPlayerState _audioPlayerState;
  Duration lastDur;
  Duration lastPos;

  AudioPlayerService() {
    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    AudioPlayer.logEnabled = true;
    _audioPlayerState = AudioPlayerState.COMPLETED;
  }

  setAudioDetails(String description) {
    this.description = description;
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    this.audioPlayer.seek(newDuration);
  }

  Stream<Duration> get audioCurrentPosition =>
      this.audioPlayer.onAudioPositionChanged;

  Stream<Duration> get audioDuration => this.audioPlayer.onDurationChanged;

  void onCompletion() {
    this._audioPlayerState = AudioPlayerState.COMPLETED;
    audioUuid = '';
  }

  AudioPlayerState get audioPlayerState => this._audioPlayerState;

  void onPlay() {
    this._audioPlayerState = AudioPlayerState.PLAYING;
    this.audioCache.play('audios/r.mp3');
  }

  void onPause() {
    print("say hi");
    this._audioPlayerState = AudioPlayerState.PAUSED;
    this.audioPlayer.pause();
  }

  void onStop() {
    this._audioPlayerState = AudioPlayerState.STOPPED;
    this.audioPlayer.stop();
  }

  void onCmpletion() {
    this._audioPlayerState = AudioPlayerState.COMPLETED;
  }

  bool get isPlaying => _audioPlayerState == AudioPlayerState.PLAYING;

  bool get isPaused => _audioPlayerState == AudioPlayerState.PAUSED;

  bool get isCompleted => _audioPlayerState == AudioPlayerState.COMPLETED;
}
