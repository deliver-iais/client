import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart' as AudioPlayerLib;
import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AudioPlayer extends StatefulWidget {
  String url;

  AudioPlayer({this.url});

  @override
  _LocalAudio createState() => _LocalAudio(this.url);

}

class _LocalAudio extends State<AudioPlayer> {

  String url;

  _LocalAudio(this.url);

  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayerLib.AudioPlayer audioplayer;
  AudioCache audioCache;
  bool isDownloaded;
  IconData _iconData = Icons.file_download;
  int _playState = 0;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }
  void initPlayer() {
    audioplayer = new AudioPlayerLib.AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioplayer);

    audioplayer.durationHandler = (d) => setState(() {
      _duration = d;
    });

    audioplayer.positionHandler = (p) => setState(() {
      _position = p;
    });
  }

  String localFilePath;

  Widget slider() {
    return Slider(
        activeColor: Colors.teal,
        inactiveColor: Colors.black54,
        value: _position.inSeconds.toDouble(),
        min: 0.0,
        max: _duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            seekToSecond(value.toInt());
            value = value;
          });
        });
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioplayer.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          //   LocalAudio(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(_iconData),
                    iconSize: 65,
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        switch (_playState) {
                          case 0:
                            audioCache.play('disco.mp3');
                            _iconData = Icons.pause;
                            _playState = 1;
                            break;
                          case 1:
                            audioplayer.pause();
                            _iconData = Icons.play_circle_filled;
                            _playState = 2;
                            break;

                          case 2:
                            audioplayer.resume();
                            _iconData = Icons.pause;
                            _playState = 1;
                            break;
                        }
                      });
                    },
                  ),

                  Text("10 min"),
                ],
              ),

              Column(
                children: <Widget>[
                  Text("Music .........."),
                  _playState == 0 ? Text("Music name") : slider(),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
