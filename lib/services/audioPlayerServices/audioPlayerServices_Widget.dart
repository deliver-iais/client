import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';


class AudioPlayerServices extends StatefulWidget {
  String url;

  @override
  _LocalAudio createState() => _LocalAudio();

  AudioPlayerServices({this.url});
}

class _LocalAudio extends State<AudioPlayerServices> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer audioplayer;
  AudioCache audioCache;
  bool isDownloaded;
  IconData _iconData = Icons.file_download;
  int _playState = 0;
  int playCurrentaudio = 0;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  void initPlayer() {
    audioplayer = new AudioPlayer();
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

  Widget showButtonSheep() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.64,
            minChildSize: 0.2,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsetsDirectional.only(bottom: 110),
                      child: ListView.builder(
                          controller: scrollController,
                          itemCount: musicList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext ctxt, int index) =>
                              AudioListWidget(
                                music: musicList[index],
                              )),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              Text("musicc"),
                              slider(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.repeat_one),
                                      onPressed: () {}),
                                  IconButton(
                                      icon: Icon(Icons.skip_previous),
                                      onPressed: () {}),
                                  IconButton(
                                      icon: Icon(Icons.play_circle_filled),
                                      onPressed: () {}),
                                  IconButton(
                                    icon: Icon(Icons.skip_next),
                                    onPressed: () {},
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: <Widget>[
                                              IconButton(
                                                  icon: Icon(Icons.arrow_forward),
                                                  onPressed: () {
                                                    //todo froward music...
                                                  }),
                                              Text("Forward"),
                                            ],
                                          )),
                                      PopupMenuItem(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: <Widget>[
                                            IconButton(
                                                icon: Icon(Icons.share),
                                                onPressed: () {
                                                  //todo share music...
                                                }),
                                            Text("Share"),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: <Widget>[
                                              IconButton(
                                                  icon: Icon(Icons.arrow_downward),
                                                  onPressed: () {
                                                    //todo save in  music album...
                                                  }),
                                              Text("Save to music"),
                                            ],
                                          ))
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioplayer.seek(newDuration);
  }

  List musicList = [
    "music1111 11 1.11111",
    "111111",
    "music 2222.222222",
    "music 333333 ",
    "33333",
    "333333 ",
    "music ",
    "44444",
    "4444",
    "4444444",
    "music",
    "55555",
  ];

  @override
  Widget build(BuildContext context) {
   return showButtonSheep();
  }
}

class AudioListWidget extends StatelessWidget {
  String music;

  AudioListWidget({this.music});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 10,
        ),
        IconButton(
            icon: Icon(Icons.play_circle_filled),
            color: Colors.blue,
            iconSize: 45,
            onPressed: () {}),
        SizedBox(
          width: 40,
        ),
        Text(
          this.music,
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}
