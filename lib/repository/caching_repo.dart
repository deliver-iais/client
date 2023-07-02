import 'package:dcache/dcache.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
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

  final _roomNameCache = LruCache<String, String>(storage: InMemoryStorage(100));

  final _userIdCache = LruCache<String, String>(storage: InMemoryStorage(100));

  final _realNameCache = LruCache<String, String>(storage: InMemoryStorage(100));

  void clearNamesCache() => _roomNameCache.clear();

  String? getName(Uid uid) => _roomNameCache.get(uid.asString());

  void setName(Uid uid, String name) =>
      _roomNameCache.set(uid.asString(), name);

  void setId(Uid uid, String id) => _userIdCache.set(uid.asString(), id);

  String? getId(Uid uid) => _userIdCache.get(uid.asString());

  void setRealName(Uid uid, String realName) =>
      _realNameCache.set(uid.asString(), realName);

  String? getRealName(Uid uid) => _realNameCache.get(uid.asString());

  final _lastSeenId = LruCache<String, int>(storage: InMemoryStorage(200));

  // Room Page Caching
  void setMessage(Uid roomUid, int id, Message msg) {
    final r = _rooms.get(roomUid);

    if (r == null) {
      final rc = RoomCache();
      rc.message.set(id, msg);
      _rooms.set(roomUid, rc);
    } else {
      r.message.set(id, msg);
    }
  }

  void setMessages(Uid rooUid, List<Message> messages) {
    for (final msg in messages) {
      setMessage(rooUid, msg.id!, msg);
    }
  }

  void setMessageWidget(Uid roomUid, int id, Widget? widget) {
    final r = _rooms.get(roomUid);

    if (r == null) {
      final rc = RoomCache();
      rc.widget.set(id, widget);
      _rooms.set(roomUid, rc);
    } else {
      r.widget.set(id, widget);
    }
  }

  void clearAllMessageWidgetForRoom(
    Uid roomUid,
  ) {
    final r = _rooms.get(roomUid);
    r?.widget.clear();
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
