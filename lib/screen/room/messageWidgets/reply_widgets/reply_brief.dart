import 'dart:math';

import 'package:animations/animations.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

class ReplyBrief extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();

  final String roomId;
  final int replyToId;
  final double maxWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final MessageBrief? messageReplyBrief;

  const ReplyBrief({
    super.key,
    required this.roomId,
    required this.replyToId,
    required this.maxWidth,
    required this.backgroundColor,
    required this.foregroundColor,
    this.messageReplyBrief,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 58,
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: FutureBuilder<Message?>(
        future: _messageRepo.getMessage(roomId, replyToId),
        builder: (context, snapshot) {
          final future = extractMessageSimpleRepresentative(snapshot.data);

          Widget widget;

          if (future == null) {
            widget = Shimmer.fromColors(
              baseColor: theme.colorScheme.outline.withOpacity(0.05),
              highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: secondaryBorder,
                  color: theme.colorScheme.surface,
                ),
                width: max(maxWidth - 8, 0),
                height: 44,
              ),
            );
          } else {
            widget = SenderAndContent(
              iconData: CupertinoIcons.reply,
              maxWidth: maxWidth,
              showBackgroundColor: true,
              messageSRF: future,
            );
          }

          return PageTransitionSwitcher(
            transitionBuilder: (
              child,
              animation,
              secondaryAnimation,
            ) {
              return SharedAxisTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.vertical,
                child: child,
              );
            },
            child: widget,
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
