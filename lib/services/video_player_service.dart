import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoPlayerService {
  VideoPlayerController videoPlayerController;

  Future<void> videoControllerInitialization(File file) {
    videoPlayerController = VideoPlayerController.file(file);
    videoPlayerController.setLooping(false);
    videoPlayerController.setVolume(0.5);
    return videoPlayerController.initialize();
  }

  videoControllerDispose() {
    videoPlayerController.dispose();
  }

  videoControllerPause(){
    videoPlayerController.pause();
  }
}
