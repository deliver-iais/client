import 'dart:async';
import 'dart:math';

import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

typedef RecordOnCompleteCallback = void Function(String?);
typedef RecordOnCancelCallback = void Function();
typedef RecordFinallyCallback = void Function();

class RecorderService {
  final _audioPlayerService = GetIt.I.get<AudioService>();
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _fileService = GetIt.I.get<FileService>();
  final _logger = GetIt.I.get<Logger>();
  final _recorder = Record();
  final _uuid = const Uuid();
  final _hasPermission = BehaviorSubject.seeded(false);

  final isRecordingStream = BehaviorSubject.seeded(false);
  final recordingDurationStream = BehaviorSubject.seeded(Duration.zero);
  final recordingAmplitudeStream = BehaviorSubject.seeded(0.0);
  final isLockedSteam = BehaviorSubject.seeded(false);
  final isPaused = BehaviorSubject.seeded(false);

  final _recordingFinallyCallbackStream =
      BehaviorSubject<RecordFinallyCallback?>();
  final _onCompleteCallbackStream =
      BehaviorSubject<RecordOnCompleteCallback?>();
  final _onCancelCallbackStream = BehaviorSubject<RecordOnCancelCallback?>();

  RecorderService() {
    isRecordingStream.listen((isRecording) {
      if (!isRecording) {
        isLockedSteam.add(false);
        isPaused.add(false);
        recordingDurationStream.add(Duration.zero);
        recordingAmplitudeStream.add(0);
      }
    });

    final tickerStream = isRecordingStream.switchMap((isRecording) {
      if (isRecording) {
        return timedCounter(
          const Duration(milliseconds: 10),
        );
      } else {
        return Stream.value(0);
      }
    });

    tickerStream
        .map((counter) => Duration(milliseconds: counter * 10))
        .listen(recordingDurationStream.add);

    tickerStream.listen(
      (tickTime) async {
        final amplitude = await _recorder.getAmplitude();
        recordingAmplitudeStream
            .add((amplitude.current + 40) / (amplitude.max + 50));
      },
    );
  }

  Stream<int> timedCounter(Duration interval, [int? maxCount]) async* {
    var i = 0;
    while (true) {
      await Future.delayed(interval);
      if (!(isPaused.valueOrNull ?? false)) {
        yield i++;
      }
      if (i == maxCount) break;
    }
  }

  bool recorderIsAvailable() => true;

  void checkPermission() {
    _logger.wtf("Checking recording permission");

    if (isAndroid) {
      _checkPermission.checkAudioRecorderPermission().then(_hasPermission.add);
    } else {
      _hasPermission.add(true);
    }
  }

  Future<void> start({
    RecordOnCompleteCallback? onComplete,
    RecordOnCancelCallback? onCancel,
  }) async {
    if (isRecordingStream.valueOrNull ?? false) {
      await cancel();
      isRecordingStream.add(false);
    }

    if (!_hasPermission.value) {
      _logger.wtf("There is no permission for recording voice");

      return;
    }

    // Check supports of recording options...
    final isOpusSupported = await _recorder.isEncoderSupported(
      AudioEncoder.opus,
    );

    var fileType = "m4a";
    var fileEncoder = AudioEncoder.aacLc;

    if (isOpusSupported && false) {
      _logger.wtf("opus is available for recording");

      fileType = "opus";
      fileEncoder = AudioEncoder.opus;
    }

    final path = await _fileService.localFilePath(_uuid.v4(), fileType);

    _logger.wtf("recording path: [$path]");

    if (_audioPlayerService.audioCurrentState.value ==
        AudioPlayerState.playing) {
      _audioPlayerService.pause();
      _recordingFinallyCallbackStream.add(_audioPlayerService.resume);
    }

    await _recorder.start(
      path: path,
      encoder: fileEncoder,
    );

    _onCompleteCallbackStream.add(onComplete);
    _onCancelCallbackStream.add(onCancel);

    quickVibrate();

    _logger.wtf("recording started");

    unawaited(_recorder.isRecording().then(isRecordingStream.add));
  }

  void lock() {
    if (isRecordingStream.valueOrNull ?? false) {
      quickVibrate();

      isLockedSteam.add(true);
    }
  }

  Future<void> togglePause() async {
    if (!await _recorder.isPaused()) {
      isPaused.add(true);
      return _recorder.pause();
    } else {
      isPaused.add(false);
      return _recorder.resume();
    }
  }

  Future<void> end() async {
    _logger.wtf("recording ended");

    isRecordingStream.add(false);

    quickVibrate();

    final path = await _recorder.stop();

    _onCompleteCallbackStream.valueOrNull?.call(path);
    _recordingFinallyCallbackStream.valueOrNull?.call();

    return;
  }

  Future<void> cancel() {
    _logger.wtf("recording canceled");

    isRecordingStream.add(false);

    quickVibrate();

    _onCancelCallbackStream.valueOrNull?.call();
    _recordingFinallyCallbackStream.valueOrNull?.call();

    return _recorder.stop();
  }
}
