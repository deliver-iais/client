import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/video/mobile_video_player_widget/material_video_controller.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MobileVideoPlayerWidget extends StatefulWidget {
  final String videoFilePath;
  final String caption;

  const MobileVideoPlayerWidget({
    super.key,
    required this.videoFilePath,
    required this.caption,
  });

  @override
  State<MobileVideoPlayerWidget> createState() =>
      _MobileVideoPlayerWidgetState();
}

class _MobileVideoPlayerWidgetState extends State<MobileVideoPlayerWidget> {
  late VideoPlayerController _controller;
  late final ChewieController _chewieController;

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    _controller = isWeb
        ? VideoPlayerController.network(widget.videoFilePath)
        : VideoPlayerController.file(File(widget.videoFilePath));
    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      showOptions: false,
      customControls: MaterialVideoController(caption: widget.caption),
      materialProgressColors: ChewieProgressColors(
        bufferedColor: settings.themeData.shadowColor.withOpacity(0.4),
        handleColor: Colors.white,
        playedColor: settings.themeData.primaryColor,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? Chewie(
              controller: _chewieController,
            )
          : Container(),
    );
  }
}
