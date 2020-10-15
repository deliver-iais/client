import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' as LocalFile;

import 'package:dcache/dcache.dart';
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
import 'package:deliver_flutter/services/message_service.dart';
import 'package:deliver_flutter/services/mode_checker.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
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
import 'package:path_provider/path_provider.dart';

class MessageRepo {
  MessageDao _messageDao = GetIt.I.get<MessageDao>();
  RoomDao _roomDao = GetIt.I.get<RoomDao>();
  PendingMessageDao _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
  FileRepo _fileRepo = GetIt.I.get<FileRepo>();
  CoreServices _coreServices = GetIt.I.get<CoreServices>();
  MessageService messageService = GetIt.I.get<MessageService>();
  FileRepo fileRepo = GetIt.I.get<FileRepo>();
  ModeChecker modeChecker = GetIt.I.get<ModeChecker>();
  Cache cache = LruCache<String, Message>(storage: SimpleStorage(size: 50));
  // ignore: non_constant_identifier_names
  final int MAX_REMAINING_RETRIES = 3;
  static ClientChannel _clientChannel = ClientChannel("172.16.111.189",
      port: 30100,
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
    // modeChecker.updating.add(true);
    try {
      var getAllUserRoomMetaRes = await _queryServiceClient.getAllUserRoomMeta(
          GetAllUserRoomMetaReq(),
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      for (UserRoomMeta userRoomMeta in getAllUserRoomMetaRes.roomsMeta) {
        Room room =
            await _roomDao.getByRoomId(userRoomMeta.roomUid.string).single;
        if (room.lastMessage != userRoomMeta.lastMessageId.toString()) {
          //it is wrong
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
            _messageDao.insertMessage(Message(
                roomId: room.roomId,
                packetId: null, //?
                id: userRoomMeta.lastMessageId.toInt() +
                    fetchMessagesRes.messages.length -
                    1, //?
                time: null, //?
                from: fetchMessagesRes.messages.last.from.string,
                to: fetchMessagesRes.messages.last.to.string,
                edited: fetchMessagesRes.messages.last.edited,
                encrypted: fetchMessagesRes.messages.last.encrypted,
                type: null, //?
                json: null)); //?
            await _roomDao.updateRoom(room.copyWith(
                lastMessage: userRoomMeta.lastMessageId.toString()));

            ///it is wrong
          } catch (e) {
            print(e);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    // modeChecker.updating.add(false);
  }

  reconnecting() {}
  sendTextMessage(Uid roomId, String text,
      {int replyId, String forwardedFrom}) async {
    String packetId = _getPacketId();
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
    _messageDao.insertMessage(message);
    _savePendingMessage(
        packetId, SendingStatus.PENDING, MAX_REMAINING_RETRIES, message);
    _sendTextMessage(message);
    _updateRoomLastMessage(roomId, packetId);
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
    String packetId = _getPacketId();
    String type;
    type = findType(path);
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
          "uuid": "0",
          "size": 0,
          "type": type,
          "path": path,
          "name": path.split('/').last,
          "caption": caption ?? "",
          "width": type == 'image' || type == 'video' ? 200 : 0,
          "height": type == 'image' || type == 'video' ? 100 : 0,
          "duration": type == 'audio' || type == 'video' ? 17.0 : 0.0,
        }));
    _messageDao.insertMessage(message);
    _savePendingMessage(
        packetId, SendingStatus.SENDING_FILE, MAX_REMAINING_RETRIES, message);
    _sendFileMessage(message, path);
    _updateRoomLastMessage(roomId, packetId);
  }

  sendPendingMessage() {
    _pendingMessageDao.watchAllMessages().listen((event) {
      for (PendingMessage pendingMessage in event) {
        if (pendingMessage.remainingRetries > 0) {
          switch (pendingMessage.status) {
            case SendingStatus.SENDING_FILE:
              _messageDao.getByDBId(pendingMessage.messageId).listen((message) {
                _sendFileMessage(message, jsonDecode(message.json)["path"]);
              });
              _updatePendingMessage(pendingMessage);

              break;
            case SendingStatus.PENDING:
              _messageDao.getByDBId(pendingMessage.messageId).listen((message) {
                _sendTextMessage(message);
              });
              _updatePendingMessage(pendingMessage);
              break;
          }
        }
      }
    });
  }

  _savePendingMessage(String messageId, SendingStatus status,
      int remainingRetries, Message message) {
    PendingMessage pendingMessage = PendingMessage(
      messageId: messageId.toString(),
      remainingRetries: remainingRetries,
      time: DateTime.now(),
      details: message.json,
      status: status,
    );
    _pendingMessageDao.insertPendingMessage(pendingMessage);
  }

  sendSeenMessage(int messageId, Uid to, Uid roomId) {
    _coreServices.sendSeenMessage(SeenByClient()
      ..to = to
      ..id = Int64.parseInt(messageId.toString()));
  }

  _updateRoomLastMessage(Uid roomId, String messageId) {
    _roomDao.insertRoom(Room(
        roomId: roomId.string,
        lastMessage: messageId,
        mentioned: false,
        mute: false));
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
      }
    }
  }

  _sendTextMessage(Message message) {
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
    _coreServices.sendMessage(messageByClient);
  }

  _sendFileMessage(Message message, String path) async {
    FileInfo fileInfo = await _fileRepo.uploadFile(LocalFile.File(path));
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
        messageId: pendingMessage.messageId,
        time: DateTime.now(),
        remainingRetries: pendingMessage.remainingRetries - 1));
  }

  deleteMessage(List<Message> messages) {}

  String _getPacketId() {
    return "${_accountRepo.currentUserUid.getString()}:${DateTime.now().microsecondsSinceEpoch.toString()}";
  }

  getPage(int page, String roomId) async {
    var messages = _messageDao.getPage(roomId, page);
    if (messages == null) {
      var fetchMessagesRes = await _queryServiceClient.fetchMessages(
          FetchMessagesReq()
            ..roomUid = roomId.uid
            ..pointer = Int64(page * 50)
            ..type = FetchMessagesReq_Type.FORWARD_FETCH
            ..limit = 50,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    }
    return messages;
  }
}
