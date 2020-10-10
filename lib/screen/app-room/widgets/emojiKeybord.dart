import 'package:emojis/emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class EmojiKeybord extends StatefulWidget {
  final Function onTap;

  const EmojiKeybord({this.onTap});

  @override
  _Emojikeybord createState() => _Emojikeybord();
}

class _Emojikeybord extends State<EmojiKeybord> {
  Iterable<Emoji> emojis = List();
  Function onTap;

  int selectedGroupIndex = 1;

  @override
  void initState() {
    emojis = Emoji.byGroup(EmojiGroup.smileysEmotion);
    this.onTap = widget.onTap;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.mood,
                color: selectedGroupIndex == 1 ? Colors.white : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selectedGroupIndex = 1;
                  emojis = Emoji.byGroup(EmojiGroup.smileysEmotion);
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.account_circle,
                color: selectedGroupIndex == 2 ? Colors.white : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selectedGroupIndex = 2;
                  emojis = Emoji.byGroup(EmojiGroup.peopleBody);
                });
              },
            ),
            IconButton(
              icon: Icon(Octicons.octoface,
                color: selectedGroupIndex == 3 ? Colors.white : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selectedGroupIndex = 3;
                  emojis = Emoji.byGroup(EmojiGroup.animalsNature);
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.flag,
                color: selectedGroupIndex == 4 ? Colors.white : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selectedGroupIndex = 4;
                  emojis = Emoji.byGroup(EmojiGroup.flags);
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.watch,
                color: selectedGroupIndex == 5 ? Colors.white : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selectedGroupIndex = 5;
                  emojis = Emoji.byGroup(EmojiGroup.objects);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.wb_incandescent,color: selectedGroupIndex ==6 ? Colors.white:Colors.grey,),
              onPressed: () {
                setState(() {
                  selectedGroupIndex =6;
                  emojis = Emoji.byGroup(EmojiGroup.travelPlaces);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline,color: selectedGroupIndex ==7? Colors.white:Colors.grey,),
              onPressed: () {
                setState(() {
                  selectedGroupIndex =7;
                  emojis = Emoji.byGroup(EmojiGroup.symbols);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.local_florist,color: selectedGroupIndex ==8 ? Colors.white:Colors.grey,),
              onPressed: () {
                setState(() {
                  selectedGroupIndex=8;
                  emojis = Emoji.byGroup(EmojiGroup.foodDrink);
                });
              },
            ),
          ],
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 7,
            children: List.generate(emojis.length, (index) {
              return GestureDetector(
                onTap: () {
                  onTap(emojis.elementAt(index).toString());
                },
                child: Text(
                  emojis.elementAt(index).toString(),
                  style: TextStyle(fontSize: 24),
                ),
              );
            }),
          ),
        )
      ],
    ));
  }
}
