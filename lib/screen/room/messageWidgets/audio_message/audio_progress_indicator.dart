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
  Duration? currentPos;
  Duration? dur;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
        stream: audioPlayerService.audioCurrentPosition(),
        builder: (context, snapshot1) {
          return StreamBuilder<Duration>(
              stream: audioPlayerService.audioCurrentPosition(),
              builder: (context, snapshot2) {
                currentPos = snapshot2.data ?? currentPos;
                if (currentPos != null) {
                  return Slider(
                      value: currentPos!.inSeconds.toDouble(),
                      min: 0.0,
                      max: widget.duration,
                      onChanged: (double value) {
                        setState(() {
                          audioPlayerService
                              .seek(Duration(seconds: value.toInt()));
                          value = value;
                        });
                      });
                } else {
                  return const SizedBox.shrink();
                }
              });
        });
  }
}
