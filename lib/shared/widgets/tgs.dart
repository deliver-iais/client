import 'dart:io';

import 'package:deliver/shared/widgets/animated_lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class Tgs extends StatelessWidget {
  final double width;
  final double height;
  final bool repeat;
  final bool animate;
  final bool reverse;
  final bool addRepaintBoundary;
  final AnimationController? controller;
  final File? file;
  final String? assetsPath;
  final LottieDelegates? delegates;
  final BoxFit? fit;
  final AlignmentGeometry? alignment;
  final FrameRate? frameRate;
  final LottieOptions? options;
  final FilterQuality? filterQuality;

  const Tgs.asset(
    this.assetsPath, {
    super.key,
    this.controller,
    this.delegates,
    this.repeat = true,
    this.animate = true,
    this.addRepaintBoundary = true,
    this.reverse = false,
    this.width = 120,
    this.height = 120,
    this.fit,
    this.alignment,
    this.frameRate,
    this.options,
    this.filterQuality,
  }) : file = null;

  const Tgs.file(
    this.file, {
    super.key,
    this.controller,
    this.delegates,
    this.repeat = true,
    this.animate = true,
    this.addRepaintBoundary = true,
    this.reverse = false,
    this.width = 120,
    this.height = 120,
    this.fit,
    this.alignment,
    this.frameRate,
    this.options,
    this.filterQuality,
  }) : assetsPath = null;

  Future<LottieComposition> _loadAssetsComposition() async {
    final assetData = await rootBundle.load(assetsPath!);

    var bytes = assetData.buffer.asUint8List();

    bytes = GZipCodec().decode(bytes) as Uint8List;

    return LottieComposition.fromBytes(bytes);
  }

  Future<LottieComposition> _loadFileComposition() async {
    var bytes = await file!.readAsBytes();

    bytes = GZipCodec().decode(bytes) as Uint8List;

    return LottieComposition.fromBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final loader =
        assetsPath != null ? _loadAssetsComposition : _loadFileComposition;

    final cacheKey = assetsPath != null ? assetsPath! : file!.path;

    return AnimatedLottie(
      cacheKey,
      loader,
      frameRate: frameRate,
      addRepaintBoundary: addRepaintBoundary,
      animate: animate,
      alignment: alignment,
      controller: controller,
      delegates: delegates,
      filterQuality: filterQuality,
      fit: fit,
      height: height,
      key: key,
      options: options,
      repeat: repeat,
      reverse: reverse,
      width: width,
    );
  }
}
