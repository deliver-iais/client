import 'package:deliver/models/file.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/video/mobile_video_player_widget/mobile_video_player_widget.dart';
import 'package:deliver/screen/room/widgets/share_box/share_box_input_caption.dart';
import 'package:flutter/material.dart';

class VideoViewerPage extends StatelessWidget {
  final File file;
  final Function(String) onSend;

  const VideoViewerPage({super.key, required this.file, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Center(
              child: MobileVideoPlayerWidget(
                videoFilePath: file.path,
                caption: "",
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: ShareBoxInputCaption(
              count: 1,
              onSend: (path) {
                onSend(path);
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
