import 'package:deliver/box/media.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ForwardPreview extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();
  final List<Message>? forwardedMessages;
  final Function() onClick;
  final proto.ShareUid? shareUid;
  final List<Media>? forwardedMedia;

  ForwardPreview({
    Key? key,
    this.forwardedMessages,
    this.shareUid,
    required this.onClick,
    this.forwardedMedia,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface.withAlpha(200),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 3,
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.arrow_turn_up_right,
              color: theme.primaryColor,
              size: 25,
            ),
            const SizedBox(width: 10),
            if (shareUid != null)
              Text(shareUid!.name)
            else if (forwardedMedia != null && forwardedMedia!.isNotEmpty)
              Text('${forwardedMedia!.length} ${_i18n.get("forwarded_medias")}')
            else
              Text(
                '${forwardedMessages!.length} ${_i18n.get("forwarded_messages")}',
              ),
            const Spacer(),
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: const Icon(CupertinoIcons.xmark, size: 20),
              onPressed: onClick,
            ),
          ],
        ),
      ),
    );
  }
}
