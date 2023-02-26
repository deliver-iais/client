import 'dart:async';

import 'package:camera/camera.dart';
import 'package:deliver/models/file.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

abstract class CameraService {
  Logger logger = GetIt.I.get<Logger>();

  bool cameraIsAvailable();

  bool switchToCameraOIsAvailable();

  Future<void> switchToAnotherCamera();

  Future<File> takePicture();

  Future<void> startVideoRecorder();

  Future<File> stopVideoRecorder();

  Future<bool> initCamera();

  Stream<bool> changeCamera();

  double getAspectRatio();

  Widget buildPreview();

  Stream<int> getDuration();

  void dispose();
}

class AndroidAndWebCameraService extends CameraService {
  Timer? timer;
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  BehaviorSubject<int> duration = BehaviorSubject.seeded(0);

  BehaviorSubject<bool> switchTo = BehaviorSubject.seeded(true);

  @override
  bool cameraIsAvailable() {
    return false;
  }

  @override
  Future<bool> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras[0],
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _controller!.initialize();
        return true;
      }
    } catch (e) {
      logger.e(e);
    }
    return false;
  }

  @override
  bool switchToCameraOIsAvailable() {
    return _cameras.length > 1;
  }

  @override
  Future<void> switchToAnotherCamera() async {
    _controller = CameraController(
      _cameras.firstWhere((element) => element != _controller!.description),
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _controller!.initialize();
    switchTo.add(!switchTo.value);
  }

  @override
  Future<File> takePicture() async {
    final file = await _controller!.takePicture();
    return File(file.path, file.name, extension: file.mimeType);
  }

  @override
  Future<void> startVideoRecorder() async {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      duration.add(duration.value + 1);
    });
    await _controller!.startVideoRecording();
  }

  @override
  Future<File> stopVideoRecorder() async {
    duration.add(0);
    timer?.cancel();
    final file = await _controller!.stopVideoRecording();
    return File(file.path, file.name, extension: file.mimeType);
  }

  @override
  Widget buildPreview() => CameraPreview(
        _controller!,
      );

  @override
  Stream<bool> changeCamera() => switchTo.stream;

  @override
  double getAspectRatio() => _controller!.value.aspectRatio;

  @override
  void dispose() => _controller?.dispose();

  @override
  Stream<int> getDuration() {
    return duration.stream;
  }
}
