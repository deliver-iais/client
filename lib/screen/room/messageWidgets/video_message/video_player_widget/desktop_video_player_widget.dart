import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';

class DesktopVideoPlayer extends StatefulWidget {
  final String videoFilePath;
  final bool showAppBar;

  const DesktopVideoPlayer({
    Key? key,
    required this.videoFilePath,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  State<DesktopVideoPlayer> createState() => _DesktopVideoPlayerState();
}

class _DesktopVideoPlayerState extends State<DesktopVideoPlayer> {
  final Player _videoPlayer = Player(
    id: 0,
    registerTexture: !isWindows,
  );

  @override
  void dispose() {
    _videoPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoPlayer.open(
      Playlist(
        medias: [
          Media.file(
            File(widget.videoFilePath),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: widget.showAppBar ? AppBar() : null,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => (isWindows)
              ? NativeVideo(
                  player: _videoPlayer,
                  width: constraints.maxWidth,
                  height: mq.size.height,
                  volumeThumbColor: theme.colorScheme.primary,
                  volumeActiveColor: theme.colorScheme.primary,
                )
              : Video(
                  player: _videoPlayer,
                  width: constraints.maxWidth,
                  height: mq.size.height,
                  volumeThumbColor: theme.colorScheme.primary,
                  volumeActiveColor: theme.colorScheme.primary,
                ),
        ),
      ),
    );
  }
}
