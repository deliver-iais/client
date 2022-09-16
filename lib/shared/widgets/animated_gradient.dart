import 'dart:ui';

import 'package:deliver/services/ux_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class AnimatedGradient extends StatefulWidget {
  final bool isConnected;

  const AnimatedGradient({
    super.key,
    this.isConnected = false,
  });

  @override
  AnimatedGradientState createState() => AnimatedGradientState();
}

class AnimatedGradientState extends State<AnimatedGradient>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animation =
        Tween<double>(begin: 10, end:80).animate(_animationController);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController
          ..reset()
          ..forward();
      }
    });

    _animationController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isConnected: widget.isConnected,
      animation: _animation,
    );
  }
}

class AnimatedBackground extends AnimatedWidget {
  static final uxService = GetIt.I.get<UxService>();
  final bool isConnected;

  const AnimatedBackground({
    super.key,
    required this.isConnected,
    required Animation<double> animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final gradientColors = <Color>[
      Color(
        uxService.getCorePalette().primary.get(uxService.themeIsDark ? 50 : 80),
      ),
      Color(
        uxService
            .getCorePalette()
            .tertiary
            .get(uxService.themeIsDark ? 50 : 70),
      ),
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: isConnected
            ? Color.alphaBlend(Colors.black12, gradientColors[1])
            : gradientColors[1],
        systemNavigationBarIconBrightness:
            isConnected ? Brightness.light : null,
      ),
      child: Scaffold(
        backgroundColor: gradientColors[1],
        body: Stack(
          children: [
            Container(
              height:
                  MediaQuery.of(context).size.height * (animation.value / 100),
              color: gradientColors[0],
            ),
            Transform.translate(
              offset: const Offset(0, 0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: Container(color: Colors.white.withOpacity(0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
