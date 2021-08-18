import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver_flutter/shared/methods/message.dart';
import 'package:deliver_flutter/shared/widgets/seen_status.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LastMessage extends StatelessWidget {
  final Message message;
  final int lastMessageId;
  final bool hasMentioned;
  final bool showSender;
  final bool showSenderInSeparatedLine;
  final bool showSeenStatus;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  LastMessage(
      {Key key,
      this.message,
      this.lastMessageId,
      this.hasMentioned = false,
      this.showSender = true,
      this.showSeenStatus = true,
      this.showSenderInSeparatedLine = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isReceivedMessage = !_authRepo.isCurrentUser(message.from);

    return FutureBuilder<MessageBrief>(
        future: extractMessageBrief(
            _i18n, _roomRepo, _authRepo, extractProtocolBufferMessage(message)),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container(height: Theme.of(context).textTheme.bodyText2.fontSize + 7);
          final mb = snapshot.data;
          return Row(
            children: [
              if (showSeenStatus && !isReceivedMessage && showSender)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SeenStatus(message),
                ),
              Expanded(
                child: RichText(
                    maxLines: showSenderInSeparatedLine && showSender ? 2 : 1,
                    overflow: TextOverflow.fade,
                    textDirection: TextDirection.ltr,
                    softWrap: false,
                    text: TextSpan(children: [
                      if (mb.senderIsAUserOrBot && showSender)
                        TextSpan(
                            text: "${mb.sender.trim()}" +
                                (showSenderInSeparatedLine ? "\n" : ": "),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    color: ExtraTheme.of(context).username)),
                      if (mb.typeDetails.isNotEmpty)
                        TextSpan(
                            text: mb.typeDetails,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    color: ExtraTheme.of(context).username)),
                      if (mb.typeDetails.isNotEmpty && mb.text.isNotEmpty)
                        TextSpan(
                            text: ", ",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    color: ExtraTheme.of(context).username)),
                      if (mb.text.isNotEmpty)
                        TextSpan(
                            text: buildText(mb),
                            style: Theme.of(context).textTheme.bodyText2),
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

  String buildText(MessageBrief mb) {
    return mb.text.split("\n").map((e) => e.trim()).where((e) => e.trim().isNotEmpty).join(" ");
    // return mb.text.split("\n").first;
  }
}
