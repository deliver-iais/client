import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class ReplyBrief extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();

  final String roomId;
  final int replyToId;
  final double maxWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final MessageBrief? messageReplyBrief;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  ReplyBrief({
    Key? key,
    required this.roomId,
    required this.replyToId,
    required this.maxWidth,
    required this.backgroundColor,
    required this.foregroundColor,
    this.messageReplyBrief,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: secondaryBorder,
      ),
      child: FutureBuilder<Message?>(
        future: _messageRepo.getMessage(roomId, replyToId),
        builder: (context, snapshot) {
          final future = extractMessageSimpleRepresentative(snapshot.data);

          if (future == null) {
            return const SizedBox.shrink();
          }

          return SenderAndContent(
            iconData: CupertinoIcons.reply,
            maxWidth: maxWidth,
            showBackgroundColor: true,
            messageSRF: future,
          );
        },
      ),
    );
  }

  Future<MessageSimpleRepresentative>? extractMessageSimpleRepresentative(
    Message? message,
  ) {
    Future<MessageSimpleRepresentative>? messageSRF;

    if (message != null) {
      messageSRF = _messageExtractorServices.extractMessageSimpleRepresentative(
        _messageExtractorServices.extractProtocolBufferMessage(message),
      );
    } else if (messageReplyBrief != null) {
      messageSRF = _messageExtractorServices
          .extractMessageSimpleRepresentativeFromMessageBrief(
        messageReplyBrief!,
      );
    }

    return messageSRF;
  }
}
