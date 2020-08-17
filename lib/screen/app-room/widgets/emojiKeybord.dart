import 'package:emojis/emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmojiKeybord extends StatefulWidget {
  final Function onTap;

 const EmojiKeybord({this.onTap});

  @override
  _Emojikeybord createState() => _Emojikeybord();
}

class _Emojikeybord extends State<EmojiKeybord> {
  Iterable<Emoji> emojis = List();
  Function onTap;

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.mood),
              onPressed: () {
                setState(() {
                  emojis = Emoji.byGroup(EmojiGroup.smileysEmotion);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.local_florist),
              onPressed: () {
                setState(() {
                  emojis = Emoji.byGroup(EmojiGroup.animalsNature);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.mood),
              onPressed: () {
                setState(() {
                  emojis = Emoji.byGroup(EmojiGroup.activities);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.mood),
              onPressed: () {
                setState(() {
                  emojis = Emoji.byGroup(EmojiGroup.flags);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.mood),
              onPressed: () {
                setState(() {
                  emojis = Emoji.byGroup(EmojiGroup.peopleBody);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.local_florist),
              onPressed: () {
                setState(() {
                  emojis = Emoji.byGroup(EmojiGroup.animalsNature);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.local_florist),
              onPressed: () {
                setState(() {
                  emojis = Emoji.byGroup(EmojiGroup.animalsNature);
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
                onTap: (){
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
