import 'package:flutter/material.dart';

class Bubbles extends StatelessWidget {
  final int _current, _size;
  Bubbles(this._current, this._size);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: List.generate(
          _size,
          (index) => Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index
                  ? Theme.of(context).primaryColor
                  : Color(0xFFBCE0FD),
            ),
          ),
        ),
      ),
    );
  }
}
