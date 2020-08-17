import 'dart:convert';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;
import 'package:get_it/get_it.dart';

class MessageService {
  var messageDao = GetIt.I.get<MessageDao>();
  var roomDao = GetIt.I.get<RoomDao>();

  sendTextMessage(String to, String text) {
    var textMessage = MessageProto.Text()..text = text;
    // TODO should send message...
    var textMessageJson = {"text": text};
    messageDao
        .insertMessage(Message(
          roomId: 'users:Judi',
          packetId: 2,
          time: DateTime.now(),
          from: 'users:John',
          to: to,
          type: MessageType.text,
          json: jsonEncode(textMessageJson),
        ))
        .then((dbId) => roomDao.insertRoom(Room(
              roomId: to,
              lastMessage: dbId,
            )));
  }

  sendFileMessage(String to, String path) {
    // TODO needs to be implemented
  }
}
