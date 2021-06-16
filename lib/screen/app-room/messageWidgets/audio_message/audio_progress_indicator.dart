import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioProgressIndicator extends StatefulWidget {
  final String audioUuid;
  final double duration;

  const AudioProgressIndicator({Key key, this.audioUuid, this.duration})
      : super(key: key);

  @override
  _AudioProgressIndicatorState createState() => _AudioProgressIndicatorState();
}

class _AudioProgressIndicatorState extends State<AudioProgressIndicator> {
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
  Duration currentPos;
  Duration dur;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
        stream: audioPlayerService.audioCurrentPosition.stream,
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
                max: widget.duration,
                onChanged: (double value) {
                  setState(() {
                    audioPlayerService.seekToSecond(value.toInt());
                    value = value;
                  });
                }),
          );
        });
  }
}
