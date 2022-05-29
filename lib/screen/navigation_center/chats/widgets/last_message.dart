import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AsyncLastMessage extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();

  final Future<MessageSimpleRepresentative> messageSRF;
  final bool pinned;
  final int lastMessageId;
  final bool hasMentioned;
  final bool showSender;
  final bool showSeenStatus;
  final bool expandContent;
  final bool showRoomDetails;
  final Color? highlightColor;

  AsyncLastMessage({
    Key? key,
    required Message message,
    required this.lastMessageId,
    this.hasMentioned = false,
    this.showSender = false,
    this.showSeenStatus = true,
    this.expandContent = true,
    this.showRoomDetails = true,
    this.pinned = false,
    this.highlightColor,
  })  : messageSRF =
            _messageExtractorServices.extractMessageSimpleRepresentative(
          _messageExtractorServices.extractProtocolBufferMessage(message),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<MessageSimpleRepresentative>(
      future: messageSRF,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(height: theme.textTheme.bodyText2!.fontSize! + 7);
        }

        return LastMessage(
          key: key,
          messageSR: snapshot.data!,
          lastMessageId: lastMessageId,
          hasMentioned: hasMentioned,
          showSender: showSender,
          showSeenStatus: showSeenStatus,
          expandContent: expandContent,
          showRoomDetails: showRoomDetails,
          pinned: pinned,
          highlightColor: highlightColor,
        );
      },
    );
  }
}

class LastMessage extends StatelessWidget {
  static final _authRepo = GetIt.I.get<AuthRepo>();

  final MessageSimpleRepresentative messageSR;
  final bool pinned;
  final int lastMessageId;
  final bool hasMentioned;
  final bool showSender;
  final bool showSeenStatus;
  final bool expandContent;
  final bool showRoomDetails;
  final Color? highlightColor;

  const LastMessage({
    Key? key,
    required this.messageSR,
    required this.lastMessageId,
    this.hasMentioned = false,
    this.showSender = false,
    this.showSeenStatus = true,
    this.expandContent = true,
    this.showRoomDetails = true,
    this.pinned = false,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mb = messageSR;
    final isReceivedMessage = !_authRepo.isCurrentUser(mb.sender);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mb.senderIsAUserOrBot && showSender)
          Row(
            children: [
              Expanded(
                child: Text(
                  mb.sender.trim(),
                  textAlign: TextAlign.end,
                  textDirection: TextDirection.rtl,
                  overflow: TextOverflow.ellipsis,
                  style: theme.primaryTextTheme.caption?.copyWith(
                    color: highlightColor,
                  ),
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
                child: SeenStatus(
                  mb.roomUid.asString(),
                  mb.packetId,
                  messageId: mb.id,
                ),
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
                        style: theme.textTheme.caption
                            ?.copyWith(color: highlightColor),
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
            if (showRoomDetails && isReceivedMessage)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: UnreadMessageCounterWidget(
                  mb.roomUid.asString(),
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
  }

  List<TextSpan> buildText(
    MessageSimpleRepresentative mb,
    BuildContext context,
  ) =>
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
      ItalicTextParser()
    ];

    for (final p in parsers) {
      blocks = p.parse(blocks, context);
    }

    return blocks;
  }
}
