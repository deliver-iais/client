import 'dart:convert';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;
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

  sendFileMessage(Uid to, String path) {
    // var textMessage = FileProto.File()..;
    String fileName = path.split('\\').last;
    var imageMessageJson = {
      "uuid": 'e824a70e-859d-4c73-92be-ccb1ead52fcc',
      "size": 5000000,
      "type": "image",
      "name": 'Screen Shot 1399-03-01 at 05.10.05.png',
      "caption": "hi",
      "width": 100,
      "height": 2000,
      "duration": 0.0
    };
    var audioMessageJson = {
      "uuid": "file: r.pdf",
      "size": 280000,
      "type": "audio",
      "name": fileName,
      "caption": "hi",
      "width": 0,
      "height": 0,
      "duration": 17.0
    };
    // TODO should send message...
    messageDao
        .insertMessage(Message(
          roomId: to.string,
          packetId: 2,
          time: DateTime.now(),
          from: accountRepo.currentUserUid.string,
          to: to.string,
          type: MessageType.file,
          json: jsonEncode(imageMessageJson),
        ))
        .then((dbId) => roomDao.insertRoom(Room(
              roomId: to.string,
              lastMessage: dbId,
            )));
  }
}
