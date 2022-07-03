import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

extension UidExtension on Uid {
  bool isSameEntity(String entityString) {
    final list = entityString.split(":");
    if (list.length != 2) {
      return false;
    } else {
      return category.value == int.parse(list[0]) && node == list[1];
    }
  }

  String asString() => "${category.value}:$node";

  bool isUser() => category == Categories.USER;

  bool isBot() => category == Categories.BOT;

  bool isGroup() => category == Categories.GROUP;

  bool isChannel() => category == Categories.CHANNEL;

  bool isSystem() => category == Categories.SYSTEM;

  bool isMuc() => isGroup() || isChannel();

  bool isEqual(Uid uid) => asString() == uid.asString();
}

// ignore: constant_identifier_names
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

  bool isUser() => asUid().isUser();

  bool isBot() => asUid().isBot();

  bool isGroup() => asUid().isGroup();

  bool isChannel() => asUid().isChannel();

  bool isSystem() => asUid().isSystem();

  bool isMuc() => isGroup() || isChannel();
}
