import 'package:deliver/services/settings.dart';

class AnimationSettings {
  static Duration? get animationOverrideDuration =>
      !settings.showAnimations.value ? const Duration(milliseconds: 1) : null;

  static Duration get fast => animationOverrideDuration ?? actualFast;

  static Duration get normal => animationOverrideDuration ?? actualNormal;

  static Duration get slow => animationOverrideDuration ?? actualSlow;

  static Duration get standard => animationOverrideDuration ?? actualStandard;

  static Duration get verySlow => animationOverrideDuration ?? actualVerySlow;

  static Duration get superSlow => animationOverrideDuration ?? actualSuperSlow;

  static Duration get ultraSlow => animationOverrideDuration ?? actualUltraSlow;

  static Duration get superUltraSlow =>
      animationOverrideDuration ?? actualSuperUltraSlow;

  static const Duration actualFast = Duration(milliseconds: 50);

  static const Duration actualNormal = Duration(milliseconds: 100);

  static const Duration actualSlow = Duration(milliseconds: 200);

  static const Duration actualStandard = Duration(milliseconds: 300);

  static const Duration actualVerySlow = Duration(milliseconds: 350);

  static const Duration actualSuperSlow = Duration(milliseconds: 500);

  static const Duration actualUltraSlow = Duration(milliseconds: 750);

  static const Duration actualSuperUltraSlow = Duration(milliseconds: 1000);
}
