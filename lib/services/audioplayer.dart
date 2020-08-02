import 'package:audioplayers/audioplayers.dart' as AudioPlayerLib;
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioPlayer extends StatelessWidget{

  String audioUrl;
  AudioPlayerLib.AudioPlayer audioPlayer;

  AudioPlayer({this.audioUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: <Widget>[
            IconButton(icon: Icon(Icons.play_circle_filled),
                color: Colors.blue, onPressed: (){

                }),
            Positioned(
              child: Container(
                width:16.0,
                height: 16.0,
                decoration: new BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
              top: 28.0,
              right: 0.0,
            ),
          ],
        ),
      ),
    );
  }



}