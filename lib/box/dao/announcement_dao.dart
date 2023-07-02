import 'package:deliver/box/announcement.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/announcement.pbenum.dart';
import 'package:hive/hive.dart';

abstract class AnnouncementDao {
  Stream<List<Announcements>> getAllAnnouncements();

  Stream<Announcements?> getAnnouncement(int index);

  Stream<List<Announcements>> getFatalAnnouncements();

  Future save(Announcements announcement);

  Future saveTime(int time);

  Future<int?> getTime();

  Future clear();
}

class AnnouncementDaoImpl extends AnnouncementDao {
  @override
  Stream<List<Announcements>> getAllAnnouncements() async* {
    final box = await _open();
    yield box.values.toList();

    yield* box.watch().map(
          (event) => box.values.toList(),
        );
  }

  @override
  Future<void> save(Announcements announcement) async {
    final box = await _open();
    await box.put(announcement.index, announcement);
  }

  @override
  Future<void> clear() async {
    final box = await _open();
    await box.clear();
  }

  @override
  Stream<Announcements?> getAnnouncement(
    int index,
  ) async* {
    final box = await _open();

    yield box.get(index);
    yield* box.watch().map((event) {
      return box.get(index);
    });
  }

  @override
  Stream<List<Announcements>> getFatalAnnouncements() async* {
    final box = await _open();
    yield box.values
        .where(
          (element) =>
              element.json.toAnnouncment().severity ==
              AnnouncementSeverity.FATAL,
        )
        .toList();

    yield* box.watch().map(
          (event) => box.values
              .where(
                (element) =>
                    element.json.toAnnouncment().severity ==
                    AnnouncementSeverity.FATAL,
              )
              .toList(),
        );
  }

  @override
  Future<void> saveTime(int time) async {
    final box = await _openAnnouncementTimeDb();
    await box.put(0, time);
  }

  @override
  Future<int?> getTime() async {
    final box = await _openAnnouncementTimeDb();
    final lastModifiedTime = box.get(0);
    return lastModifiedTime ?? 0;
  }

  static String _key() => "Announcement";

  static String _keyTime() => "AnnouncementTime";

  Future<BoxPlus<Announcements>> _open() {
    DBManager.open(_key(), TableInfo.ANNOUNCMENT_TABLE_NAME);
    return gen(Hive.openBox<Announcements>(_key()));
  }

  Future<BoxPlus<int>> _openAnnouncementTimeDb() {
    DBManager.open(_key(), TableInfo.ANNOUNCMENT_TIME_TABLE_NAME);
    return gen(Hive.openBox<int>(_keyTime()));
  }
}
