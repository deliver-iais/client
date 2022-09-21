import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/shared/methods/find_file_type.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import 'audio_modules/recorder_module.dart';

class AudioSourcePath {
  final String path;
  final bool isAssets;
  final bool isDeviceFile;
  final bool isUrl;

  AudioSourcePath.file(this.path)
      : isAssets = false,
        isDeviceFile = true,
        isUrl = false;

  AudioSourcePath.url(this.path)
      : isAssets = false,
        isDeviceFile = false,
        isUrl = true;

  AudioSourcePath.asset(this.path)
      : isAssets = true,
        isDeviceFile = false,
        isUrl = false;
}

class AudioTrack {
  final String uuid;
  final String name;
  final String path;
  final Duration duration;

  AudioTrack({
    required this.uuid,
    required this.name,
    required this.path,
    required this.duration,
  });

  AudioTrack.emptyAudioTrack()
      : uuid = "",
        name = "",
        path = "",
        duration = Duration.zero;

  bool isVoice() => isVoiceFile(path);
}

enum AudioPlayerState {
  /// Player is stopped. No file is loaded to the player.
  stopped,

  /// Currently loading a file for [playing].
  loading,

  /// Currently playing a file. The user can [pauseAudio], [resumeAudio] or [stopAudio] the
  /// playback.
  playing,

  /// Paused. The user can [resumeAudio] the playback without providing the URL.
  paused,
}

typedef OnDoneCallback = void Function();

abstract class IntermediatePlayerModule {
  void playSoundOut();

  void playSoundIn();

  void playBeepSound();

  void stopBeepSound();

  void playBusySound();

  void stopBusySound();

  void playIncomingCallSound();

  void stopIncomingCallSound();

  void playEndCallSound();
}

abstract class AudioPlayerModule {
  ValueStream<AudioPlayerState> get stateStream;

  ValueStream<Duration> get positionStream;

  Stream<void> get completedStream;

  void play(String path);

  void pause();

  void resume();

  void seek(Duration duration);

  void stop();

  void setPlaybackRate(double rate);

  double getPlaybackRate();
}

abstract class TemporaryAudioPlayerModule {
  Stream<AudioPlayerState> get stateStream;

  Stream<Duration> get positionStream;

  void play(AudioSourcePath path);

  void stop();
}

AudioPlayerModule getAudioPlayerModule() {
  if (isAndroid || isIOS) {
    return AudioPlayersAudioPlayer();
  } else if (isWindows || isMacOS) {
    return JustAudioAudioPlayer();
  } else {
    return FakeAudioPlayer();
  }
}

IntermediatePlayerModule getIntermediatePlayerModule() {
  if (isAndroid || isIOS || isWindows || isMacOS) {
    return AudioPlayersIntermediatePlayer();
  } else {
    return FakeIntermediatePlayer();
  }
}

class AudioService {
  List<Media> autoPlayMediaList = [];

  //index of next media
  int autoPlayMediaIndex = 0;
  final _mainPlayer = getAudioPlayerModule();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _intermediatePlayer = getIntermediatePlayerModule();
  final _temporaryPlayer = TemporaryAudioPlayer();
  final _recorder = RecorderModule();
  final _fileRepo = GetIt.I.get<FileRepo>();

  final _trackStream = BehaviorSubject<AudioTrack?>();

  final _onDoneCallbackStream = BehaviorSubject<OnDoneCallback?>();

  AudioService() {
    _mainPlayer.completedStream.listen((_) async {

      //todo check to see if message has been edited or deleted
      stopAudio();
      if (autoPlayMediaList.isNotEmpty &&
          autoPlayMediaIndex != autoPlayMediaList.length) {
        final json =
            jsonDecode(autoPlayMediaList[autoPlayMediaIndex].json) as Map;
        final fileUuid = json["uuid"];
        final fileName = json["name"];
        final fileDuration = json["duration"];
        final filePath = await _getFilePathFromMedia();
        if (filePath != null) {
          playAudioMessage(filePath, fileUuid, fileName, fileDuration);
          autoPlayMediaIndex++;

          //looking for new media
          // ignore: invariant_booleans
          if (autoPlayMediaList.length == autoPlayMediaIndex) {
            final list =
                await _mediaQueryRepo.getMediaAutoPlayListPageByMessageId(
              messageId: autoPlayMediaList.last.messageId,
              roomUid: autoPlayMediaList.last.roomId,
              messageTime: autoPlayMediaList.last.createdOn,
            );

            if (list != null && list.isNotEmpty) {
              autoPlayMediaList = list;
              autoPlayMediaIndex = 0;
            }
          }

          //download next file
          if (autoPlayMediaIndex != autoPlayMediaList.length) {
            await _getFilePathFromMedia();
          }
        }
      }
    });
  }

