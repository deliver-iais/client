import 'dart:math';

import 'package:flutter/material.dart';

class AnimationWaveButton extends StatefulWidget {
  final bool initialIsPlaying;
  final Icon playIcon;
  final Icon pauseIcon;

  const AnimationWaveButton({
    Key? key,
    this.initialIsPlaying = false,
    this.playIcon = const Icon(Icons.mic),
    this.pauseIcon = const Icon(Icons.pause),
  }) : super(key: key);

  @override
  AnimationWaveButtonState createState() => AnimationWaveButtonState();
}

class AnimationWaveButtonState extends State<AnimationWaveButton>
    with TickerProviderStateMixin {
  static const _kToggleDuration = Duration(milliseconds: 300);
  static const _kRotationDuration = Duration(seconds: 5);

  late bool isPlaying;

  // rotation and scale animations
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  double _rotation = 0;
  double _scale = 1;

  void _updateRotation() => _rotation = _rotationController.value * 2 * pi;

  void _updateScale() => _scale = (_scaleController.value * 0.2) + 1;

  @override
  void initState() {
    isPlaying = widget.initialIsPlaying;
    _rotationController =
        AnimationController(vsync: this, duration: _kRotationDuration)
          ..addListener(() => setState(_updateRotation))
          ..repeat();

    _scaleController =
        AnimationController(vsync: this, duration: _kToggleDuration)
          ..addListener(() => setState(_updateScale));
    _scaleController.forward();
    super.initState();
  }

  void _onToggle() {
    setState(
      () => isPlaying = !isPlaying,
    );
    _scaleController.forward();
  }

  Widget _buildIcon(bool isPlaying) {
    return SizedBox.expand(
      key: ValueKey<bool>(isPlaying),
      child: IconButton(
        icon: isPlaying ? widget.playIcon : widget.pauseIcon,
        onPressed: _onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isPlaying) ...[
            Blob(
              color: theme.primaryColor.withOpacity(0.5),
              scale: _scale,
              rotation: _rotation,
            ),
            Blob(
              color: theme.primaryColor.withOpacity(0.3),
              scale: _scale,
              rotation: _rotation * 2 - 30,
            ),
            Blob(
              color: theme.primaryColor.withOpacity(0.2),
              scale: _scale,
              rotation: _rotation * 3 - 45,
            ),
          ],
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.primaryColorLight,
                  theme.primaryColor,
                ],
              ),
            ),
            child: AnimatedSwitcher(
              duration: _kToggleDuration,
              child: _buildIcon(isPlaying),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
}

class Blob extends StatelessWidget {
  final double rotation;
  final double scale;
  final Color color;

  const Blob({Key? key, required this.color, this.rotation = 0, this.scale = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(150),
              topRight: Radius.circular(240),
              bottomLeft: Radius.circular(220),
              bottomRight: Radius.circular(180),
            ),
          ),
        ),
      ),
    );
  }
}
