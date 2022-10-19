import 'dart:convert';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/download_video_widget.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_filex/open_filex.dart';


class VideoTabUi extends StatefulWidget {
  final Uid roomUid;
  final int videoCount;
  final void Function(Media) addSelectedMedia;
  final List<Media> selectedMedia;

  const VideoTabUi({
    super.key,
    required this.roomUid,
    required this.videoCount,
    required this.addSelectedMedia,
    required this.selectedMedia,
  });

  @override
  VideoTabUiState createState() => VideoTabUiState();
}

class VideoTabUiState extends State<VideoTabUi> {
  final _fileServices = GetIt.I.get<FileService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _mediaCache = <int, Media>{};

  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      final page = (index / MEDIA_PAGE_SIZE).floor();
      final res = await _mediaQueryRepo.getMediaPage(
        widget.roomUid.asString(),
        MediaType.VIDEO,
        page,
        index,
      );
      if (res != null) {
        for (final media in res) {
          _mediaCache[media.messageId] = media;
        }
      }
      return _mediaCache.values.toList()[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  return GestureDetector(
                    child: buildMediaWidget(
                      mediaSnapShot.data!,
                      index,
                      theme,
                    ),
                    onLongPress: () =>
                        widget.addSelectedMedia(mediaSnapShot.data!),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        );
      },
    );
  }

  Container buildMediaWidget(Media media, int index, ThemeData theme) {
    final json = jsonDecode(media.json) as Map;

    final duration = double.parse(json["duration"].toString());
    final dur = Duration(seconds: duration.ceil());
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: widget.selectedMedia.isNotEmpty ? 3 : 6,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      child: Stack(
        children: [
          FutureBuilder<String?>(
            future: _fileRepo.getFileIfExist(json["uuid"], json["name"]),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return GestureDetector(
                  onTap: () {
                    if (isDesktop) {
                      OpenFilex.open(snapshot.data??"");
                    } else {
                      _routingService.openShowAllVideos(
                        uid: widget.roomUid,
                        initIndex: index,
                        videosLength: widget.videoCount,
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: theme.colorScheme.primary,
                          size: 55,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(dur.toString().substring(0, 7)),
                      )
                    ],
                  ),
                );
              } else {
                _fileServices.initProgressBar(json["uuid"]);
                return downloadVideo(media, theme);
              }
            },
          ),
          if (widget.selectedMedia.isNotEmpty)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => widget.addSelectedMedia(media),
                  icon: Container(
                    color: Theme.of(context).hoverColor,
                    child: Icon(
                      widget.selectedMedia.contains(media)
                          ? Icons.check_circle_outline
                          : Icons.panorama_fish_eye,
                      color: Theme.of(context).primaryColor,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget downloadVideo(Media media, ThemeData theme) {
    final json = jsonDecode(media.json) as Map;
    return DownloadVideoWidget(
      name: json["name"],
      uuid: json["uuid"],
      download: () async {
        await _fileRepo.getFile(json["uuid"], json["name"]);
        setState(() {});
      },
      background: theme.colorScheme.onPrimary,
      foreground: theme.colorScheme.primary,
    );
  }
}
