import 'package:flutter/material.dart';
import 'package:intro_slider/slide_object.dart';

final Color slideBackgroundColor = Colors.black;
final slidesList = [
  Slide(
    title: 'Messenger',
    pathImage: 'assets/images/messenger.png',
    description: 'The world`s fastest messaging app. It is free and secure.',
    backgroundColor: slideBackgroundColor,
    styleTitle: TextStyle(
      color: Color(0xFF2699FB),
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
    styleDescription: TextStyle(
      color: Color(0xFF2699FB),
      fontSize: 18,
    ),
    marginDescription: EdgeInsets.only(left: 50, right: 50),
  ),
  Slide(
    pathImage: 'assets/images/fast.png',
    title: 'Fast',
    description:
        'Messenger delivers messages fastest than any other application.',
    backgroundColor: slideBackgroundColor,
    styleTitle: TextStyle(
      color: Color(0xFF2699FB),
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
    styleDescription: TextStyle(
      color: Color(0xFF2699FB),
      fontSize: 18,
    ),
  ),
  Slide(
    title: 'Private',
    pathImage: 'assets/images/private.png',
    description:
        'Messenger messages are heavily encrypted and can self-destruct.',
    backgroundColor: slideBackgroundColor,
    styleTitle: TextStyle(
      color: Color(0xFF2699FB),
      fontSize: 18,
    ),
    styleDescription: TextStyle(
      color: Color(0xFF2699FB),
      fontSize: 18,
    ),
  ),
  Slide(
    title: 'Secure',
    pathImage: 'assets/images/secure.png',
    description: 'Messenger keeps your messages safe from hacker attacks.',
    backgroundColor: slideBackgroundColor,
    styleTitle: TextStyle(
      color: Color(0xFF2699FB),
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
    styleDescription: TextStyle(
      color: Color(0xFF2699FB),
      fontSize: 18,
    ),
  ),
];
