import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/screen/room/widgets/boxContent.dart';
import 'package:deliver_flutter/screen/room/widgets/message_wrapper.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class SentMessageBox extends StatelessWidget {
  final Message message;
  final Function scrollToMessage;
  final bool isSeen;
  final Function omUsernameClick;
  final String pattern;

  const SentMessageBox(
      {Key key,
      this.message,
      this.isSeen,
      this.scrollToMessage,
      this.pattern,
      this.omUsernameClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      maxWidth: maxWidthOfMessage(context),
      isSender: true,
      scrollToMessage: scrollToMessage,
      isSeen: this.isSeen,
      pattern: pattern,
      onUsernameClick: this.omUsernameClick,
    );

    return message.type == MessageType.STICKER
        ? boxContent
        : MessageWrapper(child: boxContent, isSent: true);
  }
}
