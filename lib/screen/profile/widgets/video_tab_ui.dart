import 'dart:convert';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/screen/profile/widgets/thumbnail_video_ui.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class VideoTabUi extends StatefulWidget {
  final Uid roomUid;
  final int videoCount;

  const VideoTabUi({Key? key, required this.roomUid, required this.videoCount})
      : super(key: key);

  @override
  _VideoTabUiState createState() => _VideoTabUiState();
}

class _VideoTabUiState extends State<VideoTabUi> {
  final mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final fileRepo = GetIt.I.get<FileRepo>();


  // @override
  // Widget build(BuildContext context) {
  //   var extraThemeData = ExtraTheme.of(context);
  //   return FutureBuilder<List<Media>>(
  //       future: mediaQueryRepo.getMedia(
  //           widget.roomUid, MediaType.VIDEO, widget.videoCount),
  //       builder: (BuildContext c, snaps) {
  //         if (!snaps.hasData ||
  //             snaps.data == null ||
  //             snaps.connectionState == ConnectionState.waiting) {
  //           return const SizedBox(width: 0.0, height: 0.0);
  //         } else {
  //           return GridView.builder(
  //               shrinkWrap: true,
  //               padding: EdgeInsets.zero,
  //               itemCount: snaps.data!.length,
  //               scrollDirection: Axis.vertical,
  //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: 3),
  //               itemBuilder: (context, position) {
  //                 var fileId = jsonDecode(snaps.data![position].json)["uuid"];
  //                 var fileName = jsonDecode(snaps.data![position].json)["name"];
  //                 var videoDuration =
  //                     jsonDecode(snaps.data![position].json)["duration"];
  //                 duration = Duration(seconds: videoDuration.round());
  //                 if (duration.inHours == 0) {
  //                   videoLength = duration.inMinutes > 9
  //                       ? duration.toString().substring(2, 7)
  //                       : duration.toString().substring(3, 7);
  //                   totalDuration[position] = videoLength;
  //                 } else {
  //                   videoLength =
  //                       duration.toString().split('.').first.padLeft(8, "0");
  //                   totalDuration[position] = videoLength;
  //                 }
  //
  //                 return FutureBuilder<String?>(
  //                     future: fileRepo.getFileIfExist(fileId, fileName),
  //                     builder: (BuildContext c, isExit) {
  //                       if (isExit.hasData &&
  //                           isExit.connectionState == ConnectionState.done) {
  //                         return VideoWidget(
  //                           userUid: widget.roomUid,
  //                           thumbnail: isExit.data!,
  //                           videoCount: widget.videoCount,
  //                           isExist: isExit.data != null,
  //                           mediaPosition: position,
  //                           videoLength: totalDuration[position]!,
  //                         );
  //                       } else {
  //                         return LoadFileStatus(
  //                           fileId: fileId,
  //                           fileName: fileName,
  //                           onPressed: (fId, fName) async {
  //                             await fileRepo.getFile(fileId, fileName);
  //                             setState(() {});
  //                           },
  //                           background:
  //                               extraThemeData.colorScheme.primaryContainer,
  //                           foreground:
  //                               extraThemeData.colorScheme.onPrimaryContainer,
  //                         );
  //                       }
  //                     });
  //               });
  //         }
  //       });
  // }

  final _routingService = GetIt.I.get<RoutingService>();
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _mediaCache = <int, Media>{};

  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      int page = (index / MEDIA_PAGE_SIZE).floor();
      var res = await _mediaQueryRepo.getMediaPage(
          widget.roomUid.asString(), MediaType.VIDEO, page, index);
      if (res != null) {
        for (Media media in res) {
          _mediaCache[media.messageId] = media;
        }
      }
      return _mediaCache.values.toList()[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaMetaData?>(
        stream: _mediaQueryRepo.getMediasMetaDataCountFromDB(widget.roomUid),
        builder: (context, snapshot) {
          _mediaCache.clear();
          return GridView.builder(
              itemCount: widget.videoCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (c, index) {
                return FutureBuilder<Media?>(
                  future: _getMedia(index),
                  builder: (c, mediaSnapShot) {
                    if (mediaSnapShot.hasData && mediaSnapShot.data != null) {
                      return buildMediaWidget(mediaSnapShot.data!, index);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              });
        });
  }

  Container buildMediaWidget(Media media, int index) {
    double duration =
        double.parse(jsonDecode(media.json)["duration"].toString());
    var dur = Duration(seconds: duration.ceil());
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _routingService.openShowAllVideos(
              uid: widget.roomUid, initIndex: index, videosLength: widget.videoCount);
        },
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.blue,size: 55,
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter, child: Text(dur.toString().substring(0,7)))
          ],
        ),
      ),
    );
  }
}
