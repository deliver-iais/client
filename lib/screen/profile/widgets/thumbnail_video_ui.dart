import 'dart:io';
import 'dart:ui';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class VideoThumbnail extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();

  final Uid userUid;
  final int mediaPosition;
  final String videoLength;
  final File thumbnail;
  final int videoCount;
  final Function ? onClick;
  final bool showPlayIcon;
  final bool isExist;

  VideoThumbnail(
      {required this.userUid,
      required this.mediaPosition,
      required this.videoLength,
      required this.thumbnail,
      required this.videoCount,
        this.onClick,
      this.showPlayIcon = false,
      required this.isExist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _routingService.openShowAllVideos(
            context,
            uid: userUid,
            mediaPosition: mediaPosition,
            mediasLength: videoCount,
          );
        },
        child: Stack(
          children: [
            isExist == false
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                        decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: Image.file(thumbnail).image,
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    )),
                  )
                : Container(
                    decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: Image.file(thumbnail).image,
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                  )),
            if (showPlayIcon)
              Center(
                child: MaterialButton(
                  color: Colors.black26,
                  onPressed: () async {
                    onClick!();
                  },
                  shape: CircleBorder(),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  padding: const EdgeInsets.all(10),
                ),
              ),
          ],
        ));
  }
}
