import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VlcVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final Color color;
  final double duration;

  const VlcVideoProgressIndicator(
      {Key? key,
      required this.color,
      required this.duration,
      required this.videoPlayerController})
      : super(key: key);

  @override
  State<VlcVideoProgressIndicator> createState() =>
      _VlcVideoProgressIndicatorState();
}

class _VlcVideoProgressIndicatorState extends State<VlcVideoProgressIndicator> {
  @override
  void initState() {
    widget.videoPlayerController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Duration?>(
        future: widget.videoPlayerController.position,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Slider(
                activeColor: widget.color,
                value: snapshot.hasData && snapshot.data != null
                    ? snapshot.data!.inMilliseconds.toDouble() / 1000
                    : 0.0,
                max: widget.duration,
                onChanged: (dur) {
                  widget.videoPlayerController
                      .seekTo(Duration(milliseconds: (dur * 1000).toInt()));
                });
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