  Future<String?> _getFilePathFromMedia() {
    final json = jsonDecode(autoPlayMediaList[autoPlayMediaIndex].json) as Map;
    final fileUuid = json["uuid"];
    final fileName = json["name"];
    return _fileRepo.getFile(
      fileUuid,
      fileName,
    );
  }

  ValueStream<AudioPlayerState> get playerState => _mainPlayer.stateStream;

  Stream<AudioPlayerState> get temporaryPlayerState =>
      _temporaryPlayer.stateStream;

  ValueStream<Duration> get playerPosition => _mainPlayer.positionStream;

  ValueStream<Duration> get temporaryPlayerPosition =>
      _temporaryPlayer.positionStream;

  Future<Duration?> get temporaryPlayerDuration =>
      _temporaryPlayer._audioPlayer.getDuration();

  ValueStream<AudioTrack?> get track => _trackStream;

  ValueStream<bool> get recorderIsRecording => _recorder.isRecordingStream;

  ValueStream<bool> get recorderIsLocked => _recorder.isLockedSteam;

  ValueStream<bool> get recorderIsPaused => _recorder.isPaused;

  String get recordingRoom => _recorder.recordingRoom;

  ValueStream<Duration> get recordingDuration =>
      _recorder.recordingDurationStream;

  ValueStream<double> get recordingAmplitude =>
      _recorder.recordingAmplitudeStream;

  void playAudioMessage(
    String path,
    String uuid,
    String name,
    double duration,
  ) {
    stopTemporaryAudio();

    if (_trackStream.valueOrNull?.uuid == uuid) {
      _mainPlayer.resume();
    } else {
      final track = AudioTrack(
        uuid: uuid,
        name: name,
        path: path,
        duration: Duration(milliseconds: (duration * 1000).toInt()),
      );

      _trackStream.add(track);

      _mainPlayer.play(path);
    }
  }

  void seekTime(Duration duration) => _mainPlayer.seek(duration);

  void pauseAudio() => _mainPlayer.pause();

  void resumeAudio() {
    stopTemporaryAudio();

    _mainPlayer.resume();
  }

  void stopAudio() {
    _trackStream.add(null);
    _mainPlayer.stop();
  }

  void changeAudioPlaybackRate(double rate) =>
      _mainPlayer.setPlaybackRate(rate);

  double getAudioPlaybackRate() => _mainPlayer.getPlaybackRate();

  void playTemporaryAudio(AudioSourcePath path, {String? prefix}) {
    _temporaryReversiblePause();
    _temporaryPlayer.play(path, prefix: prefix);
  }

  void stopTemporaryAudio() {
    try {
      _temporaryPlayer.stop();
      _temporaryReversiblePlay();
    } catch (_) {}
  }

  void playSoundOut() => _intermediatePlayer.playSoundOut();

  void playSoundIn() => _intermediatePlayer.playSoundIn();

  void playBeepSound() {
    _temporaryReversiblePause();
    _intermediatePlayer.playBeepSound();
  }

  void stopBeepSound() {
    _intermediatePlayer.stopBeepSound();
    _temporaryReversiblePlay();
  }

  void playBusySound() {
    _temporaryReversiblePause();
    _intermediatePlayer.playBusySound();
  }

  void stopBusySound() {
    _intermediatePlayer.stopBusySound();
    _temporaryReversiblePlay();
  }

  void playIncomingCallSound() {
    _temporaryReversiblePause();
    _intermediatePlayer.playIncomingCallSound();
  }

