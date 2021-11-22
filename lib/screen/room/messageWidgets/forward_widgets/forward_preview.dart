import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/theme/extra_theme.dart';
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
    return Container(
      width: double.infinity,
      color: ExtraTheme.of(context).inputBoxBackground.withAlpha(100),
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
              color: Theme.of(context).primaryColor,
              size: 25,
            ),
            SizedBox(width: 10),
            shareUid != null
                ? Text(
                    shareUid!.name,
                    style: TextStyle(
                        color: ExtraTheme.of(context).textDetails,
                        fontSize: 20),
                  )
                : Text(
                    '${forwardedMessages!.length} ${_i18n.get("forwarded_messages")}'),
            Spacer(),
            IconButton(
              padding: EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: Icon(Icons.close, size: 18),
              onPressed: this.onClick,
            ),
          ],
        ),
      ),
    );
  }
}
