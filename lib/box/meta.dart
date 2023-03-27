import 'package:collection/collection.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'meta.g.dart';

@HiveType(typeId: META_TRACK_ID)
class Meta {
  // DbId
  @HiveField(0)
  int createdOn;

  @HiveField(1)
  String createdBy;

  @HiveField(2)
  String json;

  @HiveField(3)
  String roomId;

  @HiveField(4)
  int messageId;

  @HiveField(5)
  MetaType type;

  @HiveField(6)
  int index;

  Meta({
    required this.createdOn,
    required this.json,
    required this.roomId,
    required this.messageId,
    required this.type,
    required this.createdBy,
    required this.index,
  });

  Meta copyDeleted() => copyWith(
        json: EMPTY_MESSAGE,
      );

  bool isDeletedMeta() => json == EMPTY_MESSAGE;

  Meta copyWith({
    int? createdOn,
    String? createdBy,
    String? json,
    String? roomId,
    int? index,
    int? messageId,
    MetaType? type,
  }) =>
      Meta(
        createdOn: createdOn ?? this.createdOn,
        createdBy: createdBy ?? this.createdBy,
        json: json ?? this.json,
        roomId: roomId ?? this.roomId,
        index: index ?? this.index,
        messageId: messageId ?? this.messageId,
        type: type ?? this.type,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is Meta &&
          const DeepCollectionEquality().equals(other.createdOn, createdOn) &&
          const DeepCollectionEquality().equals(other.json, json) &&
          const DeepCollectionEquality().equals(other.roomId, roomId) &&
          const DeepCollectionEquality().equals(other.messageId, messageId) &&
          const DeepCollectionEquality().equals(other.type, type) &&
          const DeepCollectionEquality().equals(other.createdBy, createdBy) &&
          const DeepCollectionEquality().equals(other.index, index));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(createdOn),
        const DeepCollectionEquality().hash(json),
        const DeepCollectionEquality().hash(roomId),
        const DeepCollectionEquality().hash(messageId),
        const DeepCollectionEquality().hash(type),
        const DeepCollectionEquality().hash(createdBy),
        const DeepCollectionEquality().hash(index),
      );

  @override
  String toString() {
    return "index $index and message id $messageId";
  }
}
