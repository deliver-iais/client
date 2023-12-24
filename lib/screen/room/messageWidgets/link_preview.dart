import 'dart:math';

import 'package:deliver/repository/caching_repo.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher.dart';

const APARAT = "https://www.aparat.com";

class LinkPreview extends StatelessWidget {
  final String link;
  final double? maxWidth;
  final double maxHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;

  final _cacheRepo = GetIt.I.get<CachingRepo>();

  LinkPreview({
    super.key,
    required this.link,
    this.maxWidth,
    this.backgroundColor,
    this.foregroundColor,
    this.maxHeight = 120,
  });

  Future<Metadata> _fetchFromHTML(String url) async {
    // Makes a call
    final response = await http.get(Uri.parse(url));

    // Covert Response to a Document. The utility function `responseToDocument` is provided or you can use own decoder/parser.
    final document = MetadataFetch.responseToDocument(response);

    // Get Html metadata
    return MetadataParser.twitterCard(document);
  }

  Future<Metadata> _fetchMetadata(String url) async {
    final metadata = _cacheRepo.getUrl(url);

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

    _cacheRepo.setUrl(url, m ?? Metadata());

    return m ?? Metadata();
  }

  @override
  Widget build(BuildContext context) {
    if (link.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<Metadata?>(
      initialData: _cacheRepo.getUrl(link),
      future: _fetchMetadata(link),
      builder: (context, snapshot) {
        final show = (!snapshot.hasData || snapshot.data?.description == null);

        Widget widget;

        if (show) {
          widget = const SizedBox.shrink();
        } else {
          widget = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                await launchUrl(Uri.parse(link));
              },
              child: linkPreviewContent(snapshot.data, context),
            ),
          );
        }

        return AnimatedOpacity(
          duration: AnimationSettings.standard,
          opacity: show ? 0 : 1,
          curve: Curves.easeInOut,
          child: AnimatedSize(
            duration: AnimationSettings.standard,
            alignment: Alignment.topRight,
            curve: Curves.easeInOut,
            child: widget,
          ),
        );
      },
    );
  }

  Widget linkPreviewContent(Metadata? data, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 6),
      padding: const EdgeInsets.all(4.0),
      constraints: BoxConstraints(
        maxWidth: getWidth(),
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        borderRadius: secondaryBorder,
        color: backgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 8.0,
              vertical: 2.0,
            ),
            child: Text(
              data!.title!,
              textDirection: data.title!.isPersian()
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: theme.primaryTextTheme.bodyMedium
                  ?.copyWith(color: foregroundColor),
            ),
          ),
          if (data.description != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 8.0,
                  vertical: 2.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    data.description!,
                    textDirection: data.description!.isPersian()
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double getWidth() => maxWidth != null ? max(maxWidth!, 150) : double.infinity;
}
