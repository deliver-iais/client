import 'dart:async';
import 'dart:math';

final _randomVmKey = Object();

RandomVM get randomVM =>
    Zone.current[_randomVmKey] as RandomVM? ?? const RandomVM();

T withRandomVM<T>(RandomVM randomVM, T Function() callback) {
  return runZoned(callback, zoneValues: {_randomVmKey: randomVM});
}

int getRandomSeed(int randomSize) =>
    Random(DateTime.now().millisecondsSinceEpoch).nextInt(randomSize);

class RandomVM {
  final int Function(int) _random;

  const RandomVM([int Function(int) random = getRandomSeed]) : _random = random;

  RandomVM.fixed(int rnd) : _random = ((_) => rnd);

  int nextInt(int randomSize) => _random(randomSize);
}
