import 'dart:io';

import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/video_player_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

class VideoPalyingDetails extends StatefulWidget {
  // final File video;
  final  fileId;
  final fileName;

  const VideoPalyingDetails({Key key, this.fileId,this.fileName}) : super(key: key);

  @override
  _VideoPalyingDetailsState createState() => _VideoPalyingDetailsState();
}

class _VideoPalyingDetailsState extends State<VideoPalyingDetails> {
  VideoPlayerService videoPlayerService = GetIt.I.get<VideoPlayerService>();
  FileRepo _fileRepo = GetIt.I.get<FileRepo>();

  @override
  void dispose() {
    videoPlayerService.videoControllerDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future:_fileRepo.getFile(widget.fileId, widget.fileName) ,
      builder: (context, snapshot2){
      return FutureBuilder(
          future: videoPlayerService.videoControllerInitialization(snapshot2.data),
          builder: (context, snapshot2) {
            videoPlayerService.videoPlayerController.play();
            // return Stack(
            //   children: [
            //     VideoPlayer(videoPlayerService.videoPlayerController),
            //     // Center(
            //     //     child: Container(
            //     //       width: 50,
            //     //       height: 50,
            //     //       decoration: BoxDecoration(
            //     //         shape: BoxShape.circle,
            //     //         color: Colors.black.withOpacity(0.5),
            //     //       ),
            //     //       child: IconButton(
            //     //         icon: Icon(Icons.play_arrow),
            //     //         color:  Colors.white10,
            //     //         onPressed: () {
            //     //
            //     //           videoPlayerService.videoPlayerController.play();
            //     //         }
            //     //       ),
            //     //     ))
            //   ],
            // );
          });},
    );
  }
}
