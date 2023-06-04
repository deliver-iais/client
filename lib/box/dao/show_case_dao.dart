import 'dart:math';

import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/show_case.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

abstract class ShowCaseDao {
  Future<(List<ShowCase>, bool)> getShowCasePage(
    int page, {
    int pageSize = SHOWCASE_PAGE_SIZE,
  });

  Future<ShowCase?> getShowCase(int index);

  Future save(ShowCase showCase);

  Future clearAllShowcase();

  Future<void> saveShowcaseModifyTime(int pageNum, int modifyTime);

  Future<int?> getShowcaseModifyTime(int pageNum);
}

class ShowCaseDaoImpl extends ShowCaseDao {
  @override
  Future<(List<ShowCase>, bool)> getShowCasePage(
    int page, {
    int pageSize = SHOWCASE_PAGE_SIZE,
  }) async {
    final box = await _openShowcaseTable();
    final showcaseList = Iterable<int>.generate(pageSize + 1)
        .map((e) => page * pageSize + e)
        .map((e) => box.get(e))
        .where((element) => element != null)
        .map((element) => element!)
        .toList();
    return (
      showcaseList.sublist(0, min(pageSize, showcaseList.length)),
      showcaseList.length == min(pageSize, showcaseList.length)
    );
  }

  @override
  Future<void> save(ShowCase showCase) async {
    final box = await _openShowcaseTable();
    return box.put(showCase.index, showCase);
  }

  @override
  Future<ShowCase?> getShowCase(
    int index,
  ) async {
    final box = await _openShowcaseTable();

    return box.get(index);
  }

  static String _showcaseTableKey() => "show-case";

  static String _showcaseModifyTime() => "show-case-modify-time";

  Future<BoxPlus<ShowCase>> _openShowcaseTable() {
    DBManager.open(_showcaseTableKey(), TableInfo.SHOW_CASE_TABLE_NAME);
    return gen(Hive.openBox<ShowCase>(_showcaseTableKey()));
  }

  Future<BoxPlus<int>> _openShowcaseModifyTime() {
    DBManager.open(
      _showcaseTableKey(),
      TableInfo.SHOW_CASE_MODIFY_TIME_TABLE_NAME,
    );
    return gen(Hive.openBox<int>(_showcaseModifyTime()));
  }

  @override
  Future<int?> getShowcaseModifyTime(int pageNum) async {
    final box = await _openShowcaseModifyTime();
    return box.get(pageNum);
  }

  @override
  Future<void> saveShowcaseModifyTime(int pageNum, int modifyTime) async {
    final box = await _openShowcaseModifyTime();
    return box.put(pageNum, modifyTime);
  }

  @override
  Future clearAllShowcase() async {
    final box = await _openShowcaseTable();

    await box.clear();
  }
}
