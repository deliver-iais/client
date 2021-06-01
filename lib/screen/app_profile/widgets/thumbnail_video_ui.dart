import 'dart:io';
import 'dart:ui';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get_it/get_it.dart';

class VideoThumbnail extends StatelessWidget {
  File thumbnail;
  int videoCount;
  String videoLength;
  bool isExist;
  Uid userUid;
  bool showPlayIcon;
  int mediaPosition;
  Function onClick;
  var _routingService = GetIt.I.get<RoutingService>();

  VideoThumbnail(
      {@required this.userUid,
      @required this.mediaPosition,
      @required this.videoLength,
      this.thumbnail,
      this.videoCount,
      this.onClick,
      this.showPlayIcon = false,
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
                        color: ExtraTheme.of(context).secondColor,
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
                      color: ExtraTheme.of(context).secondColor,
                    ),
                  )),
            if (showPlayIcon)
              Center(
                child: MaterialButton(
                  color: Colors.black26,
                  onPressed: () async {
                    onClick();
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
