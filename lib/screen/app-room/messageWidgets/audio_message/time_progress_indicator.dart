import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/services/audio_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TimeProgressIndicator extends StatefulWidget {
  final String audioUuid;
  final double duration;

  const TimeProgressIndicator({Key key, this.audioUuid, this.duration})
      : super(key: key);

  @override
  _TimeProgressIndicatorState createState() => _TimeProgressIndicatorState();
}

class _TimeProgressIndicatorState extends State<TimeProgressIndicator> {
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
  Duration currentPos;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioPlayerState>(
        stream: audioPlayerService.audioPlayerState(widget.audioUuid),
        builder: (c, state) {
          if (state.hasData &&
              state.data != null &&
              state.data == AudioPlayerState.PLAYING) {
            return StreamBuilder(
                stream: audioPlayerService.currentAudioId.stream,
                builder: (c, uuid) {
                  if (uuid.hasData && uuid.data.toString().contains(widget.audioUuid)) {
                    return StreamBuilder<Duration>(
                        stream: audioPlayerService.audioCurrentPosition.stream,
                        builder: (context, snapshot2) {
                          currentPos = audioPlayerService.audioName == null
                              ? Duration.zero
                              : snapshot2.data ?? currentPos ?? Duration.zero;

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
