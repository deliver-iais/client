import 'package:dcache/dcache.dart';
import 'package:deliver/box/message.dart';
import 'package:flutter/material.dart';

// TODO(bitbeter): add some dynamic storage size instead of 1000 based on devise available memory if it is possible
class RoomCache {
  final message = LruCache<int, Message>(storage: InMemoryStorage(1000));
  final widget = LruCache<int, Widget?>(storage: InMemoryStorage(0));
  final size = LruCache<int, Size>(storage: InMemoryStorage(1000));
}

class CachingRepo {
  final _rooms = LruCache<String, RoomCache>(storage: InMemoryStorage(10));

  final _lastSeenId = LruCache<String, int>(storage: InMemoryStorage(200));

  // Room Page Caching
  void setMessage(String roomId, int id, Message msg) {
    final r = _rooms.get(roomId);

    if (r == null) {
      final rc = RoomCache();
      rc.message.set(id, msg);
      _rooms.set(roomId, rc);
    } else {
      r.message.set(id, msg);
    }
  }

  void setMessageDimensionsSize(String roomId, int id, Size size) {
    final r = _rooms.get(roomId);

    if (r == null) {
      final rc = RoomCache();
      rc.size.set(id, size);
      _rooms.set(roomId, rc);
    } else {
      r.size.set(id, size);
    }
  }

  Message? getMessage(String roomId, int id) {
    final r = _rooms.get(roomId);
    if (r == null) {
      return null;
    } else {
      return r.message.get(id);
    }
  }

  Size? getMessageDimensionsSize(String roomId, int id) {
    final r = _rooms.get(roomId);
    if (r == null) {
      return null;
    } else {
      return r.size.get(id);
    }
  }

  // Last Seen
  void setLastSeenId(String roomId, int id) {
    final lsi = _lastSeenId.get(roomId);

    if (id > (lsi ?? -1)) {
      _lastSeenId.set(roomId, id);
    }
  }

  int? getLastSeenId(String roomId) {
    return _lastSeenId.get(roomId);
  }
}
