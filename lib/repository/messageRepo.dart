import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/message_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:path_provider/path_provider.dart';

class MessageRepo {
  MessageDao messageDao = GetIt.I.get<MessageDao>();
  RoomDao roomDao = GetIt.I.get<RoomDao>();
  PendingMessageDao pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();
  MessageService messageService = GetIt.I.get<MessageService>();
  FileRepo fileRepo = GetIt.I.get<FileRepo>();

  sendTextMessage(Uid roomId, String text) async {
    Message message = Message(
      roomId: roomId.string,
      packetId: 1000,
      time: DateTime.now(),
      from: accountRepo.currentUserUid.string,
      to: roomId.string,
      edited: false,
      encrypted: false,
      type: MessageType.TEXT,
      json: jsonEncode({"text": text}),
    );
    int messageId = await messageDao.insertMessage(message);
    await roomDao.insertRoom(
        Room(roomId: roomId.string, lastMessage: messageId, mentioned: false));
    PendingMessage pendingMessage = PendingMessage(
      messageId: messageId,
      retry: 0,
      time: DateTime.now(),
      status: SendingStatus.PENDING,
      details: message.json,
    );
    int pendingMsgDbId =
        await pendingMessageDao.insertPendingMessage(pendingMessage);
    Message updatedByServer = await messageService.sendMessage(message);
    messageDao.updateMessage(
        updatedByServer.copyWith(time: DateTime.now(), dbId: messageId));
    pendingMessageDao
        .deletePendingMessage(pendingMessage.copyWith(dbId: pendingMsgDbId));
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

  sendFileMessage(Uid roomId, String path) async {
    String type;
    type = findType(path);

    Message message = Message(
        roomId: roomId.string,
        packetId: 1000,
        time: DateTime.now(),
        from: accountRepo.currentUserUid.string,
        to: roomId.string,
        edited: false,
        encrypted: false,
        type: MessageType.FILE,
        json: jsonEncode({
          "uuid": "0",
          "size": 0,
          "type": type,
          "name": path.split('/').last,
          "caption": "caption",
          "width": type == 'image' || type == 'video' ? 200 : 0,
          "height": type == 'image' || type == 'video' ? 100 : 0,
          "duration": type == 'audio' || type == 'video' ? 17.0 : 0.0,
        }));
    var messageId = await messageDao.insertMessage(message);

    PendingMessage pendingMessage = PendingMessage(
      messageId: messageId,
      retry: 0,
      time: DateTime.now(),
      status: SendingStatus.SENDING_FILE,
      details: jsonEncode({"path": path}),
    );

    int pendingMsgDbId =
        await pendingMessageDao.insertPendingMessage(pendingMessage);
    Fimber.d('before uploading ${DateTime.now()}');
    FileInfo fileInfo = await fileRepo.uploadFile(File(path));
    Fimber.d(
        'after uploading ${DateTime.now()} and name of uploadedFile is ${fileInfo.name}');

    message = message.copyWith(
      dbId: messageId,
      json: jsonEncode({
        "uuid": fileInfo.uuid,
        "size": fileInfo.compressionSize,
        "name": fileInfo.name,
        "type": type,
        "caption": "caption",
        "width": type == 'image' || type == 'video' ? 250 : 0,
        "height": type == 'image' || type == 'video' ? 300 : 0,
        "duration": type == 'audio' || type == 'video' ? 17.0 : 0.0,
      }),
      time: DateTime.now(),
    );
    await messageDao.updateMessage(message);

    pendingMessage = pendingMessage.copyWith(
        dbId: pendingMsgDbId,
        status: SendingStatus.PENDING,
        time: message.time);
    await pendingMessageDao.updatePendingMessage(pendingMessage);
    Fimber.d('before sending ${DateTime.now()}');

    message = await messageService.sendMessage(message);
    Fimber.d('after sending ${DateTime.now()} sent message is $message');

    messageDao.updateMessage(message.copyWith(time: DateTime.now()));
    pendingMessageDao.deletePendingMessage(pendingMessage);
  }
}
