import 'dart:async';
import 'dart:io';
import 'dart:math';

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

class RecorderModule {
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
  String recordingRoom = "";

  final _onCompleteCallbackStream =
      BehaviorSubject<RecordOnCompleteCallback?>();
  final _onCancelCallbackStream = BehaviorSubject<RecordOnCancelCallback?>();

  RecorderModule() {
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
        return _timedCounter(
          const Duration(milliseconds: 100),
        );
      } else {
        return Stream.value(0);
      }
    });

    tickerStream
        .map((counter) => Duration(milliseconds: counter * 100))
        .listen(recordingDurationStream.add);

    tickerStream.throttleTime(const Duration(microseconds: 500)).listen(
      (tickTime) async {
        if (!isWindows) {
          final amplitude = await _recorder.getAmplitude();
          recordingAmplitudeStream.add(
            min(
              max(amplitude.current + 40, 0) / max(amplitude.max + 40, 40),
              1,
            ),
          );
        } else {
          recordingAmplitudeStream.add(
            (Random().nextDouble() * 0.2),
          );
        }
      },
    );
  }

  Stream<int> _timedCounter(Duration interval, [int? maxCount]) async* {
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
    if (isAndroid) {
      _checkPermission.checkAudioRecorderPermission().then(_hasPermission.add);
    } else {
      _hasPermission.add(true);
    }
  }

  Future<void> start({
    RecordOnCompleteCallback? onComplete,
    RecordOnCancelCallback? onCancel,
    required String roomUid,
  }) async {
    if (isRecordingStream.valueOrNull ?? false) {
      await togglePause();
      return;
    } else {
      recordingRoom = roomUid;
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
    //use wav for windows and convert to m4a on file servers :/
    var fileEncoder = AudioEncoder.aacLc;

    if (isWindows) {
      fileType = "ogg";
    }

    // Remove these comment if opus is stable
    // ignore: invariant_booleans, dead_code
    if (isOpusSupported && false) {
      _logger.wtf("ogg is available for recording");

      fileType = "opus";
      fileEncoder = AudioEncoder.opus;
    }

    final path = await _fileService.localFilePath(_uuid.v4(), fileType);

    _logger.wtf("recording path: [$path]");

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
      recordingAmplitudeStream.add(0);
      return _recorder.pause();
    } else {
      isPaused.add(false);
      return _recorder.resume();
    }
  }

  Future<bool> end() async {
    try {
      _logger.wtf("recording ended");

      isRecordingStream.add(false);
      recordingRoom = "";

      quickVibrate();

      final String? path;
      if (await _recorder.isPaused()) {
        await _recorder.resume();
        path = await _recorder.stop();
      } else {
        path = await _recorder.stop();
      }

      var fileLength = await File(path!).length();
      var pathLengthRetry = 4;
      while (fileLength % 1048576 == 0 && pathLengthRetry > 0) {
        fileLength = File(path).lengthSync();
        await Future.delayed(const Duration(milliseconds: 50));
        pathLengthRetry--;
      }

      _onCompleteCallbackStream.valueOrNull?.call(path);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<void> cancel() {
    _logger.wtf("1.recording canceled");
    isRecordingStream.add(false);
    recordingRoom = "";
    quickVibrate();

    _onCancelCallbackStream.valueOrNull?.call();

    return _recorder.stop();
  }
}
