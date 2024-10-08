import 'dart:async';
import 'package:deliver/box/message.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

abstract class MessageDao {
  Future<void> insertMessage(Message message);

  Future<void> updateMessage(Message message);

  Future<List<Message>> searchMessages(Uid roomUid, String keyword);

  Future<Message?> getMessageById(Uid roomUid, int id);

  Future<Message?> getMessageByLocalNetworkId(Uid roomUid, int id);

  Future<Message?> getMessageByPacketId(Uid roomUid, String packetId);

  Future<void> saveMessages(List<Message> messages);

  Future<List<Message>> getMessagePage(
    Uid roomUid,
    int page, {
    int pageSize = PAGE_SIZE,
  });

  Future<List<Message>> getLocalMessages(Uid roomUid);
}

mixin SortLocalNetworkMessages {
  List<Message> sortLocalMessages(List<Message> messages) => messages
    ..sort(
      (a, b) => (a.localNetworkMessageId ?? 0) - (b.localNetworkMessageId ?? 0),
    );
}