  void stopIncomingCallSound() {
    _intermediatePlayer.stopIncomingCallSound();
    _temporaryReversiblePlay();
  }

  void playEndCallSound() {
    _intermediatePlayer.playEndCallSound();
  }

  void _temporaryReversiblePause() {
    if (_mainPlayer.stateStream.valueOrNull == AudioPlayerState.playing) {
      pauseAudio();
      _onDoneCallbackStream.add(() {
        if (_mainPlayer.stateStream.valueOrNull == AudioPlayerState.paused) {
          resumeAudio();
        }
      });
    }
  }

  void _temporaryReversiblePlay() {
    _onDoneCallbackStream.valueOrNull?.call();
    _onDoneCallbackStream.add(null);
  }

  Future<void> startRecording({
    RecordOnCompleteCallback? onComplete,
    RecordOnCancelCallback? onCancel,
    required String roomUid,
  }) {
    _temporaryReversiblePause();

    return _recorder.start(
      roomUid: roomUid,
      onComplete: (path) {
        onComplete?.call(path);
        _temporaryReversiblePlay();
      },
      onCancel: () {
        onCancel?.call();
        _temporaryReversiblePlay();
      },
    );
  }

  void toggleRecorderPause() => _recorder.togglePause();

  Future<bool> endRecording() async => _recorder.end();

  void cancelRecording() => _recorder.cancel();

  void checkRecorderPermission() => _recorder.checkPermission();

  bool recorderIsAvailable() => _recorder.recorderIsAvailable();

  void lockRecorder() => _recorder.lock();
}

class AudioPlayersIntermediatePlayer implements IntermediatePlayerModule {
  final soundOutSource = AssetSource("audios/sound_out.wav");
  final soundInSource = AssetSource("audios/sound_in.wav");
  final beepSoundSource = AssetSource("audios/beep_sound.mp3");
  final busySoundSource = AssetSource("audios/busy_sound.mp3");
  final incomingCallSource = AssetSource("audios/incoming_call.mp3");
  final endCallSource = AssetSource("audios/end_call.mp3");

  final AudioPlayer _fastAudioPlayer = AudioPlayer(playerId: "fast-audio");
  final AudioPlayer _callAudioPlayer = AudioPlayer(playerId: "call-audio");

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

class AudioPlayersAudioPlayer implements AudioPlayerModule {
  final AudioPlayer _audioPlayer = AudioPlayer(playerId: "default-audio");

  double playbackRate = 1.0;

  @override
  ValueStream<Duration> get positionStream =>
      _audioPlayer.onPositionChanged.shareValueSeeded(Duration.zero);

  @override
  Stream<void> get completedStream => _audioPlayer.onPlayerComplete;

  final _audioCurrentState = BehaviorSubject.seeded(AudioPlayerState.stopped);

  @override
  ValueStream<AudioPlayerState> get stateStream => _audioCurrentState;

  @override
  void play(String path) {
    _audioCurrentState.add(AudioPlayerState.playing);
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
      _audioCurrentState.add(AudioPlayerState.paused);
      _audioPlayer.pause();
    }
  }

  @override
  void stop() {
    _audioCurrentState.add(AudioPlayerState.stopped);
    _audioPlayer.stop();
  }

  @override
  void resume() {
    _audioCurrentState.add(AudioPlayerState.playing);
    _audioPlayer
      ..resume()
      ..setPlaybackRate(playbackRate);
  }

  @override
  void setPlaybackRate(double playbackRate) {
    this.playbackRate = playbackRate;
    _audioPlayer
      ..resume()
      ..setPlaybackRate(playbackRate);
  }

  @override
  double getPlaybackRate() {
    return playbackRate;
  }
}

class JustAudioAudioPlayer implements AudioPlayerModule {
  final _logger = GetIt.I.get<Logger>();

  final _audioPlayer = just_audio.AudioPlayer();

  double playbackRate = 1.0;

  @override
  ValueStream<Duration> get positionStream => _audioPlayer.positionStream
      .mapNotNull((e) => e)
      .shareValueSeeded(Duration.zero);

  final _playerCompleted = BehaviorSubject<void>();

  @override
  Stream get completedStream => _playerCompleted;

