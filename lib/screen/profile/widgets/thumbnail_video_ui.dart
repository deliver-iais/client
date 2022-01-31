import 'dart:io';
import 'dart:ui';
import 'package:deliver/screen/room/messageWidgets/video_message/vedio_palyer_widget.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class VideoWidget extends StatelessWidget {
  final Uid userUid;
  final int mediaPosition;
  final String videoLength;
  final String thumbnail;
  final int videoCount;
  final bool isExist;

  const VideoWidget(
      {Key? key,
      required this.userUid,
      required this.mediaPosition,
      required this.videoLength,
      required this.thumbnail,
      required this.videoCount,
      required this.isExist})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
        onTap: () {
          openVideo(context);
        },
        child: Stack(
          children: [
            isExist
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                        decoration: BoxDecoration(
                      image: DecorationImage(
                        image: kIsWeb
                            ? Image.network(thumbnail).image
                            : Image.file(File(thumbnail)).image,
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        width: 1,
                        color:theme.dividerColor,
                      ),
                    )),
                  )
                : Container(
                    decoration: BoxDecoration(
                    image: DecorationImage(
                      image: kIsWeb
                          ? Image.network(thumbnail).image
                          : Image.file(File(thumbnail)).image,
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      width: 1,
                      color:theme.dividerColor,
                    ),
                  )),
            if (isExist)
              Center(
                child: MaterialButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    openVideo(context);
                  },
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.cyan,
                    size: 30,
                  ),
                  padding: const EdgeInsets.all(10),
                ),
              )
          ],
        ));
  }

  void openVideo(BuildContext context) {
    if (isDesktop()) {
      OpenFile.open(thumbnail);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Hero(
          tag: "",
          child: VideoPlayerWidget(
            videoFilePath: thumbnail,
          ),
        );
      }));
    }
  }
}
