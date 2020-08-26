import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioProgressIndicator extends StatefulWidget {
  @override
  _AudioProgressIndicatorState createState() => _AudioProgressIndicatorState();
}

class _AudioProgressIndicatorState extends State<AudioProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
    Duration currentPos;
    Duration dur;
    return StreamBuilder<Duration>(
        stream: audioPlayerService.audioDuration(),
        initialData: Duration.zero,
        builder: (context, snapshot1) {
          dur = snapshot1.data;
          return StreamBuilder<Duration>(
              stream: audioPlayerService.audioCurrentPosition(),
              initialData: Duration.zero,
              builder: (context, snapshot) {
                currentPos = snapshot.data;
                return SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.25,
                    activeTrackColor: Theme.of(context).primaryColor,
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
