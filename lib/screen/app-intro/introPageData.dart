import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/slide_object.dart';

final Color slideBackgroundColor = Colors.black;
final slidesList = [
  Slide(
    widgetTitle: Column(
      children: <Widget>[
        Container(
          width: 280,
          height: 250,
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
    widgetTitle: Column(
      children: <Widget>[
        Container(
          width: 280,
          height: 250,
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
    widgetTitle: Column(
      children: <Widget>[
        Container(
          width: 280,
          height: 250,
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
    widgetTitle: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 280,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: FlareActor(
              "assets/images/secure.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: "secure",
              sizeFromArtboard: true,
            ),
          ),
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
