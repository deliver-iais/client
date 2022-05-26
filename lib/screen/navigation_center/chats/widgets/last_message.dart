import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LastMessage extends StatelessWidget {
  final Message message;
  final bool pinned;
  final int lastMessageId;
  final bool hasMentioned;
  final bool showSender;
  final bool showSeenStatus;
  final bool expandContent;
  final bool showRoomDetails;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  LastMessage({
    Key? key,
    required this.message,
    required this.lastMessageId,
    this.hasMentioned = false,
    this.showSender = false,
    this.showSeenStatus = true,
    this.expandContent = true,
    this.showRoomDetails = true,
    this.pinned = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReceivedMessage = !_authRepo.isCurrentUser(message.from);

    return FutureBuilder<MessageBrief>(
      future: extractMessageBrief(
        _i18n,
        _roomRepo,
        _authRepo,
        extractProtocolBufferMessage(message),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(height: theme.textTheme.bodyText2!.fontSize! + 7);
        }
        final mb = snapshot.data;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mb!.senderIsAUserOrBot && showSender)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mb.sender.trim(),
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.rtl,
                      overflow: TextOverflow.ellipsis,
                      style: theme.primaryTextTheme.caption,
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showSeenStatus && !isReceivedMessage)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: SeenStatus(message),
                  ),
                Flexible(
                  fit: expandContent ? FlexFit.tight : FlexFit.loose,
                  child: RichText(
                    maxLines: showSender ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.rtl,
                    softWrap: false,
                    text: TextSpan(
                      children: [
                        if (mb.typeDetails.isNotEmpty)
                          TextSpan(
                            text: mb.typeDetails,
                            style: theme.primaryTextTheme.caption,
                          ),
                        if (mb.typeDetails.isNotEmpty && mb.text.isNotEmpty)
                          TextSpan(
                            text: ", ",
                            style: theme.primaryTextTheme.caption,
                          ),
                        if (mb.text.isNotEmpty)
                          TextSpan(
                            children: buildText(mb, context),
                            style: theme.textTheme.caption?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (showRoomDetails && hasMentioned)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.at,
                      size: 15,
                    ),
                  ),
                if (showRoomDetails && !_authRepo.isCurrentUser(message.from))
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: UnreadMessageCounterWidget(
                      message.roomUid,
                      lastMessageId,
                    ),
                  ),
                if (showRoomDetails && pinned)
                  Icon(
                    CupertinoIcons.pin,
                    size: 16,
                    color: theme.colorScheme.onSurface.withAlpha(120),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<TextSpan> buildText(MessageBrief mb, BuildContext context) =>
      extractBlocks(
        mb.text
            .split("\n")
            .map((e) => e.trim())
            .where((e) => e.trim().isNotEmpty)
            .join(" "),
        context,
      )
          .where((b) => b.text.isNotEmpty)
          .map((e) => TextSpan(text: e.text, style: e.style))
          .toList();

  List<Block> extractBlocks(String text, BuildContext context) {
    var blocks = <Block>[Block(text: text)];
    final parsers = <Parser>[
      EmojiParser(fontSize: 16),
      BoldTextParser(),
      ItalicTextParser(),
      UnderlineTextParser(),
      StrikethroughTextParser(),
      InlineIdParser(),
      InlineUrlTextParser(),
    ];

    for (final p in parsers) {
      blocks = p.parse(blocks, context);
    }

    return blocks;
  }
}
