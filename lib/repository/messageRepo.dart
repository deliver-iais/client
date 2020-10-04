import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/app_mode.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/message_service.dart';
import 'package:deliver_flutter/services/mode_checker.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as messagePb;
import 'package:deliver_public_protocol/pub/v1/models/user_room_meta.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:grpc/grpc.dart';
import 'package:path_provider/path_provider.dart';

class MessageRepo {
  MessageDao messageDao = GetIt.I.get<MessageDao>();
  RoomDao roomDao = GetIt.I.get<RoomDao>();
  PendingMessageDao pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();
  MessageService messageService = GetIt.I.get<MessageService>();
  FileRepo fileRepo = GetIt.I.get<FileRepo>();
  ModeChecker modeChecker = GetIt.I.get<ModeChecker>();

  static ClientChannel _clientChannel = ClientChannel("172.16.111.189",
      port: 30100,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  QueryServiceClient _queryServiceClient = QueryServiceClient(_clientChannel);

  MessageRepo() {
    print('MessageREpo');
    modeChecker.appMode.listen((mode) {
      print('ModeChecker');
      if (mode == AppMode.STABLE) {
//        updating();
      }
    });
  }

  updating() async {
    modeChecker.updating.add(true);
    try {
      var getAllUserRoomMetaRes = await _queryServiceClient.getAllUserRoomMeta(
          GetAllUserRoomMetaReq(),
          options: CallOptions(
              metadata: {'accessToken': await accountRepo.getAccessToken()}));
      for (UserRoomMeta userRoomMeta in getAllUserRoomMetaRes.roomsMeta) {
        Room room = await roomDao.getByRoomId(userRoomMeta.uid.string).single;
        if (room.lastMessage != userRoomMeta.lastMessageId.toInt()) {
          try {
            var fetchMessagesRes = await _queryServiceClient.fetchMessages(
                FetchMessagesReq()
                  ..with_1 = room.roomId.uid
                  ..pointer = userRoomMeta.lastMessageId
                  ..type = FetchMessagesReq_Type.FORWARD_FETCH
                  ..limit = 5,
                options: CallOptions(metadata: {
                  'accessToken': await accountRepo.getAccessToken()
                }));
            await saveFetchMessages(fetchMessagesRes.messages);
            await roomDao.updateRoom(room.copyWith(
                lastMessage: fetchMessagesRes.messages.last.id.toInt()));
          } catch (e) {
            print(e);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    modeChecker.updating.add(false);
  }

  sendTextMessage(Uid roomId, String text,
      {int replyId, String forwardedFrom}) async {
    Message message = Message(
      roomId: roomId.string,
      packetId: 1000,
      time: DateTime.now(),
      from: accountRepo.currentUserUid.string,
      to: roomId.string,
      edited: false,
      encrypted: false,
      replyToId: replyId != null ? replyId : -1,
      forwardedFrom: forwardedFrom,
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

  sendFileMessage(Uid roomId, String path,
      {int replyId, String forwardedFrom, String caption}) async {
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
    var messageId = await messageDao.insertMessage(message);
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

  sendForwardedMessage(Uid roomId, List<Message> forwardedMessage) async {
    // print('hi hi ');
    for (var i = 0; i < forwardedMessage.length; i++) {
      if (forwardedMessage[i].type == MessageType.TEXT) {
        sendTextMessage(roomId, (jsonDecode(forwardedMessage[i].json))["text"],
            forwardedFrom: forwardedMessage[i].from);
      } else if (forwardedMessage[i].type == MessageType.FILE) {
        //TODO sendFileMessage(roomId)
      }
    }
  }

  saveFetchMessages(List<messagePb.Message> messages) {
    for (messagePb.Message message in messages) {
      MessageType type = findFetchMessageType(message);
      String json = findFetchMessageJson(message, type);
      messageDao.insertMessage(
        Message(
          roomId: message.to.string,
          packetId: int.parse(message.packetId),
          id: message.id.toInt(),
          time: DateTime.fromMillisecondsSinceEpoch(message.time.toInt()),
          from: message.from.string,
          to: message.to.string,
          edited: message.edited,
          encrypted: message.encrypted,
          type: type,
          json: json,
        ),
      );
    }
  }

  MessageType findFetchMessageType(messagePb.Message message) {
    if (message.hasText())
      return MessageType.TEXT;
    else if (message.hasFile())
      return MessageType.FILE;
    else if (message.hasForm())
      return MessageType.FORM;
    else if (message.hasSticker())
      return MessageType.STICKER;
    else if (message.hasPersistEvent())
      return MessageType.PERSISTENT_EVENT;
    else if (message.hasPoll())
      return MessageType.POLL;
    else if (message.hasLiveLocation())
      return MessageType.LIVE_LOCATION;
    else if (message.hasLocation())
      return MessageType.LOCATION;
    else
      return MessageType.NAN;
  }

  String findFetchMessageJson(messagePb.Message message, MessageType type) {
    var json = Object();
    if (type == MessageType.TEXT)
      json = {"text": message.text};
    else if (type == MessageType.FILE)
      json = {
        "uuid": message.file.uuid,
        "size": message.file.size,
        "type": message.file.type,
        "name": message.file.name,
        "caption": message.file.caption,
        "width": message.file.width,
        "height": message.file.height,
        "duration": message.file.duration
      };
    else if (type == MessageType.FORM)
      json = {"uuid": message.form.uuid, "title": message.form.title};
    else if (type == MessageType.STICKER)
      json = {
        "uuid": message.sticker.uuid,
        "id": message.sticker.id,
        "width": message.sticker.width,
        "height": message.sticker.height
      };
    else if (type == MessageType.PERSISTENT_EVENT)
      json = {"type": message.persistEvent.issue}; //TODO edit this
    else if (type == MessageType.POLL)
      json = {
        "uuid": message.poll.uuid,
        "title": message.poll.title,
        "number_of_options": message.poll.numberOfOptions
      };
    else if (type == MessageType.LOCATION)
      json = {
        "latitude": message.location.latitude,
        "longitude": message.location.longitude
      };
    else if (type == MessageType.LIVE_LOCATION)
      json = {"uuid": message.liveLocation.uuid};
    return jsonEncode(json);
  }
}
