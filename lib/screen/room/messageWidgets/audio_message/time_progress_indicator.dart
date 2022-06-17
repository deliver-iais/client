import 'package:deliver/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TimeProgressIndicator extends StatefulWidget {
  final String audioUuid;
  final double duration;

  const TimeProgressIndicator({
    super.key,
    required this.audioUuid,
    required this.duration,
  });

  @override
  TimeProgressIndicatorState createState() => TimeProgressIndicatorState();
}

class TimeProgressIndicatorState extends State<TimeProgressIndicator> {
  static final audioPlayerService = GetIt.I.get<AudioService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioPlayerState>(
      stream: audioPlayerService.audioCurrentState(),
      builder: (c, state) {
        if (state.hasData &&
                state.data != null &&
                state.data == AudioPlayerState.playing ||
            state.data == AudioPlayerState.paused) {
          return StreamBuilder(
            stream: audioPlayerService.audioUuid,
            builder: (c, uuid) {
              if (uuid.hasData &&
                  uuid.data.toString().contains(widget.audioUuid)) {
                return StreamBuilder<Duration>(
                  stream: audioPlayerService.audioCurrentPosition(),
                  builder: (context, snapshot2) {
                    if (snapshot2.hasData && snapshot2.data != null) {
                      return Text(
                        "${snapshot2.data.toString().substring(0, 7)} / ${Duration(seconds: widget.duration.toInt()).toString().substring(0, 7)}",
                        style: const TextStyle(fontSize: 11),
                      );
                    } else {
                      return buildText(context);
                    }
                  },
                );
              } else {
                return buildText(context);
              }
            },
          );
        } else {
          return buildText(context);
        }
      },
    );
  }

  Text buildText(BuildContext context) {
    return Text(
      "00:00:00 / ${Duration(seconds: widget.duration.toInt()).toString().substring(0, 7)}",
      style: const TextStyle(fontSize: 11),
    );
  }
}
