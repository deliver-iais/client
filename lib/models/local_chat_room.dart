import 'package:deliver/box/room.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

class LocalChatRoom {
  Uid uid;
  int lastMessageId;
  int lastLocalNetworkId;
  String lastPacketId;

  LocalChatRoom({
    required this.uid,
    required this.lastMessageId,
    required this.lastLocalNetworkId,
    required this.lastPacketId,
  });
}

extension LocalChatRoomMapper on Room {
  LocalChatRoom getLocalChat() => LocalChatRoom(
      uid: uid,
      lastMessageId: lastMessageId,
      lastLocalNetworkId: lastLocalNetworkMessageId,
      lastPacketId:
          (lastMessage?.id != null ? lastMessage?.packetId : "") ?? "",);
}
