import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/screen/room/widgets/boxContent.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class ReceivedMessageBox extends StatelessWidget {
  final Message message;
  final bool isGroup;
  final Function scrollToMessage;
  final Function omUsernameClick;
  final String pattern;
  final Function onBotCommandClick;

  ReceivedMessageBox(
      {Key key,
      this.message,
      this.onBotCommandClick,
      this.isGroup,
      this.scrollToMessage,
      this.omUsernameClick,
      this.pattern})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5.0),
      child: message.type == MessageType.STICKER
          ? BoxContent(
              message: message,
              maxWidth: maxWidthOfMessage(context),
              isSender: false,
              onBotCommandClick: onBotCommandClick,
              scrollToMessage: scrollToMessage,
              onUsernameClick: this.omUsernameClick,
            )
          : ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Container(
                color: ExtraTheme.of(context).receivedMessageBox,
                padding: const EdgeInsets.all(2),
                child: BoxContent(
                  message: message,
                  maxWidth: maxWidthOfMessage(context),
                  onBotCommandClick: onBotCommandClick,
                  isSender: false,
                  scrollToMessage: scrollToMessage,
                  pattern: this.pattern,
                  onUsernameClick: this.omUsernameClick,
                ),
              ),
            ),
    );
  }
}
