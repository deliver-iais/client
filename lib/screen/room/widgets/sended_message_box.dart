import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/box_content.dart';
import 'package:deliver/screen/room/widgets/message_wrapper.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/material.dart';

class SentMessageBox extends StatelessWidget {
  final Message message;
  final Function scrollToMessage;
  final bool isSeen;
  final bool isFirstMessageInGroupedMessages;
  final Function omUsernameClick;
  final String? pattern;
  final Function onArrowIconClick;
  final void Function(TapDownDetails) storePosition;

  const SentMessageBox(
      {Key? key,
      required this.message,
      required this.isSeen,
      required this.isFirstMessageInGroupedMessages,
      required this.scrollToMessage,
      this.pattern,
      required this.omUsernameClick,
      required this.storePosition,
      required this.onArrowIconClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomColorScheme colorScheme;
    if (message.type == MessageType.CALL &&
        (message.json.toCallEvent().newStatus == CallEvent_CallStatus.BUSY ||
            message.json.toCallEvent().newStatus ==
                CallEvent_CallStatus.DECLINED)) {
      colorScheme = ExtraTheme.of(context).messageColorScheme(message.to);
    } else {
      colorScheme = ExtraTheme.of(context).messageColorScheme(message.from);
    }

    final boxContent = BoxContent(
      message: message,
      maxWidth: maxWidthOfMessage(context),
      minWidth: minWidthOfMessage(context),
      isSender: true,
      scrollToMessage: scrollToMessage,
      isSeen: isSeen,
      pattern: pattern,
      isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      onUsernameClick: omUsernameClick,
      onArrowIconClick: onArrowIconClick,
      colorScheme: colorScheme,
      storePosition: storePosition,
    );

    return doNotNeedsWrapper()
        ? boxContent
        : MessageWrapper(
            uid: message.from,
            colorScheme: colorScheme,
            child: boxContent,
            isSender: true,
            isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages);
  }

  bool doNotNeedsWrapper() {
    return message.type == MessageType.STICKER ||
        AnimatedEmoji.isAnimatedEmoji(message);
  }
}
