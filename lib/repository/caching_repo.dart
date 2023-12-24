import 'package:deliver/box/is_verified.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:ecache/ecache.dart';
import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

class RoomCache {
  final message =
      SimpleCache<int, Message>(storage: WeakReferenceStorage(), capacity: 1000);

  final widget =
      SimpleCache<int, Widget?>(storage: WeakReferenceStorage(), capacity: 1);
  final size =
      SimpleCache<int, Size>(storage: WeakReferenceStorage(), capacity: 1000);
}

class CachingRepo {
  final _urlCache = SimpleCache(storage: WeakReferenceStorage(), capacity: 10);
  final _isVerifiedCache = SimpleCache<String, IsVerified>(
      storage: WeakReferenceStorage(), capacity: 40);
  final _rooms =
      SimpleCache<Uid, RoomCache>(storage: WeakReferenceStorage(), capacity: 100);

  final _roomNameCache =
      SimpleCache<String, String>(storage: WeakReferenceStorage(), capacity: 100);

  final _userIdCache =
      SimpleCache<String, String>(storage: WeakReferenceStorage(), capacity: 10);

  final _realNameCache =
      SimpleCache<String, String>(storage: WeakReferenceStorage(), capacity: 10);

  void clearNamesCache() => _roomNameCache.clear();

  Metadata? getUrl(String key) => _urlCache.get(key);

  IsVerified? isVerified(String uid) => _isVerifiedCache.get(uid);

  void setVerified(String uid, IsVerified value) =>
      _isVerifiedCache.set(uid, value);

  void setUrl(String key, Metadata m) => _urlCache.set(key, m);

  String? getName(Uid uid) => _roomNameCache.get(uid.asString());

  void setName(Uid uid, String name) =>
      _roomNameCache.set(uid.asString(), name);

  void setId(Uid uid, String id) => _userIdCache.set(uid.asString(), id);

  String? getId(Uid uid) => _userIdCache.get(uid.asString());

  void setRealName(Uid uid, String realName) =>
      _realNameCache.set(uid.asString(), realName);

  String? getRealName(Uid uid) => _realNameCache.get(uid.asString());

  final _lastSeenId =
      SimpleCache<String, int>(storage: WeakReferenceStorage(), capacity: 1);

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
      setMessage(rooUid, msg.localNetworkMessageId!, msg);
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
