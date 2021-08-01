import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/shared/methods/message.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;
  final bool showLastMessage;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  PersistentEventMessage({Key key, this.message, this.showLastMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PersistentEvent persistentEventMessage = message.json.toPersistentEvent();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: showLastMessage
            ? ExtraTheme.of(context).persistentEventMessage
            : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: FutureBuilder<String>(
        future: getPersistentMessage(context, persistentEventMessage),
        builder: (c, s) {
          if (s.hasData) {
            return Directionality(
                textDirection:
                    _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  s.data,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                      color: showLastMessage
                          ? ExtraTheme.of(context).textMessage
                          : Colors.white,
                      fontSize: 14),
                ));
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Future<String> getPersistentMessage(
      BuildContext context, PersistentEvent persistentEventMessage) async {
    return getPersistentEventText(_i18n, _roomRepo, _authRepo,
        persistentEventMessage, message.to.asUid().isChannel());
  }
}
