import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

extension UidExtension on Uid {
  bool isSameEntity(String entityString) {
    var list = entityString.split(":");
    if (list.length != 2) {
      return false;
    } else {
      return this.category.value == int.parse(list[0]) && this.node == list[1];
    }
  }

  String asString() => "${this.category.value}:${this.node}";

  bool isUser() => this.category == Categories.USER;

  bool isBot() => this.category == Categories.BOT;

  bool isGroup() => this.category == Categories.GROUP;

  bool isChannel() => this.category == Categories.CHANNEL;

  bool isMuc() => this.isGroup() || this.isChannel();
}

const _ALL_SESSIONS = "*";

extension StringUidExtension on String {
  bool isSameEntity(Uid uid) {
    var list = this.split(":");
    if (list.length != 2) {
      return false;
    } else {
      return uid.category.value == int.parse(list[0]) && uid.node == list[1];
    }
  }

  Uid asUid() {
    var list = this.split(":");
    if (list.length != 2) {
      throw AssertionError("Uid is incorrect");
    } else {
      return Uid()
        ..category = Categories.valueOf(int.parse(list[0]))
        ..node = list[1]
        ..sessionId = _ALL_SESSIONS;
    }
  }

  bool isUser() => this.asUid().category == Categories.USER;

  bool isBot() => this.asUid().category == Categories.BOT;

  bool isGroup() => this.asUid().category == Categories.GROUP;

  bool isChannel() => this.asUid().category == Categories.CHANNEL;

  bool isMuc() => this.isGroup() || this.isChannel();
}
