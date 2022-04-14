import 'dart:convert';
import 'dart:io';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';

class ImageTabUi extends StatefulWidget {
  final int imagesCount;
  final Uid roomUid;
  final void Function(Media) addSelectedMedia;
  final List<Media> selectedMedia;
  final void Function(Message) onEdit;

  const ImageTabUi(
    this.imagesCount,
    this.roomUid, {
    Key? key,
    required this.addSelectedMedia,
    required this.selectedMedia,
    required this.onEdit,
  }) : super(key: key);

  @override
  _ImageTabUiState createState() => _ImageTabUiState();
}

class _ImageTabUiState extends State<ImageTabUi> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageDao = GetIt.I.get<MessageDao>();
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
        MediaType.IMAGE,
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
    return StreamBuilder<MediaMetaData?>(
      stream: _mediaQueryRepo.getMediasMetaDataCountFromDB(widget.roomUid),
      builder: (context, snapshot) {
        _mediaCache.clear();
        return GridView.builder(
          itemCount: widget.imagesCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (c, index) {
            return FutureBuilder<Media?>(
              future: _getMedia(index),
              builder: (c, mediaSnapShot) {
                if (mediaSnapShot.hasData) {
                  return buildMediaWidget(mediaSnapShot.data!, index);
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

  Container buildMediaWidget(Media media, int index) {
    final json = jsonDecode(media.json) as Map;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: widget.selectedMedia.isEmpty ? 2 : 6,
        ),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () async {
              final message = await _messageDao.getMessage(
                widget.roomUid.asString(),
                media.messageId,
              );
              _routingService.openShowAllImage(
                uid: widget.roomUid.asString(),
                messageId: media.messageId,
                initIndex: index,
                onEdit: () => widget.onEdit(message!),
              );
            },
            onLongPress: () => _addSelectedMedia(media),
            child: FutureBuilder<String?>(
              future: _fileRepo.getFileIfExist(json["uuid"], json["name"]),
              builder: (c, filePath) {
                if (filePath.hasData && filePath.data != null) {
                  return Hero(
                    tag: json["uuid"],
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: isWeb
                              ? Image.network(filePath.data!).image
                              : Image.file(
                                  File(filePath.data!),
                                ).image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    transitionOnUserGestures: true,
                  );
                } else {
                  return SizedBox(child: BlurHash(hash: json["blurHash"]));
                }
              },
            ),
          ),
          if (widget.selectedMedia.isNotEmpty)
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () => widget.addSelectedMedia(media),
                icon: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Theme.of(context).hoverColor.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Icon(
                      widget.selectedMedia.contains(media)
                          ? Icons.check_circle_outline
                          : Icons.panorama_fish_eye,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  void _addSelectedMedia(Media media) {
    widget.addSelectedMedia(media);
  }
}
