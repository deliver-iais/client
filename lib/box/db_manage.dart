import 'package:hive/hive.dart';

class DBManager {
  Future<void> deleteDB() async {
    // TODO - read all files in db directory with *.hive pattern and open it, then call delete

    await Hive.deleteFromDisk();
  }

  Future<void> migrate(String previousVersion) {}
}
