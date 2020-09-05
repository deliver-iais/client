import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fimber/fimber.dart';

extension UidExtension on Uid {
  bool isSameEntity(String entityString) {
    var list = entityString.split(":");
    if (list.length != 2) {
      return false;
    } else {
      return this.category.value == int.parse(list[0]) && this.node == list[1];
    }
  }

  bool equals(Uid uid) {
    return this.category.value == uid.category.value && this.node == uid.node;
  }

  get string => "${this.category.value}:${this.node}";

  String getString() => this.string;
}

const _ALL_SESSIONS = "*";

extension StringUidExtension on String {
  bool isSameEntity(Uid uid) {
    var list = this.split(":");
    if (list.length != 2) {
      return false;
    } else {
      Fimber.d(list[0]);
      Fimber.d(list[1]);
      return uid.category.value == int.parse(list[0]) && uid.node == list[1];
    }
  }

  get uid {
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

  String getUid() => this.uid;
}