  final _audioCurrentState = BehaviorSubject.seeded(AudioPlayerState.stopped);

  final _isProcessCompleted = BehaviorSubject.seeded(false);

  @override
  ValueStream<AudioPlayerState> get stateStream => _audioCurrentState;

  JustAudioAudioPlayer() {
    _audioPlayer.playerStateStream.listen((event) async {
      if (event.processingState == just_audio.ProcessingState.completed &&
          _isProcessCompleted.value != true) {
        _isProcessCompleted.add(true);
        _playerCompleted.add(null);
      } else {
        _isProcessCompleted.add(false);
      }
    });
  }

  @override
  Future<void> play(String path) async {
    try {
      await _audioPlayer.setFilePath(path, initialPosition: Duration.zero);
      await _audioPlayer.seek(Duration.zero);
      _audioCurrentState.add(AudioPlayerState.playing);
      await _audioPlayer.play();
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  void seek(Duration duration) => _audioPlayer.seek(duration);

  @override
  void pause() {
    if (_audioPlayer.playing) {
      _audioCurrentState.add(AudioPlayerState.paused);
      _audioPlayer.pause();
    }
  }

  @override
  void stop() {
    try {
      _audioCurrentState.add(AudioPlayerState.stopped);
      _audioPlayer.stop();
    } catch (_) {}
  }

  @override
  void resume() {
    _audioCurrentState.add(AudioPlayerState.playing);
    _audioPlayer.play();
  }

  @override
  void setPlaybackRate(double playbackRate) {
    this.playbackRate = playbackRate;
    _audioPlayer.setSpeed(playbackRate);
  }

  @override
  double getPlaybackRate() => playbackRate;
}

class FakeAudioPlayer implements AudioPlayerModule {
  @override
  ValueStream<void> get completedStream => BehaviorSubject();

  @override
  BehaviorSubject<Duration> get positionStream => BehaviorSubject();

  @override
  BehaviorSubject<AudioPlayerState> get stateStream => BehaviorSubject();

  @override
  void setPlaybackRate(double rate) {}

  @override
  double getPlaybackRate() => 1.0;

  @override
  void pause() {}

  @override
  void play(String path) {}

  @override
  void resume() {}

  @override
  void seek(Duration duration) {}

  @override
  void stop() {}
}

class FakeIntermediatePlayer implements IntermediatePlayerModule {
  @override
  void playBeepSound() {}

  @override
  void playBusySound() {}

  @override
  void playEndCallSound() {}

  @override
  void playIncomingCallSound() {}

  @override
  void playSoundIn() {}

  @override
  void playSoundOut() {}

  @override
  void stopBeepSound() {}

  @override
  void stopBusySound() {}

  @override
  void stopIncomingCallSound() {}
}

class TemporaryAudioPlayer implements TemporaryAudioPlayerModule {
  final AudioPlayer _audioPlayer = AudioPlayer(playerId: "looped-audio");

  @override
  void play(AudioSourcePath path, {String? prefix}) {
    late final Source source;

    if (path.isDeviceFile) {
      source = DeviceFileSource(path.path);
    } else if (path.isAssets) {
      source = AssetSource(path.path);
    } else {
      source = UrlSource(path.path);
    }
    if (prefix != null) {
      _audioPlayer.audioCache.prefix = prefix;
    }
    _audioPlayer
      ..setReleaseMode(ReleaseMode.loop)
      ..play(source, position: Duration.zero);
  }

  @override
  void stop() {
    _audioPlayer.stop();
  }

  @override
  ValueStream<Duration> get positionStream =>
      _audioPlayer.onPositionChanged.shareValueSeeded(Duration.zero);

  @override
  ValueStream<AudioPlayerState> get stateStream =>
      _audioPlayer.onPlayerStateChanged.map((event) {
        switch (event) {
          case PlayerState.stopped:
            return AudioPlayerState.stopped;
          case PlayerState.playing:
            return AudioPlayerState.playing;
          case PlayerState.paused:
            return AudioPlayerState.paused;
          case PlayerState.completed:
            return AudioPlayerState.stopped;
        }
      }).shareValueSeeded(AudioPlayerState.stopped);
}
