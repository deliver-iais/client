import 'dart:async';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/database.dart' as M;
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
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

  CoreServices() {}

  setCoreSetting() async {
    ResponseStream<ServerPacket> responseStream = coreService.establishStream(
        _clientPacket.stream,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    responseStream.listen((serverPacket) {
      switch (serverPacket.whichType() ){
        case ServerPacket_Type.message:
          print("messageweeeeeeeeeeeeeeeeeeee");
          _saveIncomingMessage(serverPacket.message);
          break;
        case ServerPacket_Type.error:
         serverPacket.error;
          print("errrrrrrrrrrrrrrrrrror");
          break;
        case ServerPacket_Type.seen:


          break;
        case ServerPacket_Type.activity:

          break;
        case ServerPacket_Type.pollStatusChanged:

          break;
        case ServerPacket_Type.liveLocationStatusChanged:

          break;
        case ServerPacket_Type.notSet:
          break;
      }

    });
  }
  _saveIncomingMessage(Message message) {
    _messageDao.insertMessage(M.Message(
        id: message.id.hashCode,
        packetId: int.parse(message.packetId),
        time: DateTime.parse(message.time.toString()),
        to: message.to.string,
        from: message.from.string,
        replyToId: message.replyToId.hashCode,
        forwardedFrom: message.forwardFrom.string,
        json: message.text.text,
        edited: message.edited,
        encrypted: message.encrypted,
        type: getMessageType(message.whichType())));
  }

  sendMessage(MessageByClient message) {

    _clientPacket.add(ClientPacket()..message = message);
    print("message is send ");
  }

  seenMessage(SeenByClient seen) {
    _clientPacket.add(ClientPacket()..seen = seen);
  }

  sendActivity(ActivityByClient activity){
    _clientPacket.add(ClientPacket()..activity = activity);
  }

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


}
