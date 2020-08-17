import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

extension UidExtension on Uid {
  bool isSameEntity(String entityString) {
    var list = entityString.split(":");
    if (list.length != 2) {
      return false;
    } else {
      return this.category == list[0] && this.node == list[1];
    }
  }

  String toStr() => "${this.category}:${this.node}";
}

extension StringUidExtension on String {
  bool isSameEntity(Uid uid) {
    var list = this.split(":");
    if (list.length != 2) {
      return false;
    } else {
      return uid.category == list[0] && uid.node == list[1];
    }
  }

  String toUid() {
    // TODO need to be implemented.
    return null;
  }
}
