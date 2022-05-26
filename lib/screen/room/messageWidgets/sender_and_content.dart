import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SenderAndContent extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();

  final Future<MessageSimpleRepresentative> messageSRF;
  final bool expandContent;
  final Color? highlightColor;

  SenderAndContent.viaMessage({
    Key? key,
    required Message message,
    this.expandContent = true,
    this.highlightColor,
  })  : messageSRF =
            _messageExtractorServices.extractMessageSimpleRepresentative(
          _messageExtractorServices.extractProtocolBufferMessage(message),
        ),
        super(key: key);

  SenderAndContent.viaMessageBrief({
    Key? key,
    required MessageBrief messageBrief,
    this.expandContent = true,
    this.highlightColor,
  })  : messageSRF = _messageExtractorServices
            .extractMessageSimpleRepresentativeFromMessageBrief(
          messageBrief,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LastMessage(
      messageSRF: messageSRF,
      showSender: true,
      showSeenStatus: false,
      showRoomDetails: false,
      lastMessageId: 0,
      highlightColor: highlightColor,
      expandContent: expandContent,
    );
  }
}
