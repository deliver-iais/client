import 'dart:async';
import 'package:camera/camera.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

abstract class CameraService {
  Logger logger = GetIt.I.get<Logger>();

  bool hasMultiCamera();

  Future<void> switchToAnotherCamera();

  Future<File> takePicture();

  Future<void> startVideoRecorder();

  Future<File> stopVideoRecorder();

  Future<bool> initCamera();

  Stream<int> onCameraChanged();

  double getAspectRatio();

  Widget buildPreview({Widget? child});

  Stream<int> getDuration();

  Future<void> changeRecordAudioState();

  Stream<bool> isRecordingVideo();

  Future<void> enableRecordAudio();

  bool enableAudio();

  void dispose();
}

class MobileCameraService extends CameraService {
  Timer? timer;
  late CameraController _controller;
  List<CameraDescription> _cameras = [];
  final BehaviorSubject<int> _duration = BehaviorSubject.seeded(0);
  final ResolutionPreset _resolutionPreset = ResolutionPreset.max;

  final BehaviorSubject<bool> _isRecordingVideo = BehaviorSubject.seeded(false);

  final _checkPermissionService = GetIt.I.get<CheckPermissionsService>();

  final BehaviorSubject<int> _onChanged = BehaviorSubject.seeded(0);

  @override
  Future<bool> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final microphonePermissionIsGranted =
            await _checkPermissionService.checkMicrophonePermissionIsGranted();
        _controller = CameraController(
          _cameras[0],
          _resolutionPreset,
          enableAudio: microphonePermissionIsGranted,
        );
        await Future.delayed(const Duration(milliseconds: 1300));
        await _controller.initialize();
        return true;
      }
    } catch (e) {
      logger.e(e);
    }
    return false;
  }

  @override
  bool hasMultiCamera() {
    return _cameras.length > 1;
  }

  @override
  Future<void> switchToAnotherCamera() async {
    _controller = CameraController(
      _cameras.firstWhere((element) => element != _controller.description),
      _resolutionPreset,
      enableAudio: _controller.enableAudio,
    );
    await _controller.initialize();
    _onChanged.add(_controller.cameraId);
  }

  @override
  Future<File> takePicture() async {
    final file = await _controller.takePicture();
    return File(file.path, file.name, extension: file.mimeType);
  }

  @override
  Future<void> startVideoRecorder() async {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _duration.add(_duration.value + 1);
    });
    await _controller.startVideoRecording();
    _isRecordingVideo.add(_controller.value.isRecordingVideo);
  }

  @override
  Future<File> stopVideoRecorder() async {
    _duration.add(0);
    timer?.cancel();
    final file = await _controller.stopVideoRecording();
    _isRecordingVideo.add(_controller.value.isRecordingVideo);
    return File(file.path, file.name, extension: file.mimeType);
  }

  @override
  Widget buildPreview({Widget? child}) => CameraPreview(
        _controller,
        child: child,
      );

  @override
  Stream<int> onCameraChanged() => _onChanged.stream;

  @override
  double getAspectRatio() => _controller.value.aspectRatio;

  @override
  void dispose() => _controller.dispose();

  @override
  Stream<int> getDuration() {
    return _duration.stream;
  }

  @override
  Future<void> changeRecordAudioState() async {
    _controller = CameraController(
      _controller.description,
      _resolutionPreset,
      enableAudio: !_controller.enableAudio,
    );
    await _controller.initialize();
  }

  @override
  bool enableAudio() => _controller.enableAudio;

  @override
  Stream<bool> isRecordingVideo() => _isRecordingVideo.stream;

  @override
  Future<void> enableRecordAudio() async {
    if (!_controller.enableAudio) {
      _controller = CameraController(
        _controller.description,
        _resolutionPreset,
      );
      await _controller.initialize();
    }
  }
}
