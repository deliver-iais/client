import 'dart:io';

import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/fileRepo.dart';

import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';

// TODO(any): Use other features of flutter_staggered_grid_view
class MediaTabUi extends StatefulWidget {
  final int mediasCount;
  final int allDeletedMediasCount;
  final Uid roomUid;
  final void Function(Meta) addSelectedMeta;
  final List<Meta> selectedMedia;

  const MediaTabUi(
    this.mediasCount,
    this.roomUid, {
    super.key,
    required this.addSelectedMeta,
    required this.selectedMedia,
    required this.allDeletedMediasCount,
  });

  @override
  MediaTabUiState createState() => MediaTabUiState();
}

class MediaTabUiState extends State<MediaTabUi> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  final _metaCache = <int, Meta>{};

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 3,
      itemCount: widget.mediasCount,
      itemBuilder: (context, index) {
        return FutureBuilder<Meta?>(
          future: _metaRepo.getAndCacheMetaPage(
            widget.mediasCount - index,
            MetaType.MEDIA,
            widget.roomUid.asString(),
            _metaCache,
          ),
          builder: (c, mediaSnapShot) {
            if (mediaSnapShot.hasData) {
              if (mediaSnapShot.data!.isDeletedMeta()) {
                return const SizedBox.shrink();
              }
              return buildMediaWidget(
                mediaSnapShot.data!,
                widget.mediasCount - index,
              );
            } else {
              return Container(
                height: 200,
              );
            }
          },
        );
      },
    );
  }

  Container buildMediaWidget(Meta media, int index) {
    final file = media.json.toFile();
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          width: widget.selectedMedia.contains(media) ? 10 : 2,
        ),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _routingService.openShowAllImage(
              uid: widget.roomUid.asString(),
              messageId: media.messageId,
              initIndex: index,
              mediaCount: widget.mediasCount - widget.allDeletedMediasCount,
            ),
            onLongPress: () => _addSelectedMedia(media),
            child: file.isVideoFileProto()
                ? _buildThumbnailUi(file, isVideoFile: true)
                : FutureBuilder<String?>(
                    future: _fileRepo.getFileIfExist(file.uuid, file.name),
                    builder: (c, filePath) {
                      Widget c = const SizedBox.shrink();
                      if (filePath.hasData && filePath.data != null) {
                        c = _buildImageUi(file.uuid, filePath.data!);
                      } else {
                        c = _buildThumbnailUi(file);
                      }
                      return AnimatedSwitcher(
                        duration: AnimationSettings.verySlow,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: c,
                      );
                    },
                  ),
          ),
          if (widget.selectedMedia.isNotEmpty)
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () => widget.addSelectedMeta(media),
                icon: Container(
                  width: 28,
                  height: 28,
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
                      size: 28,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildThumbnailUi(file_pb.File file, {bool isVideoFile = false}) {
    return FutureBuilder<String?>(
      future: _fileRepo.getFile(
        file.uuid,
        file.name,
        thumbnailSize: isVideoFile ? ThumbnailSize.frame : ThumbnailSize.large,
        intiProgressbar: false,
      ),
      builder: (s, path) {
        Widget child = const SizedBox.shrink();
        if (path.hasData && path.data != null) {
          child = _buildImageUi(file.uuid, path.data!);
        } else {
          child = SizedBox(
            child: BlurHash(
              hash: (file.blurHash != "")
                  ? file.blurHash
                  : "L0Hewg%MM{%M?bfQfQfQM{fQfQfQ",
            ),
          );
        }
        return AnimatedSwitcher(
          duration: AnimationSettings.verySlow,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }

  Widget _buildImageUi(String uuid, String filePath) {
    return HeroMode(
      enabled: settings.showAnimations.value,
      child: Hero(
        tag: uuid,
        transitionOnUserGestures: true,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: isWeb
                  ? Image.network(filePath).image
                  : Image.file(
                      File(filePath),
                    ).image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _addSelectedMedia(Meta media) {
    widget.addSelectedMeta(media);
  }
}
