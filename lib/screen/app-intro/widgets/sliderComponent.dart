import 'package:flutter/material.dart';
import '../introPageData.dart';

class SliderComponent extends StatelessWidget {
  final int _index;

  SliderComponent(this._index);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Image.asset(sliderContents[_index].imgAddr, height: 120, width: 120),
        Text(
          sliderContents[_index].title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          sliderContents[_index].description,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    ));
  }
}
