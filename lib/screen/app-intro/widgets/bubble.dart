import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  int _current, _index;
  Bubble(this._current, this._index);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _current == _index
            ? Color.fromRGBO(0, 0, 0, 0.9)
            : Color.fromRGBO(0, 0, 0, 0.4),
      ),
    );
  }
}
