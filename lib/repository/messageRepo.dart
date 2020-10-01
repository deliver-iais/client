import 'dart:convert';
import 'dart:io' as LocalFile;

import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/services/message_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as clientMessage;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fixnum/fixnum.dart';

class MessageRepo {
  MessageDao _messageDao = GetIt.I.get<MessageDao>();
  RoomDao _roomDao = GetIt.I.get<RoomDao>();
  PendingMessageDao _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
  MessageService _messageService = GetIt.I.get<MessageService>();
  FileRepo _fileRepo = GetIt.I.get<FileRepo>();
  CoreServices _coreServices = GetIt.I.get<CoreServices>();

  sendTextMessage(Uid roomId, String text,
      {int replyId, String forwardedFrom}) async {
    Message message = Message(
      roomId: roomId.string,
      packetId: 1000,
      time: DateTime.now(),
      from: _accountRepo.currentUserUid.string,
      to: roomId.string,
      edited: false,
      encrypted: false,
      replyToId: replyId != null ? replyId : -1,
      forwardedFrom: forwardedFrom,
      type: MessageType.TEXT,
      json: jsonEncode({"text": text}),
    );
    int messageId = await _messageDao.insertMessage(message);
    await _roomDao.insertRoom(
        Room(roomId: roomId.string, lastMessage: messageId, mentioned: false));
    PendingMessage pendingMessage = PendingMessage(
      messageId: messageId,
      retry: 0,
      time: DateTime.now(),
      status: SendingStatus.PENDING,
      details: message.json,
    );
    int pendingMsgDbId =
        await _pendingMessageDao.insertPendingMessage(pendingMessage);
    clientMessage.Text messageText = clientMessage.Text()..text = message.json;
    _coreServices.sendMessage(clientMessage.MessageByClient()
      ..packetId = "12345"
      ..text = messageText
      ..to = message.to.uid);
//    messageDao.updateMessage(
//        updatedByServer.copyWith(time: DateTime.now(), dbId: messageId));
//    pendingMessageDao
//        .deletePendingMessage(pendingMessage.copyWith(dbId: pendingMsgDbId));
  }

  String findType(String path) {
    Fimber.d('path is ' + path);
    String postfix = path.split('.').last;
    if (postfix == 'png' || postfix == 'jpg' || postfix == 'jpeg')
      return 'image';
    else if (postfix == 'mp4')
      return 'video';
    else if (postfix == 'mp3')
      return 'audio';
    else
      return 'file';
  }

  sendFileMessage(Uid roomId, String path,
      {int replyId, String forwardedFrom, String caption}) async {
    String type;
    type = findType(path);

    Message message = Message(
        roomId: roomId.string,
        packetId: 1000,
        time: DateTime.now(),
        from: _accountRepo.currentUserUid.string,
        to: roomId.string,
        edited: false,
        encrypted: false,
        replyToId: replyId != null ? replyId : -1,
        type: MessageType.FILE,
        json: jsonEncode({
          "uuid": "0",
          "size": 0,
          "type": type,
          "name": path.split('/').last,
          "caption": caption,
          "width": type == 'image' || type == 'video' ? 200 : 0,
          "height": type == 'image' || type == 'video' ? 100 : 0,
          "duration": type == 'audio' || type == 'video' ? 17.0 : 0.0,
        }));
    var messageId = await _messageDao.insertMessage(message);

    RoomDao roomDao = GetIt.I.get<RoomDao>();
    roomDao.getByRoomId(roomId.string).first.then(
        (value) => roomDao.updateRoom(value.copyWith(lastMessage: messageId)));
    PendingMessage pendingMessage = PendingMessage(
      messageId: messageId,
      retry: 0,
      time: DateTime.now(),
      status: SendingStatus.SENDING_FILE,
      details: jsonEncode({"path": path}),
    );

    int pendingMsgDbId =
        await _pendingMessageDao.insertPendingMessage(pendingMessage);
    Fimber.d('before uploading ${DateTime.now()}');
    FileInfo fileInfo = await _fileRepo.uploadFile(LocalFile.File(path));
    File file = File()
      ..name = fileInfo.name
      ..uuid = fileInfo.uuid
      ..size;
    _coreServices.sendMessage(clientMessage.MessageByClient()
      ..packetId = "12345"
      ..file = file
      ..to = message.to.uid);
    Fimber.d(
        'after uploading ${DateTime.now()} and name of uploadedFile is ${fileInfo.name}');

    message = message.copyWith(
      dbId: messageId,
      json: jsonEncode({
        "uuid": fileInfo.uuid,
        "size": fileInfo.compressionSize,
        "name": fileInfo.name,
        "type": type,
        "width": type == 'image' || type == 'video' ? 250 : 0,
        "height": type == 'image' || type == 'video' ? 300 : 0,
        "duration": type == 'audio' || type == 'video' ? 17.0 : 0.0,
      }),
      time: DateTime.now(),
    );
    await _messageDao.updateMessage(message);

    pendingMessage = pendingMessage.copyWith(
        dbId: pendingMsgDbId,
        status: SendingStatus.PENDING,
        time: message.time);
    await _pendingMessageDao.updatePendingMessage(pendingMessage);
    Fimber.d('before sending ${DateTime.now()}');

    message = await _messageService.sendMessage(message);
    Fimber.d('after sending ${DateTime.now()} sent message is $message');

    _messageDao.updateMessage(message.copyWith(time: DateTime.now()));
    _pendingMessageDao.deletePendingMessage(pendingMessage);
  }



  sendForwardedMessage(Uid roomId, List<Message> forwardedMessage) async {
    for (var i = 0; i < forwardedMessage.length; i++) {
      if (forwardedMessage[i].type == MessageType.TEXT) {
        sendTextMessage(roomId, (jsonDecode(forwardedMessage[i].json))["text"],
            forwardedFrom: forwardedMessage[i].from);
      } else if (forwardedMessage[i].type == MessageType.FILE) {
        //TODO sendFileMessage(roomId)
      }
    }
  }

}
