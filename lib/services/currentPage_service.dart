import 'package:rxdart/rxdart.dart';

class CurrentPageService {
  BehaviorSubject _currentPage = BehaviorSubject.seeded(-1);

  get currentPageStream => _currentPage.stream;

  get currentPage => _currentPage.value;

  resetPage() => _currentPage.add(-1);

  setToHome() => _currentPage.add(0);

  toggleCurrentPage() {
    if (currentPage == 0) {
      _currentPage.add(1);
    } else {
      _currentPage.add(0);
    }
  }
}
