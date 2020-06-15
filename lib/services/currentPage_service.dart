import 'package:rxdart/rxdart.dart';


class CurrentPageService {
  BehaviorSubject _currentPage = BehaviorSubject.seeded(0);

  get currentPageStream => _currentPage.stream;

  get currentPage => _currentPage.value;

  toggleCurrentPage() {
    if (currentPage == 0) {
      _currentPage.add(1);
    } else {
      _currentPage.add(0);
    }
  }
}
