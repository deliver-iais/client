import 'package:deliver/models/call_timer.dart';
import 'package:rxdart/rxdart.dart';

class EventService {
  BehaviorSubject<CountTimer> eventTimer =
      BehaviorSubject.seeded(CountTimer(0, 0, 0));

  final BehaviorSubject<CountTimer> _eventTimer =
      BehaviorSubject.seeded(CountTimer(0, 0, 0));

  EventService() {
    _eventTimer.distinct().listen((event) {
      eventTimer.add(event);
    });
  }

  void addCountTimer(CountTimer countTimer) {
    _eventTimer.add(countTimer);
  }

  Stream<CountTimer> getEventTimerStream() {
    return eventTimer.stream;
  }
}
