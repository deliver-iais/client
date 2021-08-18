import 'dart:io';

import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';

class AnimatedEmoji extends StatefulWidget {
  final Message message;
  final bool isSeen;

  static final _authRepo = GetIt.I.get<AuthRepo>();

  const AnimatedEmoji({Key key, this.message, this.isSeen}) : super(key: key);

  static isAnimatedEmoji(Message message) {
    if (message.type != MessageType.TEXT) return false;
    final content = message.json.toText().text;

    switch (content) {
      case "👍":
      case "😘":
      case "🤔":
      case "😂":
      case "❤️":
      case "😍":
      case "😁":
      case "😉":
      case "😊":
        return true;
    }

    return false;
  }

  @override
  _AnimatedEmojiState createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSender =
        AnimatedEmoji._authRepo.isCurrentUserSender(widget.message);

    return Column(
      children: [
        GestureDetector(
          onTap: () => _controller.forward(from: 0),
          child: Container(
              child: Lottie.asset(getPath(), controller: _controller,
                  onLoaded: (composition) {
            // Configure the AnimationController with the duration of the
            // Lottie file and start the animation.
            _controller
              ..duration = composition.duration
              ..forward();
          }, width: 100, height: 100, repeat: false)),
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isSender
                ? ExtraTheme.of(context).sentMessageBox
                : ExtraTheme.of(context).receivedMessageBox,
          ),
          child: TimeAndSeenStatus(
            widget.message,
            isSender,
            widget.isSeen,
            needsBackground: false,
            needsPositioned: false,
          ),
        ),
      ],
    );
  }

  String getPath() {
    final content = widget.message.json.toText().text;

    final shortName = Emoji.byChar(content).shortName;

    return 'assets/emoji/$shortName.json';
  }
}

class AnimationLocal extends StatelessWidget {
  final String path;

  const AnimationLocal({Key key, this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Lottie.file(
      File(path),
      width: 100,
      height: 100,
    ));
  }
}
