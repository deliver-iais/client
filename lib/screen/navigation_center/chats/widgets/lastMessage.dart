import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LastMessage extends StatelessWidget {
  final Message message;
  final bool pinned;
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
      this.showSenderInSeparatedLine = false,
      this.pinned = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isReceivedMessage = !_authRepo.isCurrentUser(message.from);

    return FutureBuilder<MessageBrief>(
        future: extractMessageBrief(
            _i18n, _roomRepo, _authRepo, extractProtocolBufferMessage(message)),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                height: Theme.of(context).textTheme.bodyText2.fontSize + 7);
          final mb = snapshot.data;
          return Row(
            children: [
              if (showSeenStatus && !isReceivedMessage)
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
                            style:
                                Theme.of(context).primaryTextTheme.bodyText2),
                      if (mb.typeDetails.isNotEmpty)
                        TextSpan(
                            text: mb.typeDetails,
                            style:
                                Theme.of(context).primaryTextTheme.bodyText2),
                      if (mb.typeDetails.isNotEmpty && mb.text.isNotEmpty)
                        TextSpan(
                            text: ", ",
                            style:
                                Theme.of(context).primaryTextTheme.bodyText2),
                      if (mb.text.isNotEmpty)
                        TextSpan(
                            children: buildText(mb, context),
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
                ),
              if (pinned)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: Colors.transparent, shape: BoxShape.circle),
                  child: Icon(
                    Icons.push_pin,
                    size: 15,
                    color: ExtraTheme.of(context).fileSharingDetails,
                  ),
                ),
            ],
          );
        });
  }

  List<TextSpan> buildText(MessageBrief mb, BuildContext context) =>
      extractBlocks(
              mb.text
                  .split("\n")
                  .map((e) => e.trim())
                  .where((e) => e.trim().isNotEmpty)
                  .join(" "),
              context)
          .where((b) => b.text != null && b.text.isNotEmpty)
          .map((e) => TextSpan(text: e.text, style: e.style))
          .toList();

  List<Block> extractBlocks(String text, BuildContext context) {
    List<Block> blocks = [Block(text: text)];
    List<Parser> parsers = [
      EmojiParser(fontSize: 16),
      BoldTextParser(),
      ItalicTextParser()
    ];

    for (final p in parsers) {
      blocks = p.parse(blocks, context);
    }

    return blocks;
  }
}
