import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_player_widget/mobile_video_player_widget/material_video_controller.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

class MobileVideoPlayerWidget extends StatefulWidget {
  final String videoFilePath;
  final String caption;

  const MobileVideoPlayerWidget({
    super.key,
    required this.videoFilePath, required this.caption,
  });

  @override
  State<MobileVideoPlayerWidget> createState() =>
      _MobileVideoPlayerWidgetState();
}

class _MobileVideoPlayerWidgetState extends State<MobileVideoPlayerWidget> {
  final _uxService = GetIt.I.get<UxService>();
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
      customControls:  MaterialVideoController(caption: widget.caption),
      materialProgressColors: ChewieProgressColors(
        bufferedColor: _uxService.theme.shadowColor.withOpacity(0.4),
        handleColor: Colors.white,
        playedColor: _uxService.theme.primaryColor,
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
