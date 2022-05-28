import 'package:deliver/box/message.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SenderAndContent extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();

  final Future<MessageSimpleRepresentative> messageSRF;
  final bool expandContent;
  final Color? highlightColor;

  const SenderAndContent({
    Key? key,
    required this.messageSRF,
    this.expandContent = true,
    this.highlightColor,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraTheme = ExtraTheme.of(context);

    return FutureBuilder<MessageSimpleRepresentative>(
      future: messageSRF,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(height: theme.textTheme.bodyText2!.fontSize! + 7);
        }

        final messageColorScheme =
            extraTheme.messageColorScheme(snapshot.data!.from.asString());

        return Row(
          children: [
            Icon(
              CupertinoIcons.reply,
              size: 20,
              color: messageColorScheme.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: LastMessage(
                messageSR: snapshot.data!,
                showSender: true,
                showSeenStatus: false,
                showRoomDetails: false,
                lastMessageId: 0,
                highlightColor: messageColorScheme.primary,
                expandContent: expandContent,
              ),
            ),
          ],
        );
      },
    );
  }
}
