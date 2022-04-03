import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

// TODO(hasan): add other options of Lottie in constructor, https://gitlab.iais.co/deliver/wiki/-/issues/413
class TGS extends StatefulWidget {
  final AnimationController? controller;

  final File? file;
  final String? assetsPath;

  final double width;
  final double height;
  final bool repeat;
  final bool autoPlay;

  const TGS.asset(
    this.assetsPath, {
    Key? key,
    this.controller,
    this.repeat = true,
    this.autoPlay = true,
    this.width = 120,
    this.height = 120,
  })  : file = null,
        super(key: key);

  const TGS.file(
    this.file, {
    Key? key,
    required this.controller,
    this.repeat = true,
    this.autoPlay = true,
    this.width = 120,
    this.height = 120,
  })  : assetsPath = null,
        super(key: key);

  @override
  _TGSState createState() => _TGSState();
}

// todo edit solve animation bug  !!!!
class _TGSState extends State<TGS> {
  late Future<LottieComposition?> _composition;

  Future<LottieComposition> _loadAssetsComposition() async {
    final assetData = await rootBundle.load(widget.assetsPath!);

    var bytes = assetData.buffer.asUint8List();

    bytes = GZipCodec().decode(bytes) as Uint8List;

    return LottieComposition.fromBytes(bytes);
  }

  Future<LottieComposition?> _loadFileComposition() async {
    var bytes = await widget.file!.readAsBytes();

    bytes = GZipCodec().decode(bytes) as Uint8List;

    return LottieComposition.fromBytes(bytes);
  }

  @override
  void initState() {
    if (widget.assetsPath != null) {
      _composition = _loadAssetsComposition();
    } else {
      _composition = _loadFileComposition();
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition?>(
      future: _composition,
      builder: (context, snapshot) {
        final composition = snapshot.data;

        if (composition != null) {
          if (widget.controller != null) {
            widget.controller!.duration = composition.duration;
            if (widget.autoPlay) {
              widget.controller!.forward();
            }
          }
          return Lottie(
            composition: composition,
            controller: widget.controller,
            width: widget.width,
            height: widget.height,
            repeat: widget.repeat,
          );
        } else {
          return SizedBox(
            width: widget.width,
            height: widget.height,
          );
        }
      },
    );
  }
}
