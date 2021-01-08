import 'dart:io';
import 'dart:ui';

import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class VideoThumbnail extends StatelessWidget{
  File thumbnail;
  String videoLength;
  bool isExist;
  VideoThumbnail(this.thumbnail,this.videoLength,this.isExist);
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      // onTap: () {
      //   _routingService.openShowAllMedia(
      //     uid: userUid,
      //     hasPermissionToDeletePic: true,
      //     mediaPosition: position,
      //     heroTag: "btn$position",
      //     mediasLength: imagesCount,
      //   );
      // },
        child: Stack(
          children: [
            //VideoUi(video:snaps.data),
            Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: Image.file(
                        thumbnail
                    ).image,
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    width: 1,
                    color: ExtraTheme.of(context).secondColor,
                  ),
                )),
            isExist==false?
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 3,
                sigmaY: 3
              ),
              child: Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.8,2 , 4, 2),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow,size: 17,),
                        SizedBox(width: 3,),
                        Text(videoLength,style: TextStyle(fontSize: 10),),
                      ],
                    ),
                  ),
                ),
                bottom: 4,
                left: 4,
              ),
            ):
            Positioned(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.8,2 , 4, 2),
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow,size: 17,),
                      SizedBox(width: 3,),
                      Text(videoLength,style: TextStyle(fontSize: 10),),
                    ],
                  ),
                ),
              ),
              bottom: 4,
              left: 4,
            ),
          ],
        )
    );

  }

}