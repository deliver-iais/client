import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/screen/profile/widgets/media_view/media_view_widget.dart';

import 'package:deliver/screen/room/messageWidgets/video_message/video_player_widget/desktop_video_player_widget.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_player_widget/mobile_video_player_widget/mobile_video_player_widget.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';

class AllVideoPage extends StatelessWidget {
  final String roomUid;
  final int messageId;
  final int? initIndex;
  final Message? message;
  final String? filePath;

  const AllVideoPage({
    super.key,
    required this.roomUid,
    required this.messageId,
    this.initIndex,
    this.message,
    this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return MediaViewWidget(
      roomUid: roomUid,
      messageId: messageId,
      filePath: filePath,
      initIndex: initIndex,
      message: message,
      mediaType: MediaType.VIDEO,
      mediaUiWidget: (filePath, caption) {
        if (isDesktop) {
          return DesktopVideoPlayer(
            videoFilePath: filePath,
          );
        } else {
          return MobileVideoPlayerWidget(
            videoFilePath: filePath,
            caption: caption,
          );
        }
      },
    );
  }
}
