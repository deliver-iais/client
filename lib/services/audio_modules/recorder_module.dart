import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

typedef RecordOnCompleteCallback = void Function(String?);
typedef RecordOnCancelCallback = void Function();
typedef RecordFinallyCallback = void Function();

class RecorderModule {
  final _requestLock = Lock();

  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _logger = GetIt.I.get<Logger>();
  final _recorder = Record();

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

    final tickerStream = isRecordingStream.distinct().switchMap((isRecording) {
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
          try {
            final amplitude = await _recorder.getAmplitude();
            recordingAmplitudeStream.add(
              min(
                max(amplitude.current + 40, 0) / max(amplitude.max + 40, 40),
                1,
              ),
            );
          } catch (e) {
            _logger.e(e);
            recordingAmplitudeStream.add(
              (Random().nextDouble() * 0.2),
            );
          }
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

  Future<void> start({
    RecordOnCompleteCallback? onComplete,
    RecordOnCancelCallback? onCancel,
    required String roomUid,
  }) async {
    await _requestLock.synchronized(() async {
      if (isAndroid || isIOS) {
        if (!(await _checkPermission.checkAudioRecorderPermission())) {
          _logger.wtf("There is no permission for recording voice");
          return;
        }
      }

      if (isRecordingStream.valueOrNull ?? false) {
        await togglePause();
        return;
      } else {
        recordingRoom = roomUid;
      }

      isRecordingStream.add(true);

      // Check supports of recording options...
      final isOpusSupported = await _recorder.isEncoderSupported(
        AudioEncoder.aacLc,
      );
      _logger.wtf("isOpusSupported: [$isOpusSupported]");

      await _recorder.start();

      _onCompleteCallbackStream.add(onComplete);
      _onCancelCallbackStream.add(onCancel);

      quickVibrate();

      _logger.wtf("recording started");
      isRecordingStream.add(await _recorder.isRecording());
    });
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
    return _requestLock.synchronized(() async {
      try {
        _logger.wtf("recording ended");

        isRecordingStream.add(false);
        recordingRoom = "";

        quickVibrate();
        final recordingDuration =
            recordingDurationStream.valueOrNull ?? Duration.zero;
        if (recordingDuration.inMilliseconds < 300) {
          return true;
        }

        String? path;
        if (await _recorder.isPaused()) {
          await _recorder.resume();
          path = await _recorder.stop();
        } else {
          path = await _recorder.stop();
        }
        if (path == null) {
          _logger.e("no path exist after recording");
          return false;
        }

        path = trimRecorderSavedPath(path);

        var fileLength = await File(path).length();
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
    });
  }

  Future<void> cancel() async {
    await _requestLock.synchronized(() async {
      _logger.wtf("1.recording canceled");
      isRecordingStream.add(false);
      recordingRoom = "";
      quickVibrate();

      _onCancelCallbackStream.valueOrNull?.call();

      return _recorder.stop();
    });
  }
}
