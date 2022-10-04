import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/show_case.dart';
import 'package:hive/hive.dart';

abstract class ShowCaseDao {
  Future<List<ShowCase>> getAllShowCases();

  Future<ShowCase?> getShowCase(int index);

  Future save(ShowCase showCase);
}

class ShowCaseDaoImpl implements ShowCaseDao {
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

  static Future<BoxPlus<ShowCase>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<ShowCase>(_key()));
  }
}
