import 'dart:convert';

import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/screen/room/messageWidgets/link_preview.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class LinkTabUi extends StatefulWidget {
  final int linksCount;
  final Uid roomUid;

  const LinkTabUi(this.linksCount, this.roomUid, {Key? key}) : super(key: key);

  @override
  _LinkTabUiState createState() => _LinkTabUiState();
}

class _LinkTabUiState extends State<LinkTabUi> {
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _mediaCache = <int, Media>{};

  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      int page = (index / MEDIA_PAGE_SIZE).floor();
      var res = await _mediaQueryRepo.getMediaPage(
          widget.roomUid.asString(), MediaType.LINK, page, index);
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
          return ListView.separated(
              itemCount: widget.linksCount,
              separatorBuilder: (c, i) {
                return const Divider();
              },
              itemBuilder: (c, index) {
                return FutureBuilder<Media?>(
                    future: _getMedia(index),
                    builder: (c, mediaSnapShot) {
                      if (mediaSnapShot.hasData && mediaSnapShot.data != null) {
                        return SizedBox(
                          child: LinkPreview(
                            link: jsonDecode(mediaSnapShot.data!.json)["url"],
                            maxWidth: 100,
                            isProfile: true,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    });
              });
        });
  }
}
