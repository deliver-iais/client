import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioProgressIndicator extends StatefulWidget {
  final String audioUuid;

  const AudioProgressIndicator({Key key, this.audioUuid}) : super(key: key);
  @override
  _AudioProgressIndicatorState createState() => _AudioProgressIndicatorState();
}

class _AudioProgressIndicatorState extends State<AudioProgressIndicator> {
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
  Duration currentPos;
  Duration dur;
  @override
  void initState() {
    if (audioPlayerService.audioUuid == widget.audioUuid) {
      currentPos = audioPlayerService.lastPos;
      dur = audioPlayerService.lastDur;
    }
    super.initState();
  }

  @override
  void dispose() {
    audioPlayerService.lastDur = dur;
    audioPlayerService.lastPos = currentPos;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
        stream: audioPlayerService.audioDuration,
        builder: (context, snapshot1) {
          dur = snapshot1.data ?? dur ?? Duration.zero;
          return StreamBuilder<Duration>(
              stream: audioPlayerService.audioCurrentPosition,
              builder: (context, snapshot2) {
                currentPos = snapshot2.data ?? currentPos ?? Duration.zero;
                return SliderTheme(
                  data: SliderThemeData(
                    thumbColor: ExtraTheme.of(context).active,
                    trackHeight: 2.25,
                    activeTrackColor: ExtraTheme.of(context).active,
                    inactiveTrackColor: ExtraTheme.of(context).text,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
                  ),
                  child: Slider(
                      value: currentPos.inSeconds.toDouble(),
                      min: 0.0,
                      max: dur.inSeconds.toDouble(),
                      onChanged: (double value) {
                        setState(() {
                          audioPlayerService.seekToSecond(value.toInt());
                          value = value;
                        });
                      }),
                );
              });
        });
  }
}
