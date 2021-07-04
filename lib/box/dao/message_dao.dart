import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/pending_message.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:hive/hive.dart';

abstract class MessageDao {
  Future<void> saveMessage(Message message);

  Future<void> deleteMessage(Message message);

  Future<Message> getMessage(String roomUid, int id);

  Future<List<Message>> getMessagePage(String roomUid, int page,
      {int pageSize = 40});

  // Pending Messages
  Future<List<PendingMessage>> getPendingMessages(String roomUid);

  Future<PendingMessage> getPendingMessage(String roomUid, String packetId);

  Stream<PendingMessage> watchPendingMessage(String roomUid, String packetId);

  Future<List<PendingMessage>> getAllPendingMessages();

  Future<void> deletePendingMessage(String packetId);

  Future<void> savePendingMessage(PendingMessage pm);

  // Room Metadata
  Future<void> saveRoom(Room room);

  Future<void> updateRoom(Room room);

  Future<void> deleteRoom(Room room);

  Future<List<Room>> getAllRooms();

  Stream<List<Room>> watchAllRooms();

  Future<Room> getRoom(String roomUid);

  Stream<Room> watchRoom(String roomUid);
}

class MessageDaoImpl implements MessageDao {
  Future<void> deleteMessage(Message message) async {
    var box = await _openMessages(message.roomUid);

    box.delete(message.id);
  }

  Future<void> deletePendingMessage(String packetId) async {
    var box = await _openPending();

    box.delete(packetId);
  }

  Future<Message> getMessage(String roomUid, int id) async {
    var box = await _openMessages(roomUid);

    return box.get(id);
  }

  Future<List<PendingMessage>> getAllPendingMessages() async {
    // TODO: implement getAllPendingMessages
    throw UnimplementedError();
  }

  Future<List<Message>> getMessagePage(String roomUid, int page,
      {int pageSize = 40}) async {
    // TODO: implement getPage
    throw UnimplementedError();
  }

  Future<List<PendingMessage>> getPendingMessages(String roomUid) async {
    // TODO: implement getPendingMessages
    throw UnimplementedError();
  }

  Future<PendingMessage> getPendingMessage(
      String roomUid, String packetId) async {
    // TODO: implement getPendingMessages
    throw UnimplementedError();
  }

  Stream<PendingMessage> watchPendingMessage(
      String roomUid, String packetId) async* {
    // TODO: implement getPendingMessages
    throw UnimplementedError();
  }

  Future<void> saveMessage(Message message) async {
    var box = await _openMessages(message.roomUid);

    box.put(message.id, message);
  }

  Future<void> savePendingMessage(PendingMessage pm) async {
    var box = await _openPending();

    box.put(pm.packetId, pm);
  }

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

  static String _keyMessages(String uid) => "message-$uid";

  static String _keyRoom() => "room";

  static String _keyPending() => "pending";

  static Future<Box<Message>> _openMessages(String uid) =>
      Hive.openBox<Message>(_keyMessages(uid));

  static Future<Box<PendingMessage>> _openPending() =>
      Hive.openBox<PendingMessage>(_keyPending());

  static Future<Box<Room>> _openRoom() => Hive.openBox<Room>(_keyRoom());
}
