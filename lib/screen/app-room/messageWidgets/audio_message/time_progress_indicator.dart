import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TimeProgressIndicator extends StatelessWidget {
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
          return StreamBuilder(
              stream: audioPlayerService.audioCurrentPosition(),
              initialData: Duration.zero,
              builder: (context, snapshot) {
                currentPos = snapshot.data;
                if (dur.inHours > 0)
                  return Container(
                    child: Text(currentPos.toString().split('.')[0] +
                        " / " +
                        dur.toString().split('.')[0]),
                  );
                else
                  return Text(
                    currentPos.toString().split('.')[0].substring(3) +
                        " / " +
                        dur.toString().split('.')[0].substring(3),
                    style: TextStyle(fontSize: 11),
                  );
              });
        });
  }
}
