import 'package:collection/collection.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:flutter_test/flutter_test.dart';

class PendingMessageExceptStatusMatcher extends Matcher {
  const PendingMessageExceptStatusMatcher({
    required this.pm,
  });

  final PendingMessage pm;

  @override
  // ignore: type_annotate_public_apis
  bool matches(other, Map<dynamic, dynamic> matchState) {
    return identical(this, other) ||
        (
            other.runtimeType == pm.runtimeType &&
            other is PendingMessage &&
            const DeepCollectionEquality().equals(other.roomUid, pm.roomUid) &&
            const DeepCollectionEquality()
                .equals(other.packetId, pm.packetId) &&
            const DeepCollectionEquality().equals(other.msg, pm.msg) &&
            const DeepCollectionEquality().equals(other.failed, pm.failed));
  }

  @override
  Description describe(Description description) =>
      description.add('matches color $pm');
}
