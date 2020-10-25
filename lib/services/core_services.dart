import 'dart:async';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart' as M;

import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class CoreServices {
  static ClientChannel _clientChannel = ClientChannel(
      ServicesDiscoveryRepo().coreService.host,
      port: ServicesDiscoveryRepo().coreService.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var coreService = CoreServiceClient(_clientChannel);
  StreamController<ClientPacket> _clientPacket =
      StreamController<ClientPacket>();
  var _accountRepo = GetIt.I.get<AccountRepo>();

  var _messageDao = GetIt.I.get<MessageDao>();
  var _seenDao = GetIt.I.get<SeenDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  PendingMessageDao _pendingMessageDao = GetIt.I.get<PendingMessageDao>();

  setCoreSetting() async {
    try {
      ResponseStream<ServerPacket> responseStream = coreService.establishStream(
          _clientPacket.stream,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      responseStream.listen((serverPacket) {
        print("messageweeeeee");
        switch (serverPacket.whichType()) {
          case ServerPacket_Type.message:
            _saveIncomingMessage(serverPacket.message);
            break;
          case ServerPacket_Type.error:
            print("errrrrrrrrrrrrrrrrrror");
            break;
          case ServerPacket_Type.seen:
            _saveSeenMessage(serverPacket.seen);

            break;
          case ServerPacket_Type.activity:
            _saveActivityMessage(serverPacket.activity);
            break;
          case ServerPacket_Type.pollStatusChanged:
            break;
          case ServerPacket_Type.liveLocationStatusChanged:
            break;
          case ServerPacket_Type.notSet:
            break;
          case ServerPacket_Type.pong:
            print("ffffffff");
            savePingMessage(serverPacket.pong);
            break;
        }
      });
    } catch (e) {
      print("correservice error");
    }
  }

  _saveIncomingMessage(Message message) {
    _messageDao.insertMessage(M.Message(
        id: message.id.toInt(),
        packetId: message.packetId,
        time: DateTime.parse(message.time.toString()),
        to: message.to.string,
        from: message.from.string,
        replyToId: message.replyToId.hashCode,
        forwardedFrom: message.forwardFrom.string,
        json: message.text.text,
        edited: message.edited,
        encrypted: message.encrypted,
        type: getMessageType(message.whichType())));
    // _pendingMessageDao
    //     .deletePendingMessage(M.PendingMessage(messageDbId: : message.));
    // _roomDao.insertRoom(
    //   M.Room(
    //       roomId: message.from.string,
    //       lastMessageId: message.id.toInt(),
    //       lastMessageDbId: message.),
    // );
  }

  sendMessage(MessageByClient message) {
    _clientPacket.add(ClientPacket()
      ..message = message
      ..id = message.packetId);
    print("message is send ");
  }

  sendPingMessage() {
    _clientPacket.add(ClientPacket()
      ..ping = Ping()
      ..id = DateTime.now().microsecondsSinceEpoch.toString());
  }

  sendSeenMessage(SeenByClient seen) {
    _clientPacket.add(ClientPacket()
      ..seen = seen
      ..id = seen.id.toString());
  }

  sendActivityMessage(ActivityByClient activity) {
    _clientPacket.add(ClientPacket()
      ..activity = activity
      ..id = DateTime.now().microsecondsSinceEpoch.toString());
  }

  deleteMessage() {}

  MessageType getMessageType(Message_Type messageType) {
    switch (messageType) {
      case Message_Type.text:
        return MessageType.TEXT;
        break;
      case Message_Type.file:
        return MessageType.FILE;
        break;
      case Message_Type.sticker:
        return MessageType.STICKER;
        break;
      case Message_Type.location:
        return MessageType.LOCATION;
        break;
      case Message_Type.liveLocation:
        return MessageType.LIVE_LOCATION;
        break;
      case Message_Type.poll:
        return MessageType.POLL;
        break;
      case Message_Type.form:
        return MessageType.FORM;
        break;
      case Message_Type.persistEvent:
        return MessageType.PERSISTENT_EVENT;
        break;
      case Message_Type.notSet:
        return MessageType.NOT_SET;
        break;
    }
  }

  _saveSeenMessage(Seen seen) {
    Uid roomId;
    switch (seen.to.category) {
      case Categories.USER:
        seen.to == _accountRepo.currentUserUid
            ? roomId = seen.to
            : roomId = seen.from;
        break;
      case Categories.GROUP:
      case Categories.PRIVATE_CHANNEL:
      case Categories.PUBLIC_CHANNEL:
      case Categories.BOT:
        roomId = seen.to;
        break;
    }
    _seenDao.insertSeen(M.Seen(
        messageId: seen.id.toInt(),
        user: seen.from.string,
        roomId: roomId.string));
  }

  _saveActivityMessage(Activity activity) {
    //todo
  }

  void savePingMessage(Pong pong) {}
}
