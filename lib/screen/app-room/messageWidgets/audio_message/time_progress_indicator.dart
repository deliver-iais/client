import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TimeProgressIndicator extends StatefulWidget {
  final String audioUuid;

  const TimeProgressIndicator({Key key, this.audioUuid}) : super(key: key);

  @override
  _TimeProgressIndicatorState createState() => _TimeProgressIndicatorState();
}

class _TimeProgressIndicatorState extends State<TimeProgressIndicator> {
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
  Duration currentPos;
  Duration dur;

  @override
  void initState() {
    super.initState();
    if (audioPlayerService.audioUuid == widget.audioUuid) {
      currentPos = audioPlayerService.lastPos;
      dur = audioPlayerService.lastDur;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioPlayerState>(
        stream: audioPlayerService.audioPlayerState(widget.audioUuid),
        builder: (c, state) {
          if (state.hasData &&
                  state.data != null &&
                  state.data == AudioPlayerState.PLAYING ||
              audioPlayerService.CURRENT_AUDIO_ID.contains(widget.audioUuid)) {
            return StreamBuilder<Duration>(
                stream: audioPlayerService.audioDuration,
                builder: (context, snapshot1) {
                  dur = snapshot1.data ?? dur ?? Duration.zero;
                  return StreamBuilder<Duration>(
                      stream: audioPlayerService.audioCurrentPosition,
                      builder: (context, snapshot2) {
                        currentPos = audioPlayerService.audioName == null
                            ? Duration.zero
                            : snapshot2.data ?? currentPos ?? Duration.zero;
                        if (dur.inHours > 0)
                          return Container(
                            child: Text(currentPos.toString().split('.')[0] +
                                " / " +
                                dur.toString().split('.')[0]),
                          );
                        return Text(
                          currentPos.toString().split('.')[0].substring(2) +
                              " / " +
                              dur.toString().split('.')[0].substring(2),
                          style: TextStyle(fontSize: 11),
                        );
                      });
                });
          } else {
            return Text(
              currentPos.toString().split('.')[0].substring(3) +
                  " / " +
                  dur.toString().split('.')[0].substring(3),
              style: TextStyle(fontSize: 11),
            );
          }
        });
  }
}
