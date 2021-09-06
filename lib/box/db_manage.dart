import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' if (dart.library.html) ""
    as path_helper;

class DBManager {
  Future<void> deleteDB() async {
    // TODO - read all files in db directory with *.hive pattern and open it, then call delete
    try {
      await Hive.deleteFromDisk();
    } catch (e) {}

    var documentPath = await getApplicationDocumentsDirectory();
//todo database dir
    var myDir = Directory("web");
    // myDir
    //     .list()
    //     .where((file) => !file.path.endsWith(".lock"))
    //     .map((file) => file.path)
    //     .map((path) => path.replaceAll(".hive", ""))
    //     .map((path) => path_helper.basename(path))
    //     .forEach((db) async {
    //   try {
    //     await Hive.deleteBoxFromDisk(db);
    //   } catch (e) {
    //     print("########" + e.toString());
    //   }
    // });
  }

  Future<void> migrate(String previousVersion) async {}
}
