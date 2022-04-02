import 'dart:math';

import 'package:deliver/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioProgressIndicator extends StatefulWidget {
  final String audioUuid;
  final double duration;

  const AudioProgressIndicator(
      {Key? key, required this.audioUuid, required this.duration})
      : super(key: key);

  @override
  _AudioProgressIndicatorState createState() => _AudioProgressIndicatorState();
}

class _AudioProgressIndicatorState extends State<AudioProgressIndicator> {
  final audioPlayerService = GetIt.I.get<AudioService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
        stream: audioPlayerService.audioCurrentPosition(),
        builder: (context, duration) {
          if (duration.hasData && duration.data != null) {
            return Slider(
                value:
                    min(duration.data!.inMilliseconds / 1000, widget.duration),
                max: widget.duration,
                onChanged: (value) {
                  setState(() {
                    audioPlayerService.seek(Duration(
                      seconds: value.floor(),
                    ));
                    value = value;
                  });
                });
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
