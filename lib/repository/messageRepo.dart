import 'dart:convert';
import 'dart:ffi';
import 'dart:io' as LocalFile;

import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/app_mode.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';

import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as clientMessage;
import 'package:deliver_flutter/services/mode_checker.dart';
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

import 'package:fixnum/fixnum.dart';
import 'package:random_string/random_string.dart';
import 'package:grpc/grpc.dart';

class MessageRepo {
  MessageDao _messageDao = GetIt.I.get<MessageDao>();
  RoomDao _roomDao = GetIt.I.get<RoomDao>();
  LastSeenDao _lastSeenDao = GetIt.I.get<LastSeenDao>();
  PendingMessageDao _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
  FileRepo _fileRepo = GetIt.I.get<FileRepo>();
  CoreServices _coreServices = GetIt.I.get<CoreServices>();
  ModeChecker modeChecker = GetIt.I.get<ModeChecker>();

  static int id = 0;

  // ignore: non_constant_identifier_names
  final int MAX_REMAINING_RETRIES = 3;
  static ClientChannel _clientChannel = ClientChannel("172.16.111.189",
      port: 30101,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  QueryServiceClient _queryServiceClient = QueryServiceClient(_clientChannel);

  MessageRepo() {
    modeChecker.appMode.listen((mode) {
      if (mode == AppMode.STABLE) {
        updating();
      }
    });
    // establish();
  }

  updating() async {
    modeChecker.updating.add(true);
    int lastMessageDbId;
    try {
      var getAllUserRoomMetaRes = await _queryServiceClient.getAllUserRoomMeta(
          GetAllUserRoomMetaReq(),
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      for (UserRoomMeta userRoomMeta in getAllUserRoomMetaRes.roomsMeta) {
        Room room =
            await _roomDao.getByRoomId(userRoomMeta.roomUid.string).single;
        if (room == null) {
          await _roomDao.insertRoom(Room(roomId: userRoomMeta.roomUid.string));
          room = await _roomDao.getByRoomId(userRoomMeta.roomUid.string).single;
        }
        if (room.lastMessageId != userRoomMeta.lastMessageId.toInt()) {
          try {
            var fetchMessagesRes = await _queryServiceClient.fetchMessages(
                FetchMessagesReq()
                  ..roomUid = room.roomId.uid
                  ..pointer = userRoomMeta.lastMessageId
                  ..type = FetchMessagesReq_Type.FORWARD_FETCH
                  ..limit = 5,
                options: CallOptions(metadata: {
                  'accessToken': await _accountRepo.getAccessToken()
                }));
            lastMessageDbId =
                await _saveFetchMessages(fetchMessagesRes.messages);
            //TODO update last message db id
            await _roomDao.updateRoom(room.copyWith(
                lastMessageId: fetchMessagesRes.messages.last.id.toInt()));
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

  reconnecting() {}

  sendTextMessage(Uid roomId, String text,
      {int replyId, String forwardedFrom}) async {
    String packetId = _getPacketId();
    if (id == 0) {
      await insertRoomAndLastSeen((roomId.string));
    }
    Message message = Message(
      roomId: roomId.string,
      packetId: packetId,
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
    int dbId = await _messageDao.insertMessage(message);

    await _updateRoomLastMessage(roomId.string, dbId);
    await _savePendingMessage(dbId, roomId.string, SendingStatus.PENDING,
        MAX_REMAINING_RETRIES, message);
    await _sendTextMessage(message);
    await Future.delayed(Duration(seconds: 20)).whenComplete(() async {
      //TODO
      await _messageDao.updateMessage(
          message.copyWith(dbId: dbId, id: id, time: DateTime.now()));
      await _updateRoomLastMessage(roomId.string, dbId, id: id);

      await _lastSeenDao.updateLastSeen(message.roomId, id);

      await _pendingMessageDao.deletePendingMessage(dbId);

      id++;
    });
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

  sendFileMessage(Uid roomId, List<String> filesPath,
      {int replyId, String forwardedFrom, String caption}) async {
    List<Message> messageList = new List();
    List<String> uploadKeyList = new List();
    List<int> dbIdList = new List();
    if (id == 0) {
      await insertRoomAndLastSeen((roomId.string));
    }
    for (var path in filesPath) {
      String packetId = _getPacketId();
      String type;
      type = findType(path);
      String uploadKey = randomString(10);
      uploadKeyList.add(uploadKey);
      Message message = Message(
          roomId: roomId.string,
          packetId: packetId,
          time: DateTime.now(),
          from: _accountRepo.currentUserUid.string,
          to: roomId.string,
          edited: false,
          encrypted: false,
          replyToId: replyId != null ? replyId : -1,
          type: MessageType.FILE,
          json: jsonEncode({
            "uuid": uploadKey,
            "size": 0,
            "type": type,
            "path": path,
            "name": path.split('/').last,
            "caption": caption ?? "",
            "width": type == 'image' || type == 'video' ? 200 : 0,
            "height": type == 'image' || type == 'video' ? 100 : 0,
            "duration": type == 'audio' || type == 'video' ? 17.0 : 0.0,
          }));
      messageList.add(message);
      int dbId = await _messageDao.insertMessage(message);
      dbIdList.add(dbId);
      await _updateRoomLastMessage(roomId.string, dbId);
      await _savePendingMessage(dbId, roomId.string, SendingStatus.SENDING_FILE,
          MAX_REMAINING_RETRIES, message);
    }
    for (int i = 0; i < filesPath.length; i++) {
      FileInfo fileInfo = await _fileRepo.uploadFile(
        LocalFile.File(filesPath[i]),
        uploadKey: uploadKeyList[i],
      );
      await _sendFileMessage(messageList[i], filesPath[i], fileInfo: fileInfo);
      await Future.delayed(Duration(seconds: 10));

      //TODO
      await _messageDao.updateMessage(messageList[i]
          .copyWith(dbId: dbIdList[i], id: id, time: DateTime.now()));
      await _updateRoomLastMessage(roomId.string, dbIdList[i], id: id);
      await _lastSeenDao.updateLastSeen(messageList[i].roomId, id);
      await _pendingMessageDao.deletePendingMessage(dbIdList[i]);
      id++;
    }
  }

  sendPendingMessage() {
    _pendingMessageDao.watchAllMessages().listen((event) {
      for (PendingMessage pendingMessage in event) {
        if (pendingMessage.remainingRetries > 0) {
          switch (pendingMessage.status) {
            case SendingStatus.SENDING_FILE:
              _messageDao
                  .getByDbId(pendingMessage.messageDbId)
                  .listen((message) {
                _sendFileMessage(message, jsonDecode(message.json)["path"]);
              });
              _updatePendingMessage(pendingMessage);

              break;
            case SendingStatus.PENDING:
              _messageDao
                  .getByDbId(pendingMessage.messageDbId)
                  .listen((message) {
                _sendTextMessage(message);
              });
              _updatePendingMessage(pendingMessage);
              break;
          }
        }
      }
    });
  }

  _savePendingMessage(int dbId, String roomId, SendingStatus status,
      int remainingRetries, Message message) async {
    PendingMessage pendingMessage = PendingMessage(
      messageDbId: dbId,
      messagePacketId: message.packetId,
      roomId: roomId,
      remainingRetries: remainingRetries,
      time: DateTime.now(),
      details: message.json,
      status: status,
    );
    return await _pendingMessageDao.insertPendingMessage(pendingMessage);
  }

  sendSeenMessage(int messageId, Uid to, Uid roomId) {
    _coreServices.sendSeenMessage(SeenByClient()
      ..to = to
      ..id = Int64.parseInt(messageId.toString()));
  }

  insertRoomAndLastSeen(String roomId) async {
    await _lastSeenDao.insertLastSeen(LastSeen(roomId: roomId));
    await _roomDao
        .insertRoom(Room(roomId: roomId, mentioned: false, mute: false));
  }

  _updateRoomLastMessage(String roomId, int dbId, {int id}) async {
    if (id != null)
      await _roomDao.updateRoomLastMessage(roomId, dbId, newMessageId: id);
    else
      await _roomDao.updateRoomLastMessage(roomId, dbId);
  }

  sendForwardedMessage(Uid roomId, List<Message> forwardedMessage) async {
    for (Message forwardedMessage in forwardedMessage) {
      switch (forwardedMessage.type) {
        case MessageType.TEXT:
          sendTextMessage(
            roomId,
            (jsonDecode(forwardedMessage.json))["text"],
            forwardedFrom: forwardedMessage.from,
          );
          break;
        case MessageType.FILE:
          sendFileMessage(forwardedMessage.roomId.uid,
              jsonDecode(forwardedMessage.json)["path"],
              forwardedFrom: forwardedMessage.forwardedFrom);
          break;
        case MessageType.STICKER:
          // TODO: Handle this case.
          break;
        case MessageType.LOCATION:
          // TODO: Handle this case.
          break;
        case MessageType.LIVE_LOCATION:
          // TODO: Handle this case.
          break;
        case MessageType.POLL:
          // TODO: Handle this case.
          break;
        case MessageType.FORM:
          // TODO: Handle this case.
          break;
        case MessageType.PERSISTENT_EVENT:
          // TODO: Handle this case.
          break;
        case MessageType.NOT_SET:
          // TODO: Handle this case.
          break;
      }
    }
  }

  _sendTextMessage(Message message) async {
    clientMessage.Text messageText = clientMessage.Text()..text = message.json;
    clientMessage.MessageByClient messageByClient =
        clientMessage.MessageByClient()
          ..packetId = message.packetId
          ..text = messageText
          ..replyToId = Int64.parseInt(message.replyToId.toString())
          ..to = message.to.uid;

    if (message.forwardedFrom != null) {
      messageByClient.forwardFrom = message.forwardedFrom.uid;
    }
    await _coreServices.sendMessage(messageByClient);
  }

  _sendFileMessage(Message message, String path, {FileInfo fileInfo}) async {
    File file = File()
      ..name = fileInfo.name
      ..uuid = fileInfo.uuid
      ..caption = jsonDecode(message.json)["caption"];

    clientMessage.MessageByClient messageByClient =
        clientMessage.MessageByClient()
          ..packetId = message.packetId
          ..file = file
          ..replyToId = Int64.parseInt(message.replyToId.toString())
          ..to = message.to.uid;

    if (message.forwardedFrom != null) {
      messageByClient.forwardFrom = message.forwardedFrom.uid;
    }
    _coreServices.sendMessage(messageByClient);
  }

  _updatePendingMessage(PendingMessage pendingMessage) {
    _pendingMessageDao.insertPendingMessage(PendingMessage(
        messageDbId: pendingMessage.messageDbId,
        messagePacketId: pendingMessage.messagePacketId,
        roomId: pendingMessage.roomId,
        time: DateTime.now(),
        remainingRetries: pendingMessage.remainingRetries - 1));
  }

  getPendingMessage(int dbId) async {
    return await _messageDao.getPendingMessage(dbId);
  }

  deleteMessage(List<Message> messages) {}

  String _getPacketId() {
    return "${_accountRepo.currentUserUid.getString()}:${DateTime.now().microsecondsSinceEpoch.toString()}";
  }

  int pageSize = 50;
  getPage(int page, String roomId) async {
    var messages = await _messageDao.getPage(roomId, page);
    if (messages == null) {
      var fetchMessagesRes = await _queryServiceClient.fetchMessages(
          FetchMessagesReq()
            ..roomUid = roomId.uid
            ..pointer = Int64(page * pageSize)
            ..type = FetchMessagesReq_Type.FORWARD_FETCH
            ..limit = pageSize,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      await _saveFetchMessages(fetchMessagesRes.messages);
      messages = await _messageDao.getPage(roomId, page);
      if (messages == null) return List<Message>.filled(0, Message());
    }
    return messages;
  }

  _saveFetchMessages(List<messagePb.Message> messages) async {
    int lastMessageDbId;
    for (messagePb.Message message in messages) {
      MessageType type = findFetchMessageType(message);
      String json = findFetchMessageJson(message, type);
      lastMessageDbId = await _messageDao.insertMessage(
        Message(
          roomId: message.to.string,
          packetId: message.packetId,
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
    return lastMessageDbId;
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
      return MessageType.NOT_SET;
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
      json = {"type": message.persistEvent}; //TODO edit this
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

  receiveMessage(String a) async {
    for (int i = 0; i < 20; i++) {
      int k = await _messageDao.insertMessage(Message(
        packetId: "a:${DateTime.now().microsecondsSinceEpoch.toString()}",
        roomId: a,
        from: a,
        to: _accountRepo.currentUserUid.getString(),
        time: DateTime.now(),
        id: id,
        edited: false,
        encrypted: false,
        replyToId: -1,
        type: MessageType.TEXT,
        json: jsonEncode({"text": 'aaaa $id'}),
      ));
      await _roomDao.updateRoomLastMessage(a, k, newMessageId: id);
      id++;
    }
  }
}
