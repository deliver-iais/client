import 'package:deliver/screen/profile/widgets/media_page/widget/video/desktop_video_player/desktop_video_player_widget.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';

import 'mobile_video_player_widget/mobile_video_player_widget.dart';

class VideoMediaWidget extends StatelessWidget {
  final String videoFilePath;
  final String caption;

  const VideoMediaWidget(
      {Key? key, required this.videoFilePath, required this.caption})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return DesktopVideoPlayer(
        videoFilePath: videoFilePath,
      );
    } else {
      return MobileVideoPlayerWidget(
        videoFilePath: videoFilePath,
        caption: caption,
      );
    }
  }
}
