import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmojiKeyboard extends StatefulWidget {
  final void Function(String) onTap;
  final Function? onStickerTap;

  const EmojiKeyboard({super.key, required this.onTap, this.onStickerTap});

  @override
  EmojiKeyboardState createState() => EmojiKeyboardState();
}

class EmojiKeyboardState extends State<EmojiKeyboard> {
  Iterable<Emoji> emojis = [];

  String selectedGroupIndex = "😀";

  @override
  void initState() {
    emojis = Emoji.byGroup(EmojiGroup.smileysEmotion);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Divider(),
        Container(
          color: theme.colorScheme.surfaceVariant,
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 20),
            child: SizedBox(
              height: 52,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: <Widget>[
                    buildSelectedContainer(theme, "😀", () {
                      emojis = Emoji.byGroup(EmojiGroup.smileysEmotion).where(
                        (e) => !e.shortName.contains("transgender"),
                      );
                    }),
                    buildSelectedContainer(theme, "🖐", () {
                      emojis = Emoji.byGroup(EmojiGroup.peopleBody)
                          .where(
                            (e) => !e.shortName.contains("transgender"),
                          )
                          .where(
                            (element) => !element.shortName.contains("_tone"),
                          );
                    }),
                    buildSelectedContainer(theme, "🐶", () {
                      emojis = Emoji.byGroup(EmojiGroup.animalsNature).where(
                        (e) => !e.shortName.contains("transgender"),
                      );
                    }),
                    buildSelectedContainer(theme, "🏳", () {
                      emojis = Emoji.byGroup(EmojiGroup.flags)
                          .where(
                            (e) => !e.shortName.contains("transgender"),
                          )
                          .where(
                            (e) => !e.shortName.contains("rainbow_flag"),
                          )
                          .where(
                            (e) => !e.shortName.contains("flag_il"),
                          );
                    }),
                    buildSelectedContainer(theme, "💡", () {
                      emojis = Emoji.byGroup(EmojiGroup.objects).where(
                        (e) => !e.shortName.contains("transgender"),
                      );
                    }),
                    buildSelectedContainer(theme, "🏠", () {
                      emojis = Emoji.byGroup(EmojiGroup.travelPlaces);
                    }),
                    buildSelectedContainer(theme, "🕉️", () {
                      emojis = Emoji.byGroup(EmojiGroup.symbols).where(
                        (e) => !e.shortName.contains("transgender"),
                      );
                    }),
                    buildSelectedContainer(theme, "🍔", () {
                      emojis = Emoji.byGroup(EmojiGroup.foodDrink).where(
                        (e) => !e.shortName.contains("transgender"),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: theme.colorScheme.surface,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: emojis.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.of(context).size.width -
                        (isLarge(context) ? NAVIGATION_PANEL_SIZE : 0)) ~/
                    50,
              ),
              itemBuilder: (context, index) {
                final emoji = emojis.elementAt(index);

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => widget.onTap(emoji.toString()),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          emoji.toString(),
                          style: GoogleFonts.notoEmoji(fontSize: 25),
                        ),
                      ),
                      if (isDebugEnabled())
                        if (isAnimatedEmoji(emoji.toString()))
                          Center(
                            child: Container(
                              color: ACTIVE_COLOR,
                              height: 10,
                              width: 10,
                            ),
                          )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  TextStyle selectionStyle(ThemeData theme, String emoji) {
    return GoogleFonts.notoEmoji(
      fontSize: 22,
      color: selectionColor(theme, emoji),
      fontWeight: isSelectedEmojiGroup(emoji) ? FontWeight.bold : null,
    );
  }

  Color selectionColor(ThemeData theme, String emoji) {
    if (isSelectedEmojiGroup(emoji)) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.onSurfaceVariant.withOpacity(0.7);
    }
  }

  Border selectionBorder(ThemeData theme, String emoji) {
    if (isSelectedEmojiGroup(emoji)) {
      return Border(
        bottom: BorderSide(color: theme.colorScheme.primary, width: 3),
      );
    } else {
      return const Border(
        bottom: BorderSide(color: Colors.transparent, width: 0),
      );
    }
  }

  bool isSelectedEmojiGroup(String emoji) => emoji == selectedGroupIndex;

  Widget buildSelectedContainer(
    ThemeData theme,
    String emoji,
    void Function() callback,
  ) {
    return AnimatedContainer(
      padding: const EdgeInsets.only(
        left: 4.0,
        right: 8.0,
        top: 4.0,
        bottom: 3.0,
      ),
      decoration: BoxDecoration(
        border: selectionBorder(theme, emoji),
      ),
      duration: ANIMATION_DURATION,
      child: IconButton(
        icon: Text(emoji, style: selectionStyle(theme, emoji)),
        onPressed: () {
          setState(() {
            selectedGroupIndex = emoji;
            callback();
          });
        },
      ),
    );
  }
}
