import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

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

  void animate() {
    ctrl.forward(from: 0);
  }
}

class TGS extends StatefulWidget {
  final TGSController controller;

  final File file;
  final String assetsPath;

  TGS.assets(this.assetsPath, {Key key, TGSController controller})
      : file = null,
        controller = controller ?? TGSController(),
        super(key: key);

  TGS.file(this.file, {Key key, TGSController controller})
      : assetsPath = null,
        controller = controller ?? TGSController(),
        super(key: key);

  @override
  _TGSState createState() => _TGSState();
}

class _TGSState extends State<TGS> with TickerProviderStateMixin {
  Future<LottieComposition> _composition;

  Future<LottieComposition> _loadAssetsComposition() async {
    var assetData = await rootBundle.load(widget.assetsPath);

    var bytes = assetData.buffer.asUint8List();

    bytes = GZipCodec().decode(bytes);

    return await LottieComposition.fromBytes(bytes);
  }

  Future<LottieComposition> _loadFileComposition() async {
    var bytes = await widget.file.readAsBytes();

    bytes = GZipCodec().decode(bytes);

    return await LottieComposition.fromBytes(bytes);
  }

  @override
  void initState() {
    widget.controller.init(this);
    if (widget.assetsPath != null) {
      _composition = _loadAssetsComposition();
    } else {
      _composition = _loadFileComposition();
    }
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
