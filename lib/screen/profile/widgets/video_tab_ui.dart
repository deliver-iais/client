import 'dart:convert';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/download_video_widget.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
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
  final _fileServices = GetIt.I.get<FileService>();
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
                crossAxisCount: 3,
              ),
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
      child: FutureBuilder<String?>(
          future: _fileRepo.getFileIfExist(
              jsonDecode(media.json)["uuid"], jsonDecode(media.json)["name"]),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return GestureDetector(
                onTap: () {
                  _routingService.openShowAllVideos(
                      uid: widget.roomUid,
                      initIndex: index,
                      videosLength: widget.videoCount);
                },
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.blue,
                        size: 55,
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(dur.toString().substring(0, 7)))
                  ],
                ),
              );
            } else {
              _fileServices.initProgressBar(jsonDecode(media.json)["uuid"]);
              return downloadVideo(media);
            }
          }),
    );
  }

  Widget downloadVideo(Media media) {
    return DownloadVideoWidget(
      name: jsonDecode(media.json)["name"],
      uuid: jsonDecode(media.json)["uuid"],
      download: () async {
        await _fileRepo.getFile(
            jsonDecode(media.json)["uuid"], jsonDecode(media.json)["name"]);
        setState(() {});
      },
      background: Colors.blue,
      foreground: Colors.amber,
    );
  }
}
