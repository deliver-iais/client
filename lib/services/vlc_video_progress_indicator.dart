import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcVideoProgressIndicator extends StatefulWidget {
  final VlcPlayerController vlcPlayerController;
  final Color color;
  final double duration;

  const VlcVideoProgressIndicator(
      {Key? key, required this.vlcPlayerController, required this.color,required this.duration}) : super(key: key);

  @override
  State<VlcVideoProgressIndicator> createState() =>
      _VlcVideoProgressIndicatorState();
}

class _VlcVideoProgressIndicatorState extends State<VlcVideoProgressIndicator> {
  @override
  void initState() {
    widget.vlcPlayerController.addListener(() {
      setState(() {});
    });
    super.initState();
  }


  @override
  void dispose() {
    widget.vlcPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Duration>(
        future: widget.vlcPlayerController.getPosition(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Slider(
                activeColor: widget.color,
                value: snapshot.hasData && snapshot.data != null
                    ? snapshot.data!.inMilliseconds.toDouble() / 1000
                    : 0.0,
                max: widget.duration,
                onChanged: (dur) {
                  widget.vlcPlayerController
                      .seekTo(Duration(milliseconds: (dur * 1000).toInt()));
                });
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
