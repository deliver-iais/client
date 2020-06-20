import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/slide_object.dart';

final Color slideBackgroundColor = Colors.black;
final slidesList = [
  Slide(
    centerWidget: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 50,
              height: 120,
            ),
            Column(
              children: <Widget>[
                Container(
                  width: 180,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFF5F5F5F),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: FlareActor(
                      "assets/images/messenger.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: "chat",
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF5F5F5F),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Text(
              'Messenger',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 200,
            child: Text(
              'The world`s fastest messaging app. It is free and secure.',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    ),
    backgroundColor: slideBackgroundColor,
  ),
  Slide(
    centerWidget: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF5F5F5F),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  width: 180,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFF5F5F5F),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: FlareActor(
                      "assets/images/fast.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: "fast",
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF5F5F5F),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Text(
              'Fast',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 200,
            child: Text(
              'Messenger delivers messages fastest than any other application.',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    ),
    backgroundColor: slideBackgroundColor,
  ),
  Slide(
    centerWidget: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF5F5F5F),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  width: 180,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFF5F5F5F),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: FlareActor(
                      "assets/images/infinity.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: "infinity",
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF5F5F5F),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Text(
              'Powerful',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 200,
            child: Text(
              'Messenger has no limits on the size of your media and chats.',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    ),
    backgroundColor: slideBackgroundColor,
  ),
  Slide(
    centerWidget: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF5F5F5F),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  width: 180,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFF5F5F5F),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Container(
                      child: FlareActor(
                        "assets/images/secure.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: "secure",
                        sizeFromArtboard: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 120,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Text(
              'Secure',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 200,
            child: Text(
              'Messenger keeps your messages safe from hacker attacks.',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    ),
    backgroundColor: slideBackgroundColor,
  ),
];
