import 'package:deliver_flutter/box/room.dart';
import 'package:hive/hive.dart';

abstract class RoomDao {
  Future<void> saveRoom(Room room);

  Future<void> updateRoom(Room room);

  Future<void> deleteRoom(Room room);

  Future<List<Room>> getAllRooms();

  Stream<List<Room>> watchAllRooms();

  Future<Room> getRoom(String roomUid);

  Stream<Room> watchRoom(String roomUid);
}

class RoomDaoImpl implements RoomDao {
  @override
  Future<void> deleteRoom(Room room) async {
    var box = await _openRoom();

    box.delete(room.uid);
  }

  @override
  Future<List<Room>> getAllRooms() async {
    var box = await _openRoom();

    return box.values.toList();
  }

  @override
  Stream<List<Room>> watchAllRooms() async* {
    var box = await _openRoom();

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }

  @override
  Future<Room> getRoom(String roomUid) async {
    var box = await _openRoom();

    return box.get(roomUid);
  }

  @override
  Future<void> saveRoom(Room room) async {
    var box = await _openRoom();

    return box.put(room.uid, room);
  }

  @override
  Future<void> updateRoom(Room room) {
    // TODO: implement updateRoom
    throw UnimplementedError();
  }

  @override
  Stream<Room> watchRoom(String roomUid) async* {
    var box = await _openRoom();

    yield box.get(roomUid);

    yield* box.watch(key: roomUid).map((event) => box.get(roomUid));
  }

  static String _keyRoom() => "room";

  static Future<Box<Room>> _openRoom() => Hive.openBox<Room>(_keyRoom());
}
