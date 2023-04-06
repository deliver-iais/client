import 'dart:async';

import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  AnimatedLottieState createState() => AnimatedLottieState();
}

class AnimatedLottieState extends State<AnimatedLottie> {
  static final _appLifecycleService = GetIt.I.get<AppLifecycleService>();
  late final Future<LottieComposition> _composition;

  StreamSubscription<AppLifecycle>? _subscription;

  @override
  void initState() {
    _subscription = _appLifecycleService.lifecycleStream.listen((event) {
      setState(() {});
    });
    _composition = Lottie.cache.putIfAbsent(widget.cacheKey, widget.loader);
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition>(
      future: _composition,
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
            animate: _appLifecycleService.isActive && widget.animate,
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
