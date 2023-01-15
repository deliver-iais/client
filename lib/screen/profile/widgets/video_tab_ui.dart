import 'dart:io' as io;

import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/download_video_widget.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/format_duration.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
    final file = media.json.toFile();

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
            future: _fileRepo.getFileIfExist(file.uuid, file.name),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return InkWell(
                  onTap: () {
                    _routingService.openShowAllVideos(
                      roomUid: widget.roomUid.asString(),
                      initIndex: index,
                      messageId: media.messageId,
                    );
                  },
                  child: Hero(
                    tag: file.uuid,
                    child: Stack(
                      children: [
                        FutureBuilder<String?>(
                          future: _fileRepo.getFile(
                            file.uuid,
                            // TODO(fix-this): it should change to webp
                            file.name,
                            thumbnailSize: ThumbnailSize.large,
                            intiProgressbar: false,
                          ),
                          builder: (c, path) {
                            if (path.hasData && path.data != null) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  image: DecorationImage(
                                    image:
                                        Image.file(io.File(path.data!)).image,
                                    fit: BoxFit.cover,
                                  ),
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                // child: Image.file(File(path.data!),width: 400,),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: theme.colorScheme.primary,
                            size: 55,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            formatDuration(
                              Duration(
                                seconds: double.parse(file.duration.toString())
                                    .round(),
                              ),
                            ),
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontSize: 10,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
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
    return DownloadVideoWidget(
      file: media.json.toFile(),
      maxWidth: 100,
      colorScheme: ExtraTheme.of(context).primaryColorsScheme,
      onDownloadCompleted: (_) => setState(() {}),
      background: theme.colorScheme.onPrimary,
      foreground: theme.colorScheme.primary,
    );
  }
}
