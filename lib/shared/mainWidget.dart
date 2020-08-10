import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainWidget extends StatelessWidget {
  final Widget _widget;
  final double _start;
  final double _end;

  MainWidget(this._widget, this._start, this._end);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(start: _start, end: _end),
      child: _widget,
    );
  }
}
