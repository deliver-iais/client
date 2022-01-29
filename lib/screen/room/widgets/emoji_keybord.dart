import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmojiKeyboard extends StatefulWidget {
  final Function onTap;
  final Function? onStickerTap;

  const EmojiKeyboard({Key? key, required this.onTap, this.onStickerTap}) : super(key: key);

  @override
  _EmojiKeyboard createState() => _EmojiKeyboard();
}

class _EmojiKeyboard extends State<EmojiKeyboard> {
  List<Emoji> emojis = [];
  late Function onTap;

  int selectedGroupIndex = 1;

  bool emojiState = true;

  @override
  void initState() {
    emojis = Emoji.byGroup(EmojiGroup.smileysEmotion).toList();
    onTap = widget.onTap;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.notoColorEmojiCompat(
      fontSize: 22,
    );

    return emojiState
        ? Column(
            children: <Widget>[
              const Divider(),
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: DefaultTextStyle(
                  style: const TextStyle(fontSize: 20),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Container(
                          color: selectedGroupIndex == 1
                              ? Theme.of(context).dividerColor.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: IconButton(
                            icon: Text("🙂", style: style),
                            onPressed: () {
                              setState(() {
                                selectedGroupIndex = 1;
                                emojis =
                                    Emoji.byGroup(EmojiGroup.smileysEmotion)
                                        .where((e) => !e.shortName
                                            .contains("transgender"))
                                        .toList();
                              });
                            },
                          ),
                        ),
                        Container(
                          color: selectedGroupIndex == 2
                              ? Theme.of(context).dividerColor.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: IconButton(
                            icon: Text("🖐", style: style),
                            onPressed: () {
                              setState(() {
                                selectedGroupIndex = 2;
                                emojis = Emoji.byGroup(EmojiGroup.peopleBody)
                                    .where((e) =>
                                        !e.shortName.contains("transgender"))
                                    .where((element) =>
                                        !element.shortName.contains("_tone"))
                                    .toList();
                              });
                            },
                          ),
                        ),
                        Container(
                          color: selectedGroupIndex == 3
                              ? Theme.of(context).dividerColor.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: IconButton(
                            icon: Text("🐸", style: style),
                            onPressed: () {
                              setState(() {
                                selectedGroupIndex = 3;
                                emojis = Emoji.byGroup(EmojiGroup.animalsNature)
                                    .where((e) =>
                                        !e.shortName.contains("transgender"))
                                    .toList();
                              });
                            },
                          ),
                        ),
                        Container(
                          color: selectedGroupIndex == 4
                              ? Theme.of(context).dividerColor.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: IconButton(
                            icon: Text("🏁", style: style),
                            onPressed: () {
                              selectedGroupIndex = 4;
                              emojis = Emoji.byGroup(EmojiGroup.flags)
                                  .where((e) =>
                                      !e.shortName.contains("transgender"))
                                  .where((e) =>
                                      !e.shortName.contains("rainbow_flag"))
                                  .where(
                                      (e) => !e.shortName.contains("flag_il"))
                                  .toList();
                              setState(() {});
                            },
                          ),
                        ),
                        Container(
                          color: selectedGroupIndex == 5
                              ? Theme.of(context).dividerColor.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: IconButton(
                            icon: Text("💎", style: style),
                            onPressed: () {
                              setState(() {
                                selectedGroupIndex = 5;
                                emojis = Emoji.byGroup(EmojiGroup.objects)
                                    .where((e) =>
                                        !e.shortName.contains("transgender"))
                                    .toList();
                              });
                            },
                          ),
                        ),
                        Container(
                          color: selectedGroupIndex == 6
                              ? Theme.of(context).dividerColor.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: IconButton(
                            icon: Text("🚑", style: style),
                            onPressed: () {
                              setState(() {
                                selectedGroupIndex = 6;
                                emojis = Emoji.byGroup(EmojiGroup.travelPlaces)
                                    .toList();
                              });
                            },
                          ),
                        ),
                        Container(
                          color: selectedGroupIndex == 7
                              ? Theme.of(context).dividerColor.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: IconButton(
                            icon: Text("✅", style: style),
                            onPressed: () {
                              setState(() {
                                selectedGroupIndex = 7;
                                emojis = Emoji.byGroup(EmojiGroup.symbols)
                                    .where((e) =>
                                        !e.shortName.contains("transgender"))
                                    .toList();
                              });
                            },
                          ),
                        ),
                        Container(
                          color: selectedGroupIndex == 8
                              ? Theme.of(context).dividerColor.withOpacity(0.3)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: IconButton(
                            icon: Text("🍎", style: style),
                            onPressed: () {
                              setState(() {
                                selectedGroupIndex = 8;
                                emojis = Emoji.byGroup(EmojiGroup.foodDrink)
                                    .where((e) =>
                                        !e.shortName.contains("transgender"))
                                    .toList();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: GridView.builder(
                      itemCount: emojis.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (MediaQuery.of(context).size.width -
                                  (isLarge(context)
                                      ? NAVIGATION_PANEL_SIZE
                                      : 0)) ~/
                              50),
                      itemBuilder: (context, index) {
                        var emoji = emojis.elementAt(index);

                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            onTap(emoji.toString());
                          },
                          child: Center(
                            child: Text(
                              emoji.toString(),
                              style: GoogleFonts.notoColorEmojiCompat(
                                fontSize: 25,
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}
