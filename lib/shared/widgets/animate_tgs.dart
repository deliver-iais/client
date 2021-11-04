import 'package:flutter/material.dart';

class TGSController {
  final bool repeat;

  AnimationController ctrl;

  TGSController({this.repeat = true});

  void init(TickerProvider vsync) {
    ctrl = AnimationController(vsync: vsync);
  }

  void dispose() {
    ctrl.dispose();
  }

  void animate() {}
}

class TGS extends StatefulWidget {
  final TGSController controller;

  TGS({Key key, this.controller}) : super(key: key);

  @override
  _TGSState createState() => _TGSState();
}

class _TGSState extends State<TGS> with TickerProviderStateMixin {
  @override
  void initState() {
    widget.controller.init(this);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
