import 'dart:convert';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MessageService {
  var messageDao = GetIt.I.get<MessageDao>();
  var roomDao = GetIt.I.get<RoomDao>();
  var accountRepo = GetIt.I.get<AccountRepo>();

  sendTextMessage(Uid to, String text) {
    var textMessage = MessageProto.Text()..text = text;
    // TODO should send message...
    var textMessageJson = {"text": text};
    messageDao
        .insertMessage(Message(
          roomId: to.string,
          packetId: 2,
          time: DateTime.now(),
          from: accountRepo.currentUserUid.string,
          to: to.string,
          type: MessageType.text,
          json: jsonEncode(textMessageJson),
        ))
        .then((dbId) => roomDao.insertRoom(Room(
              roomId: to.string,
              lastMessage: dbId,
            )));
  }

  sendFileMessage(String to, String path) {
    // TODO needs to be implemented
    // messageDao
    //     .insertMessage(MessagesCompanion(
    //       roomId: Value('0:Judi'),
    //       packetId: Value(2),
    //       time: Value(DateTime.now().subtract(Duration(days: 2))),
    //       from: Value('0:john'),
    //       to: Value('0:jain'),
    //       type: Value(MessageType.file),
    //       json: Value('{\"uuid\":\"File:a.png\",\"size\":' +
    //           Int64.parseInt('5000000').toString() +
    //           ',\"type\":\"image\",\"name\":\"a.png\",\"caption\":\"hi a\",\"width\":100,\"height\":100,\"duration\":0}'),
    //     ))
  }
}
