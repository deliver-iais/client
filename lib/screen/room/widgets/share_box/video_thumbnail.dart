import 'dart:io';

import 'package:deliver/screen/room/widgets/share_box/file_box_item_icon.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  final String path;

  const VideoThumbnail({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  VideoThumbnailState createState() => VideoThumbnailState();
}

class VideoThumbnailState extends State<VideoThumbnail>
    with AutomaticKeepAliveClientMixin {
  String thumb = '';
  bool loading = true;
  late VideoPlayerController _controller;
  late final theme=Theme.of(context);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            loading = false;
          }); //when your thumbnail will show.
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading
        ? buildFileIcon( Icons.videocam_rounded,theme,theme.colorScheme.tertiary)
        : VideoPlayer(_controller);
  }

  @override
  bool get wantKeepAlive => true;
}
