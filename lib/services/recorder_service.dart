import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'routing_service.dart';

typedef RecordOnCompleteCallback = void Function(String?);
typedef RecordOnCancelCallback = void Function();
typedef RecordFinallyCallback = void Function();

class RecorderService {
  final _audioPlayerService = GetIt.I.get<AudioService>();
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _fileService = GetIt.I.get<FileService>();
  final _logger = GetIt.I.get<Logger>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _recorder = Record();
  final _uuid = const Uuid();
  final _hasPermission = BehaviorSubject.seeded(false);

  final isRecordingStream = BehaviorSubject.seeded(false);
  final recordingDurationStream = BehaviorSubject.seeded(Duration.zero);
  final recordingAmplitudeStream = BehaviorSubject.seeded(0.0);
  final isLockedSteam = BehaviorSubject.seeded(false);
  final isPaused = BehaviorSubject.seeded(false);
  final recordingRoomStream = BehaviorSubject<Uid?>();

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
    required Uid roomUid,
  }) async {
    if (isRecordingStream.valueOrNull ?? false) {
      await togglePause();
      _routingService.openRoom(recordingRoomStream.value!.asString());
      return;
    } else {
      recordingRoomStream.add(roomUid);
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

    if(isWindows){
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

    if (_audioPlayerService.audioCurrentState.value ==
        AudioPlayerState.playing) {
      _audioPlayerService.pause();
      _recordingFinallyCallbackStream.add(_audioPlayerService.resume);
    }

    _logger.i("recorder starting await $clock.now().millisecondsSinceEpoch");

    await _recorder.start(
      path: path,
      encoder: fileEncoder,
    );

    _logger.i("recorder start $clock.now().millisecondsSinceEpoch");

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

  Future<void> end() async {
    _logger.wtf("recording ended");

    isRecordingStream.add(false);
    recordingRoomStream.add(null);

    quickVibrate();

    final String? path;
    if(await _recorder.isPaused()) {
      await _recorder.resume();
      path = await _recorder.stop();
    }else{
      path = await _recorder.stop();
    }

    var fileLength = await File(path!).length();
    while(fileLength % 1048576 == 0){
      fileLength = File(path).lengthSync();
      await Future.delayed(const Duration(milliseconds: 50));
      print(fileLength);
    }

    _onCompleteCallbackStream.valueOrNull?.call(path);
    _recordingFinallyCallbackStream.valueOrNull?.call();

    _recordingFinallyCallbackStream.add(null);

    return;
  }

  Future<void> cancel() {
    _logger.wtf("1.recording canceled");
    isRecordingStream.add(false);
    recordingRoomStream.add(null);
    quickVibrate();

    _onCancelCallbackStream.valueOrNull?.call();
    _recordingFinallyCallbackStream.valueOrNull?.call();

    _recordingFinallyCallbackStream.add(null);

    return _recorder.stop();
  }
}
