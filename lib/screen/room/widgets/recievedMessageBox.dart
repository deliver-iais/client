import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/screen/room/widgets/boxContent.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';

import 'message_wrapper.dart';

class ReceivedMessageBox extends StatelessWidget {
  final Message message;
  final Function scrollToMessage;
  final Function omUsernameClick;
  final String pattern;
  final Function onBotCommandClick;

  ReceivedMessageBox(
      {Key key,
      this.message,
      this.onBotCommandClick,
      this.scrollToMessage,
      this.omUsernameClick,
      this.pattern})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      maxWidth: maxWidthOfMessage(context),
      onBotCommandClick: onBotCommandClick,
      isSender: false,
      scrollToMessage: scrollToMessage,
      pattern: this.pattern,
      onUsernameClick: this.omUsernameClick,
    );

    return message.type == MessageType.STICKER
        ? boxContent
        : MessageWrapper(child: boxContent, isSent: false);
  }
}
