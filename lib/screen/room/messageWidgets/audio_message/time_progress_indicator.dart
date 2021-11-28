import 'package:deliver/services/audio_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TimeProgressIndicator extends StatefulWidget {
  final String audioUuid;
  final double duration;

  const TimeProgressIndicator(
      {Key? key, required this.audioUuid, required this.duration})
      : super(key: key);

  @override
  _TimeProgressIndicatorState createState() => _TimeProgressIndicatorState();
}

class _TimeProgressIndicatorState extends State<TimeProgressIndicator> {
  final audioPlayerService = GetIt.I.get<AudioService>();
  Duration ? currentPos;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioPlayerState>(
        stream: audioPlayerService.audioCurrentState(),
        builder: (c, state) {
          if (state.hasData &&
                  state.data != null &&
                  state.data == AudioPlayerState.PLAYING ||
              state.data == AudioPlayerState.PAUSED) {
            return StreamBuilder(
                stream: audioPlayerService.audioUuid,
                builder: (c, uuid) {
                  if (uuid.hasData &&
                      uuid.data.toString().contains(widget.audioUuid)) {
                    return StreamBuilder<Duration>(
                        stream: audioPlayerService.audioCurrentPosition(),
                        builder: (context, snapshot2) {
                          currentPos = Duration.zero;

                          return Text(
                            currentPos.toString().split('.')[0].substring(2) +
                                " / " +
                                "${Duration(seconds: widget.duration.toInt()).toString().substring(0, 7)}",
                            style: TextStyle(
                                fontSize: 11,
                                color: ExtraTheme.of(context).textField),
                          );
                        });
                  } else
                    return buildText(context);
                });
          } else {
            return buildText(context);
          }
        });
  }

  Text buildText(BuildContext context) {
    return Text(
      "00:00" +
          " / " +
          "${Duration(seconds: widget.duration.toInt()).toString().substring(0, 7)}",
      style: TextStyle(fontSize: 11, color: ExtraTheme.of(context).textField),
    );
  }
}
