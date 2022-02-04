import 'dart:math';

import 'package:dcache/dcache.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: constant_identifier_names
const APARAT = "https://www.aparat.com";

class LinkPreview extends StatelessWidget {
  static final Cache<String, Metadata> cache =
      LruCache<String, Metadata>(storage: InMemoryStorage(100));
  final String link;
  final double maxWidth;
  final double maxHeight;
  final bool isProfile;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const LinkPreview(
      {Key? key,
      required this.link,
      required this.maxWidth,
      this.backgroundColor,
      this.foregroundColor,
      this.maxHeight = 100,
      this.isProfile = false})
      : super(key: key);

  Future<Metadata> _fetchFromHTML(String url) async {
    // Makes a call
    var response = await http.get(Uri.parse(url));

    // Covert Response to a Document. The utility function `responseToDocument` is provided or you can use own decoder/parser.
    var document = MetadataFetch.responseToDocument(response);

    // Get Html metadata
    return MetadataParser.twitterCard(document);
  }

  Future<Metadata> _fetchMetadata(String url) async {
    final metadata = cache.get(url);

    if (metadata != null) {
      return metadata;
    }

    final uri = Uri.parse(url);

    Metadata? m;
    switch (uri.origin) {
      case APARAT:
        m = await _fetchFromHTML(url);
        break;
      default:
        m = await MetadataFetch.extract(link);
    }

    cache.set(url, m ?? Metadata());

    return m ?? Metadata();
  }

  @override
  Widget build(BuildContext context) {
    if (link.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<Metadata?>(
        future: _fetchMetadata(link),
        builder: (context, snapshot) {
          if ((!snapshot.hasData || snapshot.data == null) ||
              ((snapshot.data?.description == null) &&
                  (snapshot.data?.description == null))) {
            return const SizedBox.shrink();
          }

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () async {
                  await launch(link);
                },
                child: linkPreviewContent(snapshot.data, context)),
          );
        });
  }

  Widget linkPreviewContent(Metadata? data, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        constraints: BoxConstraints(
            minWidth: 300, maxWidth: max(300, maxWidth), maxHeight: maxHeight),
        decoration: BoxDecoration(
            borderRadius: secondaryBorder, color: backgroundColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Text(
                data!.title!,
                textDirection: data.title!.isPersian()
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.primaryTextTheme.bodyText2
                    ?.copyWith(color: foregroundColor),
              ),
            ),
            if (data.description != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Text(
                    data.description!,
                    textDirection: data.description!.isPersian()
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: theme.textTheme.bodyText2,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
          ],
        ));
  }
}
