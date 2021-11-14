import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoPlayerService {
  VideoPlayerController videoPlayerController;
  VideoPlayerController  thumbnailVideoPlayerController;

  Future<void> videoControllerInitialization(File file) {
    videoPlayerController = VideoPlayerController.file(file);
    thumbnailVideoPlayerController = VideoPlayerController.file(file);
    videoPlayerController.setLooping(false);
    videoPlayerController.setVolume(0.5);
    thumbnailVideoPlayerController.initialize();
    return videoPlayerController.initialize();
  }

  // videoControllerDispose() {
  //   videoPlayerController.dispose();
  // }
}
