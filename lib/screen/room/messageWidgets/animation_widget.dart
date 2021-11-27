import 'dart:io';
import 'dart:typed_data';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class AnimatedEmoji extends StatefulWidget {
  final Message message;
  final bool isSeen;

  static final _authRepo = GetIt.I.get<AuthRepo>();

  const AnimatedEmoji({Key? key, required this.message, required this.isSeen})
      : super(key: key);

  static isAnimatedEmoji(Message message) {
    if (message.type != MessageType.TEXT) return false;
    final content = message.json!.toText().text;

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
      case "😢":
      case "🥰":
      case "😱":
      case "😐":
      case "🤣":
      case "😳":
      case "💋":
      case "🙃":
      case "😒":
      case "😞":
      case "🤓":
      case "😎":
      case "😋":
      case "😛":
      case "🙂":
      case "🤯":
      case "😡":
      case "🤬":
      case "🥵":
      case "🥶":
      // case "☹️️":
      case "🥺":
      case "😔":
        return true;
    }

    return false;
  }

  @override
  _AnimatedEmojiState createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Future<LottieComposition?> _composition;

  @override
  void initState() {
    super.initState();
    _composition = _loadComposition();
    _controller = AnimationController(vsync: this);
  }

  Future<LottieComposition?> _loadComposition() async {
    var assetData = await rootBundle.load(getPath());
    Uint8List bytes = assetData.buffer.asUint8List();
    bytes = GZipCodec().decode(bytes) as Uint8List;
    return await LottieComposition.fromBytes(bytes);
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
        FutureBuilder<LottieComposition?>(
            future: _composition,
            builder: (context, snapshot) {
              var composition = snapshot.data;
              if (composition != null) {
                _controller
                  ..duration = composition.duration
                  ..forward();
                return GestureDetector(
                  onTap: () => _controller.forward(from: 0),
                  child: Container(
                      child: Lottie(
                          composition: composition,
                          controller: _controller,
                          width: 120,
                          height: 120,
                          repeat: false),
                      width: 120,
                      height: 120),
                );
              } else
                return Container(width: 120, height: 120);
            }),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
    final content = widget.message.json!.toText().text;

    final shortName = Emoji.byChar(content).shortName;

    return 'assets/emoji/$shortName.tgs';
  }

  String getAlt() {
    final content = widget.message.json!.toText().text;

    final shortName = Emoji.byChar(content).shortName;

    return 'assets/emoji/$shortName - $content';
  }
}

class AnimationLocal extends StatelessWidget {
  final String path;

  const AnimationLocal({Key? key, required this.path}) : super(key: key);

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
