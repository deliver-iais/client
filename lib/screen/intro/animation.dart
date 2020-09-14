import 'dart:math';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';

/// [FlareControls] is a concrete implementation of the [FlareController].
///
/// This controller will provide some basic functionality, such as
/// playing an animation, and advancing every frame. If multiple animations are
/// playing at the same time, this controller will mix them.
class IntroAnimationController extends FlareController {
  /// The current [FlutterActorArtboard].
  FlutterActorArtboard _artboard;

  /// The current [ActorAnimation].
  String _animationName = "Steps";
  final double _mixSeconds = 0.1;

  /// The [FlareAnimationLayer]s currently active.
  FlareAnimationLayer _animationLayers;
  double pauseTime = 0;
  double direction = 1;

  /// Called at initialization time, it stores the reference
  /// to the current [FlutterActorArtboard].
  @override
  void initialize(FlutterActorArtboard artboard) {
    _artboard = artboard;
    if (_animationName != null && _artboard != null) {
      ActorAnimation animation = _artboard.getAnimation(_animationName);
      if (animation != null) {
        _animationLayers = FlareAnimationLayer()
          ..name = _animationName
          ..animation = animation
          ..mix = 1;
      }
    }
  }

  void play({double pauseTime = 1}) {
    if (_animationLayers != null) {
      this.pauseTime = pauseTime > _animationLayers.duration
          ? _animationLayers.duration
          : pauseTime < 0 ? 0 : pauseTime;
      if (pauseTime > _animationLayers.time) {
        direction = 1;
      } else {
        direction = -1;
      }
      isActive.value = true;
    }
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  /// Advance all the [FlareAnimationLayer]s that are currently controlled
  /// by this object, and mixes them accordingly.
  ///
  /// If an animation completes during the current frame (and doesn't loop),
  /// the [onCompleted()] callback will be triggered.
  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    /// This loop will mix all the currently active animation layers so that,
    /// if an animation is played on top of the current one, it'll smoothly mix
    ///  between the two instead of immediately switching to the new one.
    FlareAnimationLayer layer = _animationLayers;

//    layer.mix += direction * elapsed;
    var speed = direction > 0 ? elapsed * 1.75 : elapsed * 2.5;
    layer.time += direction * speed;

    double mix = (_mixSeconds == null || _mixSeconds == 0.0)
        ? 1.0
        : min(1.0, layer.mix / _mixSeconds);

    /// Loop the time if needed.
    if (layer.animation.isLooping) {
      layer.time %= layer.animation.duration;
    }

    /// Apply the animation with the current mix.
    layer.animation.apply(layer.time, _artboard, mix);

    /// Add (non-looping) finished animations to the list.
    if ((direction > 0 && layer.time >= pauseTime) ||
        (direction < 0 && layer.time <= pauseTime)) {
      return false;
    }

    return true;
  }
}
