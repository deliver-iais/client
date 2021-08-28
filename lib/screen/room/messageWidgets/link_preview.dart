import 'package:dcache/dcache.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';

const APARAT = "https://www.aparat.com";

class LinkPreview extends StatelessWidget {
  static final Cache<String, Metadata> cache =
      LruCache<String, Metadata>(storage: InMemoryStorage(100));
  final String link;
  final double maxWidth;
  final double maxHeight;

  const LinkPreview({Key key, this.link, this.maxWidth, this.maxHeight = double.infinity}) : super(key: key);

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

    Metadata m;
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
    if (link == null || link.isEmpty) return SizedBox.shrink();
    return FutureBuilder<Metadata>(
        future: _fetchMetadata(link),
        builder: (context, snapshot) {
          if ((!snapshot.hasData || snapshot.data == null) ||
              ((snapshot.data?.description == null) &&
                  (snapshot.data?.description == null)))
            return SizedBox.shrink();

          return Container(
              margin: const EdgeInsets.only(top: 10),
              constraints:
                  BoxConstraints(minWidth: maxWidth, maxWidth: maxWidth, maxHeight: maxHeight),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(45),
                  border: Border(
                      left: BorderSide(
                          width: 3, color: Theme.of(context).primaryColor))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Theme.of(context).primaryColor.withAlpha(30),
                    child: TextButton.icon(
                      icon: Icon(Icons.chevron_left_rounded),
                      label: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              snapshot.data.title,
                              textDirection: snapshot.data.title.isPersian()
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w700),
                            ),
                          )),
                      onPressed: () => launch(link),
                    ),
                  ),
                  Divider(),
                  if (snapshot.data?.description != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        snapshot.data.description,
                        textDirection: snapshot.data.description.isPersian()
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),

                ],
              ));
        });
  }
}
