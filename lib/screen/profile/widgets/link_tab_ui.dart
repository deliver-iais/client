import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/screen/room/messageWidgets/link_preview.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// TODO(any): add ui design for every url in url list
class LinkTabUi extends StatefulWidget {
  final int linksCount;
  final Uid roomUid;

  const LinkTabUi(this.linksCount, this.roomUid, {super.key});

  @override
  LinkTabUiState createState() => LinkTabUiState();
}

class LinkTabUiState extends State<LinkTabUi> {
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final _metaCache = <int, Meta>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return ListView.separated(
      itemCount: widget.linksCount,
      separatorBuilder: (c, i) {
        return const Divider();
      },
      itemBuilder: (c, index) {
        return FutureBuilder<Meta?>(
          future: _metaRepo.getAndCacheMetaPage(
            widget.linksCount - index,
            MetaType.LINK,
            widget.roomUid.asString(),
            _metaCache,
          ),
          builder: (c, mediaSnapShot) {
            if (mediaSnapShot.hasData) {
              if (mediaSnapShot.data!.isDeletedMeta()) {
                return const SizedBox.shrink();
              }
              final urls = mediaSnapShot.data!.json.toLink().urls;
              return Column(
                children: [
                  LinkPreview(
                    link: urls.last,
                    foregroundColor: theme.primary,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _urlHandlerService.onUrlTap(
                              urls[index],
                            );
                          },
                          child: Text(
                            urls[index],
                            maxLines: 1,
                            style: TextStyle(color: theme.primary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                      itemCount: urls.length,
                      shrinkWrap: true,
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox(
                height: 100,
              );
            }
          },
        );
      },
    );
  }
}
