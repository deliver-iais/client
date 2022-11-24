import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AsyncLastMessage extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();

  final Future<MessageSimpleRepresentative> messageSRF;
  final bool showSender;
  final bool showSeenStatus;
  final bool expandContent;
  final Color? highlightColor;
  final int? maxLine;

  AsyncLastMessage({
    super.key,
    required Message message,
    this.showSender = false,
    this.showSeenStatus = true,
    this.expandContent = true,
    this.highlightColor,
    this.maxLine,
  }) : messageSRF =
            _messageExtractorServices.extractMessageSimpleRepresentative(
          _messageExtractorServices.extractProtocolBufferMessage(message),
        );

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
          showSender: showSender,
          showSeenStatus: showSeenStatus,
          expandContent: expandContent,
          highlightColor: highlightColor,
          maxLine: maxLine,
        );
      },
    );
  }
}

class LastMessage extends StatelessWidget {
  static final _authRepo = GetIt.I.get<AuthRepo>();

  final MessageSimpleRepresentative messageSR;

  final bool showSender;
  final int? maxLine;
  final bool showSeenStatus;
  final bool expandContent;
  final Color? highlightColor;

  const LastMessage({
    super.key,
    required this.messageSR,
    this.showSender = false,
    this.showSeenStatus = true,
    this.expandContent = true,
    this.highlightColor,
    this.maxLine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mb = messageSR;
    final isReceivedMessage = !_authRepo.isCurrentUser(mb.from.asString());

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: maxLine ?? (showSender ? 1 : 2),
                textAlign: TextAlign.end,
                textDirection: TextDirection.rtl,
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
          ],
        ),
      ],
    );
  }

  List<InlineSpan> buildText(
    MessageSimpleRepresentative mb,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return onePath(
      [
        Block(
          text: mb.text
              .split("\n")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .join(" "),
          features: {},
        )
      ],
      detectorsWithSearchTermDetector(),
      simpleInlineSpanTransformer(
        defaultColor: theme.colorScheme.primary,
        linkColor: theme.colorScheme.primary,
      ),
    );
  }
}
