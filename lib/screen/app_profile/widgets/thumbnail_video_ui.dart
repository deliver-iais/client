import 'dart:io';
import 'dart:ui';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class VideoThumbnail extends StatelessWidget {
  File thumbnail;
  int videoCount;
  String videoLength;
  bool isExist;
  Uid userUid;
  int mediaPosition;
  var _routingService = GetIt.I.get<RoutingService>();

  VideoThumbnail(
      {@required this.userUid,
      @required this.mediaPosition,
      @required this.videoLength,
      this.thumbnail,
      this.videoCount,
      this.isExist});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _routingService.openShowAllVideos(
            uid: userUid,
            mediaPosition: mediaPosition,
            mediasLength: videoCount,
          );
        },
        child: Stack(
          children: [
            isExist == false?
            ImageFiltered(
                 imageFilter: ImageFilter.blur(
                    sigmaX: 4,sigmaY: 4),
              child: Container(
                  decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: Image.file(thumbnail).image,
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  width: 1,
                  color: ExtraTheme.of(context).secondColor,
                ),
              )),
            ):
            Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: Image.file(thumbnail).image,
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    width: 1,
                    color: ExtraTheme.of(context).secondColor,
                  ),
                )),
            Positioned(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.8, 2, 4, 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 17,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        videoLength,
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: 4,
              left: 4,
            ),
          ],
        ));
  }
}
