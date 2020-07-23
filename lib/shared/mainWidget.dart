

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainWidget extends StatelessWidget {
  Widget _widget;
  double _start;
  double _end;
  MainWidget(Widget widget,double start , double end){
    this._widget = widget;
    this._end = end;
    this._start = start;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsetsDirectional.only(start: _start, end: _end),
      child: _widget,
    );
  }

}
