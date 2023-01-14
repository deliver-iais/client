import 'package:deliver/shared/methods/platform.dart';
import 'package:vibration/vibration.dart';

Future<void> vibrate({
  int duration = 500,
  List<int> pattern = const [],
  int repeat = -1,
  List<int> intensities = const [],
  int amplitude = -1,
}) async {
  if (hasVibrationCapability && (await Vibration.hasVibrator() ?? false)) {
    return Vibration.vibrate(
      duration: duration,
      pattern: pattern,
      repeat: repeat,
      intensities: intensities,
      amplitude: amplitude,
    );
  }
}

Future<void> cancelVibration() {
  return Vibration.cancel();
}

void quickVibrate() {
  if (isAndroid) vibrate(duration: 100).ignore();
}
