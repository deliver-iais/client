import 'package:deliver/box/active_notification.dart';
import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class ActiveNotificationDao {
  Future<List<ActiveNotification>> getRoomActiveNotification(String roomUid);

  Future<ActiveNotification?> getActiveNotification(
    String roomUid,
    int messageId,
  );

  Future<void> save(ActiveNotification activeNotification);

  Future<void> removeActiveNotification(String roomUid, int messageId);

  Future<void> removeRoomActiveNotification(String roomUid);

  Future<void> removeAllActiveNotification();
}

class ActiveNotificationDaoImpl implements ActiveNotificationDao {
  @override
  Future<ActiveNotification?> getActiveNotification(
    String roomUid,
    int messageId,
  ) async {
    final box = await _open(roomUid);
    return box.get(messageId);
  }

  @override
  Future<List<ActiveNotification>> getRoomActiveNotification(
    String roomUid,
  ) async {
    final box = await _open(roomUid);
    return sorted(box.values.toList());
  }

  @override
  Future<void> removeActiveNotification(String roomUid, int messageId) async {
    final box = await _open(roomUid);
    return box.delete(messageId);
  }

  @override
  Future<void> removeRoomActiveNotification(String roomUid) async {
    final box = await _open(roomUid);
    await box.clear();
  }

  @override
  Future<void> save(ActiveNotification activeNotification) async {
    final box = await _open(activeNotification.roomUid);
    return box.put(activeNotification.messageId, activeNotification);
  }

  static String _key(String roomUid) => "active-notification-$roomUid";

  static Future<BoxPlus<ActiveNotification>> _open(String uid) {
    BoxInfo.addBox(_key(uid.replaceAll(":", "-")));
    return gen(
      Hive.openBox<ActiveNotification>(_key(uid.replaceAll(":", "-"))),
    );
  }

  @override
  Future<void> removeAllActiveNotification() async {
    final box = await Hive.openBox<String>("box_info");
    box.values.toList().forEach((key) async {
      if (key.contains("active-notification")) {
        await BoxInfo.deleteBox(key);
      }
    });
  }

  List<ActiveNotification> sorted(List<ActiveNotification> list) {
    list.sort((a, b) => (a.messageId) - (b.messageId));
    return list;
  }
}
