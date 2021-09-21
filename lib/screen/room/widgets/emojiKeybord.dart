import 'package:deliver/shared/constants.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmojiKeyboard extends StatefulWidget {
  final Function onTap;
  final Function onStickerTap;

  const EmojiKeyboard({this.onTap, this.onStickerTap});

  @override
  _Emojikeybord createState() => _Emojikeybord();
}

class _Emojikeybord extends State<EmojiKeyboard> {
  List<Emoji> emojis = [];
  Function onTap;

  int selectedGroupIndex = 1;

  bool emojiState = true;

  @override
  void initState() {
    emojis = Emoji.byGroup(EmojiGroup.smileysEmotion).toList();
    this.onTap = widget.onTap;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 22, fontFamily: "NotoColorEmoji",
    fontFamilyFallback: ["NotoColorEmoji"]);

    return emojiState
        ? Column(
            children: <Widget>[
              Divider(),
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: DefaultTextStyle(
                  style: TextStyle(fontSize: 20),
                  child: Container(
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
                              style: TextStyle(fontSize: 26, fontFamily: "NotoColorEmoji",
                                  fontFamilyFallback: ["NotoColorEmoji"]),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }
}
