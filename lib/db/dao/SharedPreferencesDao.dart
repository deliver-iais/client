import 'package:deliver_flutter/db/SharedPreferences.dart';
import 'package:moor/moor.dart';
import '../database.dart';

part 'SharedPreferencesDao.g.dart';

@UseDao(tables: [SharedPreferences])
class SharedPreferencesDao extends DatabaseAccessor<Database>
    with _$SharedPreferencesDaoMixin {
  final Database database;

  SharedPreferencesDao(this.database) : super(database);

  Future<int> set(String key, String value) => into(sharedPreferences)
      .insertOnConflictUpdate(SharedPreference(key: key, value: value));

  Future<String> get(String key) async =>
      (await (select(sharedPreferences)..where((sh) => sh.key.equals(key)))
              .getSingleOrNull())
          ?.value ??
      null;

  Stream<SharedPreference> watch(String key) =>
      ((select(sharedPreferences)..where((sh) => sh.key.equals(key)))
          .watchSingleOrNull());
}
