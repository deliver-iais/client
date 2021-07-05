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
  Future<void> deleteRoom(Room room) {
    // TODO: implement deleteRoom
    throw UnimplementedError();
  }

  @override
  Future<List<Room>> getAllRooms() {
    // TODO: implement getAllRooms
    throw UnimplementedError();
  }

  @override
  Stream<List<Room>> watchAllRooms() {
    // TODO: implement getAllRooms
    throw UnimplementedError();
  }

  @override
  Future<Room> getRoom(String roomUid) {
    // TODO: implement getRoom
    throw UnimplementedError();
  }

  @override
  Future<void> saveRoom(Room room) {
    // TODO: implement saveRoom
    throw UnimplementedError();
  }

  @override
  Future<void> updateRoom(Room room) {
    // TODO: implement updateRoom
    throw UnimplementedError();
  }

  @override
  Stream<Room> watchRoom(String roomUid) {
    // TODO: implement watchRoom
    throw UnimplementedError();
  }


  static String _keyRoom() => "room";

  static Future<Box<Room>> _openRoom() => Hive.openBox<Room>(_keyRoom());
}
