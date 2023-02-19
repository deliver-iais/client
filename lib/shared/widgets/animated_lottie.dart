import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedLottie extends StatefulWidget {
  final AnimationController? controller;
  final LottieDelegates? delegates;
  final String cacheKey;
  final Future<LottieComposition> Function() loader;
  final double width;
  final double height;
  final bool repeat;
  final bool animate;
  final bool reverse;
  final bool addRepaintBoundary;
  final BoxFit? fit;
  final AlignmentGeometry? alignment;
  final FrameRate? frameRate;
  final LottieOptions? options;
  final FilterQuality? filterQuality;

  const AnimatedLottie(
    this.cacheKey,
    this.loader, {
    super.key,
    this.controller,
    this.delegates,
    this.fit,
    this.alignment,
    this.frameRate,
    this.options,
    this.filterQuality,
    this.repeat = true,
    this.animate = true,
    this.reverse = false,
    this.addRepaintBoundary = true,
    this.width = 120,
    this.height = 120,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedLottieState createState() => _AnimatedLottieState();
}

// todo edit solve animation bug  !!!!
class _AnimatedLottieState extends State<AnimatedLottie> {
  late final Future<LottieComposition> composition;

  @override
  void initState() {
    composition = Lottie.cache.putIfAbsent(widget.cacheKey, widget.loader);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition>(
      future: composition,
      builder: (context, snapshot) {
        final composition = snapshot.data;

        if (composition != null) {
          if (widget.controller != null) {
            widget.controller!.duration = composition.duration;
            if (widget.animate) {
              widget.controller!.forward();
            }
          }
          return Lottie(
            composition: composition,
            controller: widget.controller,
            delegates: widget.delegates,
            width: widget.width,
            height: widget.height,
            repeat: widget.repeat,
            reverse: widget.reverse,
            fit: widget.fit,
            animate: widget.animate,
            alignment: widget.alignment,
            frameRate: widget.frameRate,
            options: widget.options,
            addRepaintBoundary: widget.addRepaintBoundary,
            filterQuality: widget.filterQuality,
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
