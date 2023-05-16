import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

part 'room_isar.g.dart';

@collection
class RoomIsar {
  Id get id => fastHash(uid);

  String uid;

  String? lastMessage;

  bool deleted;

  int lastMessageId;

  String? draft;

  int lastUpdateTime;

  int firstMessageId;

  bool pinned;

  int pinId;

  bool synced;

  int lastCurrentUserSentMessageId;

  bool seenSynced;

  String? replyKeyboardMarkup;

  List<int>? mentionsId;

  bool shouldUpdateMediaCount;

  RoomIsar({
    required this.uid,
    this.lastMessage,
    this.deleted = false,
    this.lastMessageId = 0,
    this.draft,
    this.lastUpdateTime = 0,
    this.firstMessageId = 0,
    this.pinned = false,
    this.pinId = 0,
    this.synced = false,
    this.lastCurrentUserSentMessageId = 0,
    this.seenSynced = false,
    this.replyKeyboardMarkup,
    this.mentionsId,
    this.shouldUpdateMediaCount = false,
  });

  Room fromIsar() => Room(
        uid: uid.asUid(),
        lastMessage:
            lastMessage != null ? getMessageFromJson(lastMessage!) : null,
        deleted: deleted,
        lastMessageId: lastMessageId,
        firstMessageId: firstMessageId,
        draft: draft ?? "",
        lastUpdateTime: lastUpdateTime,
        pinId: pinId,
        pinned: pinned,
        synced: synced,
        seenSynced: seenSynced,
        shouldUpdateMediaCount: shouldUpdateMediaCount,
        mentionsId: mentionsId ?? [],
        replyKeyboardMarkup: replyKeyboardMarkup,
        lastCurrentUserSentMessageId: lastCurrentUserSentMessageId,
      );
}

extension RoomIsarMapper on Room {
  RoomIsar toIsar() => RoomIsar(
        uid: uid.asString(),
        lastMessage: lastMessage?.toJson(),
        deleted: deleted,
        draft: draft,
        seenSynced: seenSynced,
        shouldUpdateMediaCount: shouldUpdateMediaCount,
        synced: synced,
        lastUpdateTime: lastUpdateTime,
        lastMessageId: lastMessageId,
        lastCurrentUserSentMessageId: lastCurrentUserSentMessageId,
        firstMessageId: firstMessageId,
        pinned: pinned,
        pinId: pinId,
        replyKeyboardMarkup: replyKeyboardMarkup,
        mentionsId: mentionsId,
      );
}
