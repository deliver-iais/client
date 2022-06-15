import 'dart:io';
import 'dart:typed_data';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

bool isAnimatedEmoji(String content) {
  switch (content) {
    case "😀":
    case "😃":
    case "😄":
    case "😆":
    case "😅":
    case "😇":
    case "😌":
    case "🥲":
    case "😗":
    case "😙":
    case "😚":
    case "😝":
    case "😜":
    case "🤪":
    case "🧐":
    case "🤩":
    case "🥳":
    case "😏":
    case "😟":
    case "😕":
    case "🙁":
    case "😖":
    case "😫":
    case "😩":
    case "😭":
    case "😤":
    case "😨":
    case "😰":
    case "😓":
    case "🤗":
    case "🤭":
    case "🥱":
    case "🤫":
    case "🤥":
    case "😶":
    case "😑":
    case "😬":
    case "🙄":
    case "😯":
    case "😦":
    case "😧":
    case "😮":
    case "😲":
    case "😴":
    case "🤤":
    case "😪":
    case "🤐":
    case "🥴":
    case "🤢":
    case "🤮":
    case "🤧":
    case "😷":
    case "🤒":
    case "🤕":
    case "🤑":
    case "🤠":
    case "🥸":
    case "😈":
    case "👿":
    case "🤡":
    case "💩":
    case "👻":
    case "💀":
    case "☠️":
    case "🤖":
    case "😺":
    case "😸":
    case "😹":
    case "😻":
    case "😼":
    case "😽":
    case "🙀":
    case "😿":
    case "😾":
    case "🙈":
    case "🙊":
    case "💫":
    case "💥":
    case "💌":
    case "❤️":
    case "🧡":
    case "💛":
    case "💚":
    case "💙":
    case "💜":
    case "🖤":
    case "🤎":
    case "🤍":
    case "💔":
    case "❣️":
    case "💕":
    case "💞":
    case "💓":
    case "💖":
    case "💘":
    case "💝":
    case "💟":
    case "💯":
    case "💢":
    case "💤":
    case "💬":
    case "💭":
    case "💗":
    case "🤲":
    case "👐":
    case "🙌":
    case "👏":
    case "🤝":
    case "👍":
    case "👎":
    case "👊":
    case "✊":
    case "🤛":
    case "🤜":
    case "🤞":
    case "😘":
    case "🤔":
    case "😂":
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
    case "✌️":
    case "🤟":
    case "🤘":
    case "👌":
    case "🤏":
    case "🤌":
    case "👈":
    case "👉":
    case "👆":
    case "👇":
    case "☝️":
    case "✋":
    case "🤚":
    case "🖐":
    case "🖖":
    case "👋":
    case "🤙":
    case "💪":
    case "🦾":
    case "✍️":
    case "🙏":
    case "🦶":
    case "🦵":
    case "🦿":
    case "🎅":
    case "🧛‍♀️":
    case "🧛":
    case "🧛‍♂️":
    case "🧟‍♀️":
    case "🧟":
    case "🧟‍♂️":
    case "🌝":
    case "🌛":
    case "🌜":
    case "🌚":
    case "🌕":
    case "🌖":
    case "🌗":
    case "🌘":
    case "🌑":
    case "🌒":
    case "🌓":
    case "🌔":
    case "⭐":
    case "🌟":
    case "⚡":
    case "🔥":
    case "☃️":
    case "⛄":
    case "🍔":
    case "🌭":
    case "🍟":
    case "🍕":
    case "🌮":
    case "🍦":
    case "🎮":
    case "🚗":
    case "🚕":
    case "🚓":
    case "🚑":
    case "🗿":
    case "⏳":
    case "🎈":
    case "📝":
    case "❌":
    case "♨️":
    case "❗":
    case "❕":
    case "❓":
    case "❔":
    case "📣":
    case "☺️":
    case "☹️":
    case "👂":
    case "🦻":
    case "👃":
    case "🌸":
    case "🌺":
    case "🌹":
    case "🌷":
    case "🌿":
    case "🌱":
    case "🌴":
    case "🌳":
    case "🌲":
    case "🌵":
    case "👛":
    case "☎️":
    case "📞":
    case "💡":
    case "⚰️":
    case "💊":
    case "💉":
    case "🧻":
    case "🧼":
    case "🧽":
    case "📬":
    case "📊":
    case "📁":
    case "📂":
    case "🧮":
    case "💸":
    case "💎":
      return true;
  }

  return false;
}

class AnimatedEmoji extends StatefulWidget {
  final Message message;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  static final _authRepo = GetIt.I.get<AuthRepo>();

  const AnimatedEmoji({
    Key? key,
    required this.message,
    required this.isSeen,
    required this.colorScheme,
  }) : super(key: key);

  static bool isAnimatedEmojiMessage(Message message) {
    if (message.type != MessageType.TEXT) return false;
    final content = message.json.toText().text;

    return isAnimatedEmoji(content);
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
    try {
      _composition = _loadComposition();
    } catch (_) {}
    _controller = AnimationController(vsync: this);
  }

  Future<LottieComposition?> _loadComposition() async {
    final assetData = await rootBundle.load(getPath());
    var bytes = assetData.buffer.asUint8List();
    bytes = GZipCodec().decode(bytes) as Uint8List;
    return LottieComposition.fromBytes(bytes);
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
        if (isDebugEnabled())
          DebugC(
            isOpen: true,
            children: [
              Debug(shortname(), label: "Path"),
              Debug(content(), label: "content"),
            ],
          ),
        FutureBuilder<LottieComposition?>(
          future: _composition,
          builder: (context, snapshot) {
            final composition = snapshot.data;
            if (composition != null) {
              _controller
                ..duration = composition.duration
                ..forward();
              return GestureDetector(
                onTap: () => _controller.forward(from: 0),
                child: SizedBox(
                  child: Lottie(
                    composition: composition,
                    controller: _controller,
                    width: 120,
                    height: 120,
                    repeat: false,
                  ),
                  width: 120,
                  height: 120,
                ),
              );
            } else {
              return const SizedBox(width: 120, height: 120);
            }
          },
        ),
        Container(
          decoration: const BoxDecoration(borderRadius: mainBorder),
          child: TimeAndSeenStatus(
            widget.message,
            isSender: isSender,
            isSeen: widget.isSeen,
            needsPositioned: false,
            showBackground: true,
            needsPadding: true,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  String getPath() {
    final content = widget.message.json.toText().text;

    final shortName = Emoji.byChar(content).shortName;

    return 'assets/emoji/$shortName.tgs';
  }

  String shortname() {
    try {
      final content = widget.message.json.toText().text;

      final shortName = Emoji.byChar(content).shortName;

      return shortName;
    } catch (e) {
      return e.toString();
    }
  }

  String content() {
    try {
      return widget.message.json.toText().text;
    } catch (_) {
      return "";
    }
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
      ),
    );
  }
}
