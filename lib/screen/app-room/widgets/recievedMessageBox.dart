import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/screen/app-room/widgets/boxContent.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class RecievedMessageBox extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final bool isGroup;
  final Function scrollToMessage;
  final Function omUsernameClick;
  final String pattern;
  final Function onBotCommandClick;

  RecievedMessageBox(
      {Key key,
      this.message,
      this.maxWidth,
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
              maxWidth: maxWidth,
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
                  maxWidth: maxWidth,
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
