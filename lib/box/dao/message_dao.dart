import 'dart:async';
import 'package:deliver/box/message.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

abstract class MessageDao {
  Future<void> saveMessage(Message message);


  Future<Message?> getMessage(Uid roomUid, int id);

  Future<List<Message>> getMessagePage(
    Uid roomUid,
    int page, {
    int pageSize = PAGE_SIZE,
  });
}
