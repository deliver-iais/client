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
                    child: Container(
                      child: Image.asset(
                        'assets/images/messenger.png',
                      ),
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
                    child: Container(
                      child: Image.asset(
                        'assets/images/fast.png',
                      ),
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
                    child: Container(
                      child: Image.asset(
                        'assets/images/private.png',
                      ),
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
              'Private',
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
              'Messenger messages are heavily encrypted and can self-destruct.',
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
                      child: Image.asset(
                        'assets/images/secure.png',
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
