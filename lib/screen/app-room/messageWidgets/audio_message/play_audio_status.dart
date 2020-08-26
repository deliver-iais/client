import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PlayAudioStatus extends StatefulWidget {
  final File file;
  final int dbId;
  const PlayAudioStatus({Key key, this.file, this.dbId}) : super(key: key);
  @override
  _PlayAudioStatusState createState() => _PlayAudioStatusState();
}

class _PlayAudioStatusState extends State<PlayAudioStatus> {
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
  @override
  void initState() {
    audioPlayerService.audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        audioPlayerService.setAudioPlayerState(AudioPlayerState.COMPLETED);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPlaying =
        audioPlayerService.audioPlayerState == AudioPlayerState.PLAYING;
    return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ExtraTheme.of(context).text,
        ),
        child: IconButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.center,
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Theme.of(context).primaryColor,
            size: 40,
          ),
          onPressed: () {
            setState(() {
              isPlaying
                  ? audioPlayerService.pauseAudio()
                  : audioPlayerService.playAudio();
            });
          },
        ));
  }
}
