import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/shared/methods/message.dart';
import 'package:deliver_flutter/shared/widgets/seen_status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class LastMessage extends StatelessWidget {
  final Message message;
  final int lastMessageId;
  final bool hasMentioned;
  final bool showSender;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  LastMessage(
      {Key key,
      this.message,
      this.lastMessageId,
      this.hasMentioned,
      this.showSender = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    I18N _i18n = I18N.of(context);

    var isReceivedMessage = !_authRepo.isCurrentUser(message.from);

    return FutureBuilder<MessageBrief>(
        future: extractMessageBrief(
            _i18n, _roomRepo, _authRepo, extractProtocolBufferMessage(message)),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          final mb = snapshot.data;
          return Row(
            children: [
              if (!isReceivedMessage && showSender)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SeenStatus(message),
                ),
              Expanded(
                child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    text: TextSpan(children: [
                      if (mb.senderIsAUserOrBot && showSender)
                        TextSpan(
                            text: "${mb.sender.trim()}: ",
                            style: TextStyle(
                                color: ExtraTheme.of(context).username,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      if (mb.typeDetails.isNotEmpty)
                        TextSpan(
                            text: "${mb.typeDetails}",
                            style: TextStyle(
                                color: ExtraTheme.of(context).username,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      if (mb.typeDetails.isNotEmpty && mb.text.isNotEmpty)
                        TextSpan(
                            text: ", ",
                            style: TextStyle(
                                color: ExtraTheme.of(context).username,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      if (mb.text.isNotEmpty)
                        TextSpan(
                            text: mb.text.split("\n").first,
                            style: TextStyle(
                                color: ExtraTheme.of(context)
                                    .chatOrContactItemDetails,
                                fontSize: 14)),
                    ])),
              ),
              if (hasMentioned)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle),
                  child: Icon(
                    Icons.alternate_email,
                    size: 15,
                  ),
                ),
              if (!_authRepo.isCurrentUser(message.from))
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: UnreadMessageCounterWidget(
                      message.roomUid, lastMessageId),
                )
            ],
          );
        });
  }
}
