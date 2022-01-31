import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ForwardPreview extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();
  final List<Message>? forwardedMessages;
  final Function() onClick;
  final proto.ShareUid? shareUid;

  ForwardPreview(
      {Key? key, this.forwardedMessages, this.shareUid, required this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color:theme.colorScheme.surface.withAlpha(200),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward,
              color:theme.primaryColor,
              size: 25,
            ),
            const SizedBox(width: 10),
            shareUid != null
                ? Text(shareUid!.name)
                : Text(
                    '${forwardedMessages!.length} ${_i18n.get("forwarded_messages")}'),
            const Spacer(),
            IconButton(
              padding: const EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClick,
            ),
          ],
        ),
      ),
    );
  }
}
