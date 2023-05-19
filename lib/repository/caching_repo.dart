import 'package:dcache/dcache.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

// TODO(bitbeter): add some dynamic storage size instead of 1000 based on devise available memory if it is possible
class RoomCache {
  final message = LruCache<int, Message>(storage: InMemoryStorage(1000));

  // TODO(bitbeter): bug exists in here
  final widget = LruCache<int, Widget?>(storage: InMemoryStorage(0));
  final size = LruCache<int, Size>(storage: InMemoryStorage(1000));
}

class CachingRepo {
  final _rooms = LruCache<Uid, RoomCache>(storage: InMemoryStorage(10));

  final _lastSeenId = LruCache<String, int>(storage: InMemoryStorage(200));

  // Room Page Caching
  void setMessage(Uid roomId, int id, Message msg) {
    final r = _rooms.get(roomId);

    if (r == null) {
      final rc = RoomCache();
      rc.message.set(id, msg);
      _rooms.set(roomId, rc);
    } else {
      r.message.set(id, msg);
    }
  }

  void setMessageWidget(Uid roomUid, int id, Widget? widget) {
    final r = _rooms.get(roomUid);

    if (r == null) {
      final rc = RoomCache();
      // TODO(bitbeter): bug exists in here
      // rc.widget.set(id, widget);
      _rooms.set(roomUid, rc);
    } else {
      // TODO(bitbeter): bug exists in here
      // r.widget.set(id, widget);
    }
  }

  void setMessageDimensionsSize(Uid roomId, int id, Size size) {
    final r = _rooms.get(roomId);

    if (r == null) {
      final rc = RoomCache();
      rc.size.set(id, size);
      _rooms.set(roomId, rc);
    } else {
      r.size.set(id, size);
    }
  }

  Widget? getMessageWidget(Uid roomId, int id) {
    final r = _rooms.get(roomId);
    if (r == null) {
      return null;
    } else {
      return r.widget.get(id);
    }
  }

  Message? getMessage(Uid roomId, int id) {
    final r = _rooms.get(roomId);
    if (r == null) {
      return null;
    } else {
      return r.message.get(id);
    }
  }

  Size? getMessageDimensionsSize(Uid roomId, int id) {
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
