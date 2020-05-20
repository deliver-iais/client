import 'package:flutter/material.dart';

class SliderComponent extends StatelessWidget {
  final String _title;
  final String _imageAddress;

  SliderComponent(this._title, this._imageAddress);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(_title),
          Image.asset(_imageAddress, height: 120, width: 120),
        ],
      ));
  }
}
