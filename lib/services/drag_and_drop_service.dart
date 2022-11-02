import 'package:rxdart/rxdart.dart';

class DragAndDropService {
  final _isDragEnable = BehaviorSubject.seeded(true);

  BehaviorSubject<bool> get isDragEnable => _isDragEnable;

  void enableDrag() {
    _isDragEnable.add(true);
  }

  void disableDrag() {
    _isDragEnable.add(false);
  }
}
