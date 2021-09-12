import 'package:we/localization/i18n.dart';
import 'package:we/box/message.dart';
import 'package:we/repository/authRepo.dart';
import 'package:we/repository/roomRepo.dart';
import 'package:we/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:we/shared/extensions/uid_extension.dart';
import 'package:we/shared/extensions/json_extension.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  PersistentEventMessage({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PersistentEvent persistentEventMessage = message.json.toPersistentEvent();
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding:
          const EdgeInsets.only(top: 5, left: 8.0, right: 8.0, bottom: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
                  style: TextStyle(fontSize: 14, height: 1),
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
