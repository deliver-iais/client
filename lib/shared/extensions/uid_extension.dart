import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

const UidJsonKey = JsonKey(fromJson: uidFromJson, toJson: uidToJson);

const NullableUidJsonKey =
    JsonKey(fromJson: nullAbleUidFromJson, toJson: nullableUidToJson);

Uid uidFromJson(String json) {
  return Uid.fromJson(json);
}

Uid? nullAbleUidFromJson(String? json) {
  return json != null ? Uid.fromJson(json) : null;
}

String uidToJson(Uid protobufModel) {
  return protobufModel.writeToJson();
}

String? nullableUidToJson(Uid? protobufModel) {
  return protobufModel?.writeToJson();
}

extension UidExtension on Uid {
  bool isSameEntity(String entityString) {
    final list = entityString.split(":");
    if (list.length != 2) {
      return false;
    } else {
      return category.value == int.parse(list[0]) && node == list[1];
    }
  }

  MucCategories asMucCategories() {
    switch (category) {
      case Categories.BROADCAST:
        return MucCategories.BROADCAST;
      case Categories.CHANNEL:
        return MucCategories.CHANNEL;
      case Categories.GROUP:
        return MucCategories.GROUP;
      case Categories.BOT:
      case Categories.STORE:
      case Categories.SYSTEM:
      case Categories.USER:
        return MucCategories.NONE;
    }
    return MucCategories.NONE;
  }

  String asString() => "${category.value}:$node";

  String asStringWithSession() => "${category.value}:$node:$sessionId";

  bool isUser() => category == Categories.USER;

  bool isBot() => category == Categories.BOT;

  bool isGroup() => category == Categories.GROUP;

  bool isChannel() => category == Categories.CHANNEL;

  bool isBroadcast() => category == Categories.BROADCAST;

  bool isSystem() => category == Categories.SYSTEM;

  bool isMuc() => isGroup() || isChannel() || isBroadcast();

  bool isPrivateBaseMuc() => isChannel() || isBroadcast();

  bool isEqual(Uid uid) => asString() == uid.asString();
}

const String _ALL_SESSIONS = "*";

extension StringUidExtension on String {
  bool isSameEntity(Uid uid) {
    final list = split(":");
    if (list.length != 2) {
      return false;
    } else {
      return uid.category.value == int.parse(list[0]) && uid.node == list[1];
    }
  }

  Uid asUid() {
    final list = split(":");
    if (list.length != 2) {
      throw AssertionError("Uid is incorrect");
    } else {
      return Uid()
        ..category = Categories.valueOf(int.parse(list[0]))!
        ..node = list[1]
        ..sessionId = _ALL_SESSIONS;
    }
  }

  Uid asUidWithSession() {
    final list = split(":");
    if (list.length != 3) {
      throw AssertionError("Uid is incorrect");
    } else {
      return Uid()
        ..category = Categories.valueOf(int.parse(list[0]))!
        ..node = list[1]
        ..sessionId = list[2];
    }
  }

  bool isUser() => asUid().isUser();

  bool isBot() => asUid().isBot();

  bool isGroup() => asUid().isGroup();

  bool isChannel() => asUid().isChannel();

  bool isBroadcast() => asUid().isBroadcast();

  bool isSystem() => asUid().isSystem();

  bool isMuc() => isGroup() || isChannel() || isBroadcast();
}
