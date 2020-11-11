import 'dart:convert';
import 'dart:ffi';
import 'dart:io' as LocalFile;
import 'dart:math';

import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/app_mode.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';

import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as clientMessage;
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
import 'package:grpc/grpc.dart';
import 'package:rxdart/rxdart.dart';

enum TitleStatusConditions { Disconnected, Updating, Normal }

class MessageRepo {
  MessageDao _messageDao = GetIt.I.get<MessageDao>();
  RoomDao _roomDao = GetIt.I.get<RoomDao>();
  LastSeenDao _lastSeenDao = GetIt.I.get<LastSeenDao>();
  PendingMessageDao _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
  FileRepo _fileRepo = GetIt.I.get<FileRepo>();
  CoreServices _coreServices = GetIt.I.get<CoreServices>();
  BehaviorSubject<TitleStatusConditions> updatingStatus =
      BehaviorSubject.seeded(TitleStatusConditions.Disconnected);

  static int id = 0;

  // ignore: non_constant_identifier_names
  final int MAX_REMAINING_RETRIES = 3;
  static ClientChannel _clientChannel = ClientChannel("172.16.111.189",
      port: 30101,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  QueryServiceClient _queryServiceClient = QueryServiceClient(_clientChannel);

  MessageRepo() {
    _coreServices.connectionStatus.listen((mode) {
      if (mode == ConnectionStatus.Disconnected) {
        updatingStatus.add(TitleStatusConditions.Disconnected);
      }
      if (mode == ConnectionStatus.Connected) {
        updating();
      }
    });
    // establish();
  }

  updating() async {
    updatingStatus.add(TitleStatusConditions.Updating);
    print("UPDATTTTTTTTTTTTTTTTTTTTTTTTTTTTINNNNNNNNNNNNGGGGGGGGGGGG");
    try {
      var getAllUserRoomMetaRes = await _queryServiceClient.getAllUserRoomMeta(
          GetAllUserRoomMetaReq(),
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      print("FOOOOOOOOOOOOOR: $getAllUserRoomMetaRes");
      for (UserRoomMeta userRoomMeta in getAllUserRoomMetaRes.roomsMeta) {
        var room =
            await _roomDao.getByRoomIdFuture(userRoomMeta.roomUid.string) ??
                Room(
                    roomId: userRoomMeta.roomUid.getString(),
                    lastMessageId: -1,
                    lastMessageDbId: -1);
        print("FOOOOOOOOOOOOOR: $room $userRoomMeta");
        if (room.lastMessageId < userRoomMeta.lastMessageId.toInt()) {
          try {
            var fetchMessagesRes = await _queryServiceClient.fetchMessages(
                FetchMessagesReq()
                  ..roomUid = room.roomId.uid
                  ..pointer = userRoomMeta.lastMessageId
                  ..type = FetchMessagesReq_Type.BACKWARD_FETCH
                  ..limit = 5,
                options: CallOptions(metadata: {
                  'accessToken': await _accountRepo.getAccessToken()
                }));
            List<Message> messages =
                await _saveFetchMessages(fetchMessagesRes.messages);

            print("messages $messages");

            Message lastMessage = messages.reduce(
                (value, element) => value.id > element.id ? value : element);

            // TODO if there is Pending Message this line has a bug!!!
            await _roomDao.insertRoom(room.copyWith(
                lastMessageId: lastMessage.id.toInt(),
                lastMessageDbId: lastMessage.dbId));
          } catch (e) {
            print("EXCEPTIOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOONNNNNNNNNNNNNNNNNNNNNNNNN");
            print(e);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    updatingStatus.add(TitleStatusConditions.Normal);
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
    // await Future.delayed(Duration(seconds: 20)).whenComplete(() async {
    //   //TODO
    //   await _messageDao.updateMessage(
    //       message.copyWith(dbId: dbId, id: id, time: DateTime.now()));
    //   await _updateRoomLastMessage(roomId.string, dbId, id: id);
    //
    //   await _lastSeenDao.updateLastSeen(message.roomId, id);
    //
    //   await _pendingMessageDao.deletePendingMessage(dbId);
    //
    //   id++;
    // });
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
      {int replyId,
      String forwardedFrom,
      String caption,
      String forwardedMessageBody}) async {
    List<Message> messageList = new List();
    List<String> uploadKeyList = new List();
    // TODO refactored needed
    if (id == 0) {
      await insertRoomAndLastSeen((roomId.string));
    }
    for (var path in filesPath) {
      String packetId = _getPacketId();
      String type;
      type = forwardedMessageBody != null
          ? jsonDecode(forwardedMessageBody)["type"]
          : findType(path);
      String uploadKey = randomUid().node;
      uploadKeyList.add(uploadKey);
      Message message = Message(
          roomId: roomId.string,
          packetId: packetId,
          time: DateTime.now(),
          from: _accountRepo.currentUserUid.string,
          to: roomId.string,
          edited: false,
          encrypted: false,
          forwardedFrom: forwardedFrom,
          replyToId: replyId != null ? replyId : -1,
          type: MessageType.FILE,
          json: forwardedMessageBody != null
              ? forwardedMessageBody
              : jsonEncode({
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
      await _updateRoomLastMessage(roomId.string, dbId);
      await _savePendingMessage(dbId, roomId.string, SendingStatus.SENDING_FILE,
          MAX_REMAINING_RETRIES, message);
    }

    if (forwardedMessageBody == null) {
      for (int i = 0; i < filesPath.length; i++) {
        FileInfo fileInfo = await _fileRepo.uploadFile(
          LocalFile.File(filesPath[i]),
          uploadKey: uploadKeyList[i],
        );
        _sendFileMessage(messageList[i], fileInfo: fileInfo);
      }
    } else {
      _sendFileMessage(messageList[0],
          fileInfo: FileInfo(
              uuid: jsonDecode(messageList[0].json)["uuid"],
              name: jsonDecode(messageList[0].json)["name"]));
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
                //  _sendFileMessage(message, jsonDecode(message.json)["path"]);
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
          sendFileMessage(roomId, [""],
              forwardedFrom: forwardedMessage.forwardedFrom,
              forwardedMessageBody: forwardedMessage.json);
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

  _sendFileMessage(Message message, {FileInfo fileInfo}) async {
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

  Future<List<Message>> getPage(int page, String roomId, int id,
      {int pageSize = 50}) async {
    // print("MESSAGE IDDDDDDDDDDDDDDDDDDDDD: $id");
    var messages = await _messageDao.getPage(roomId, page);
    if (!messages.any((element) => element.id == id)) {
      var fetchMessagesRes = await _queryServiceClient.fetchMessages(
          FetchMessagesReq()
            ..roomUid = roomId.uid
            ..pointer = Int64(page * pageSize)
            ..type = FetchMessagesReq_Type.FORWARD_FETCH
            ..limit = pageSize,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      print(
          "MESSAGE $id IDDDDDDDDDDDDDDDDDDDDD fetch result: ${fetchMessagesRes.messages.length}");
      return await _saveFetchMessages(fetchMessagesRes.messages);
    }
    return messages;
  }

  Future<List<Message>> _saveFetchMessages(
      List<messagePb.Message> messages) async {
    List<Message> msgList = [];
    for (messagePb.Message message in messages) {
      msgList.add(await _coreServices.saveMessageInMessagesDB(message));
    }

    return msgList;
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
