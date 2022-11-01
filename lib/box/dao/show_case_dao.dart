import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/show_case.dart';
import 'package:hive/hive.dart';

abstract class ShowCaseDao extends DBManager {
  Future<List<ShowCase>> getAllShowCases();

  Future<ShowCase?> getShowCase(int index);

  Future save(ShowCase showCase);
}

class ShowCaseDaoImpl extends ShowCaseDao {
  @override
  Future<List<ShowCase>> getAllShowCases() async {
    final box = await _open();
    return box.values.toList();
  }

  @override
  Future<void> save(ShowCase showCase) async {
    final box = await _open();
    return box.put(showCase.index, showCase);
  }

  @override
  Future<ShowCase?> getShowCase(
    int index,
  ) async {
    final box = await _open();

    return box.get(index);
  }

  static String _key() => "show-case";

  Future<BoxPlus<ShowCase>> _open() {
    super.open(_key(), SHOW_CASE_TABLE_NAME);
    return gen(Hive.openBox<ShowCase>(_key()));
  }
}
