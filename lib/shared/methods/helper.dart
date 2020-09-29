import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:uuid/uuid.dart';

import "dart:math";

T getRandomElement<T>(List<T> list) {
  final random = new Random();
  var i = random.nextInt(list.length);
  return list[i];
}

Uid randomUid() {
  var randomCategory = getRandomElement([Categories.USER]);
  var uuid = Uuid();
  return Uid()
    ..category = randomCategory
    ..node = uuid.v1();
}
