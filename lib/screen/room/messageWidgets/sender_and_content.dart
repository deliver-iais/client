import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/constants.dart';
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
    super.key,
    required this.messageSRF,
    this.maxWidth,
    this.iconData,
    this.expandContent = true,
    this.showBackgroundColor = false,
    this.highlightColor,
  });

  SenderAndContent.viaMessage({
    super.key,
    required Message message,
    this.maxWidth,
    this.iconData,
    this.expandContent = true,
    this.showBackgroundColor = false,
    this.highlightColor,
  }) : messageSRF =
            _messageExtractorServices.extractMessageSimpleRepresentative(
          _messageExtractorServices.extractProtocolBufferMessage(message),
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraTheme = ExtraTheme.of(context);

    return FutureBuilder<MessageSimpleRepresentative>(
      future: messageSRF,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(height: theme.textTheme.bodyMedium!.fontSize! + 7);
        }

        final messageColorScheme =
            extraTheme.messageColorScheme(snapshot.data!.from);

        return Container(
          constraints: maxWidth != null
              ? BoxConstraints(maxWidth: max(maxWidth!, 100) - 12)
              : null,
          decoration: showBackgroundColor
              ? const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                )
              : null,
          clipBehavior: showBackgroundColor ? Clip.hardEdge : Clip.none,
          child: Container(
            decoration: showBackgroundColor
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: messageColorScheme.primary,
                        width: 3,
                      ),
                    ),
                    color: Color.lerp(
                      theme.colorScheme.surface,
                      messageColorScheme.primary,
                      0.1,
                    ),
                  )
                : null,
            padding: const EdgeInsetsDirectional.all(p4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (iconData != null)
                  Icon(
                    iconData,
                    size: 18,
                    color: messageColorScheme.primary,
                  ),
                if (iconData != null) const SizedBox(width: 4),
                Flexible(
                  child: LastMessage(
                    messageSR: snapshot.data!,
                    showSender: true,
                    useMultiLineText: true,
                    highlightColor: messageColorScheme.primary,
                    expandContent: expandContent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
