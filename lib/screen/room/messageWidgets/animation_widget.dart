import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
    super.key,
    required this.message,
    required this.isSeen,
    required this.colorScheme,
  });

  static bool isAnimatedEmojiMessage(Message message) {
    if (message.type != MessageType.TEXT) return false;
    final content = message.json.toText().text;

    return isAnimatedEmoji(content);
  }

  @override
  AnimatedEmojiState createState() => AnimatedEmojiState();
}

class AnimatedEmojiState extends State<AnimatedEmoji>
    with TickerProviderStateMixin {
  static final _featureFlags = GetIt.I.get<FeatureFlags>();

  late AnimationController _controller;
  late String path;

  @override
  void initState() {
    super.initState();
    try {
      path = getPath();
    } catch (_) {}
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
      // Reply box in animated emoji has different UI
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (_featureFlags.showDeveloperDetails)
          DebugC(
            isOpen: true,
            children: [
              Debug(shortname(), label: "Path"),
              Debug(content(), label: "content"),
            ],
          ),
        GestureDetector(
          onTap: () => _controller.forward(from: 0),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Ws.asset(
              path,
              controller: isWeb ? _controller : null,
              repeat: !isWeb,
            ),
          ),
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

    return 'assets/emoji/$shortName.ws';
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
