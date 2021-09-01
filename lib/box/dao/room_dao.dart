import 'package:we/box/room.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:hive/hive.dart';
import 'package:we/shared/extensions/uid_extension.dart';

abstract class RoomDao {
  Future<void> updateRoom(Room room);

  Future<void> deleteRoom(Room room);

  Future<List<Room>> getAllRooms();

  Stream<List<Room>> watchAllRooms();

  Future<Room> getRoom(String roomUid);

  Stream<Room> watchRoom(String roomUid);

  Future<List<Room>> getAllGroups();
}

class RoomDaoImpl implements RoomDao {
  @override
  Future<void> deleteRoom(Room room) async {
    var box = await _openRoom();

    box.delete(room.uid);
  }

  @override
  Future<List<Room>> getAllRooms() async {
    try {
      var box = await _openRoom();

      return sorted(
          box.values.where((element) => element.lastMessage != null).toList());
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<Room>> watchAllRooms() async* {
    var box = await _openRoom();

    yield sorted(
        box.values.where((element) => element.lastMessage != null).toList());

    yield* box.watch().map((event) => sorted(box.values
        .where((element) =>
            element.lastMessage != null &&
            (element.deleted == null || element.deleted == false))
        .toList()));
  }

  List<Room> sorted(List<Room> list) {
    var l = list;

    l.sort((a, b) => (b.lastMessage?.time ?? 0) - (a.lastMessage?.time ?? 0));

    return l;
  }

  @override
  Future<Room> getRoom(String roomUid) async {
    var box = await _openRoom();

    return box.get(roomUid);
  }

  @override
  Future<void> updateRoom(Room room) async {
    var box = await _openRoom();

    if (room != null && room.lastMessage != null) {
      room = room.copyWith(lastMessageId: room.lastMessage.id);
    }

    var r = box.get(room.uid) ?? room;

    return box.put(room.uid, r.copy(room));
  }

  @override
  Stream<Room> watchRoom(String roomUid) async* {
    var box = await _openRoom();

    yield box.get(roomUid);

    yield* box.watch(key: roomUid).map((event) => box.get(roomUid));
  }

  static String _keyRoom() => "room";

  static Future<Box<Room>> _openRoom() async {
    try {
      return await Hive.openBox<Room>(_keyRoom());
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyRoom());
      return await Hive.openBox<Room>(_keyRoom());
    }
  }

  @override
  Future<List<Room>> getAllGroups() async {
    var box = await _openRoom();
    return box.values
        .where((element) =>
            element.uid.asUid().category == Categories.GROUP &&
            (element.deleted == null || element.deleted != true))
        .toList();
  }
}
