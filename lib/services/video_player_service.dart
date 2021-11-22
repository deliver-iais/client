import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoPlayerService {
  late VideoPlayerController videoPlayerController;
 late VideoPlayerController  thumbnailVideoPlayerController;

  Future<void> videoControllerInitialization(File file) {
    videoPlayerController = VideoPlayerController.file(file);
    videoPlayerController.setLooping(false);
    videoPlayerController.setVolume(0.5);
    return videoPlayerController.initialize();
  }
  initThumbnailVideoPlayerController(File file){
    thumbnailVideoPlayerController = VideoPlayerController.file(file);
    thumbnailVideoPlayerController.initialize();
    return thumbnailVideoPlayerController.initialize();
  }


}
