import 'package:deliver/box/message.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SenderAndContent extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();

  final Future<MessageSimpleRepresentative> messageSRF;
  final bool expandContent;
  final bool showBackgroundColor;
  final double? maxWidth;
  final IconData? iconData;
  final Color? highlightColor;

  const SenderAndContent({
    Key? key,
    required this.messageSRF,
    this.maxWidth,
    this.iconData,
    this.expandContent = true,
    this.showBackgroundColor = false,
    this.highlightColor,
  }) : super(key: key);

  SenderAndContent.viaMessage({
    Key? key,
    required Message message,
    this.maxWidth,
    this.iconData,
    this.expandContent = true,
    this.showBackgroundColor = false,
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

        return Container(
          constraints: maxWidth != null
              ? BoxConstraints(maxWidth: maxWidth! - 14.0)
              : null,
          decoration: showBackgroundColor
              ? BoxDecoration(
                  borderRadius: secondaryBorder,
                  color: messageColorScheme.primaryContainer.withOpacity(0.2),
                  border: Border.all(
                    color: messageColorScheme.primary,
                    width: 2,
                  ),
                )
              : null,
          padding:
              const EdgeInsets.only(left: 4.0, top: 4, bottom: 4, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconData != null)
                Icon(
                  iconData,
                  size: 22,
                  color: messageColorScheme.primary,
                ),
              if (iconData != null) const SizedBox(width: 4),
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
          ),
        );
      },
    );
  }
}
