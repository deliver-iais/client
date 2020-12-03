import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' as DartFile;

import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user_room_meta.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:mime_type/mime_type.dart';
import 'package:moor/moor.dart';
import 'package:rxdart/rxdart.dart';

import 'mucRepo.dart';

enum TitleStatusConditions { Disconnected, Updating, Normal }

const int MAX_REMAINING_RETRIES = 3;

DateTime now() {
  return DateTime.now();
}

class MessageRepo {
  var _messageDao = GetIt.I.get<MessageDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _pendingMessageDao = GetIt.I.get<PendingMessageDao>();

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();

  var _coreServices = GetIt.I.get<CoreServices>();

  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  BehaviorSubject<TitleStatusConditions> updatingStatus =
      BehaviorSubject.seeded(TitleStatusConditions.Disconnected);

  MessageRepo() {
    _coreServices.connectionStatus.listen((mode) {
      if (mode == ConnectionStatus.Disconnected) {
        updatingStatus.add(TitleStatusConditions.Disconnected);
      }
      if (mode == ConnectionStatus.Connected) {
        _updating();
      }
    });
  }

  var _completerMap = Map<String, Completer<List<Message>>>();

  // TODO: Refactor Needed
  _updating() async {
    updatingStatus.add(TitleStatusConditions.Updating);
    print("UPDATTTTTTTTTTTTTTTTTTTTTTTTTTTTINNNNNNNNNNNNGGGGGGGGGGGG");
    try {
      var getAllUserRoomMetaRes = await _queryServiceClient.getAllUserRoomMeta(
          GetAllUserRoomMetaReq(),
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
      print(getAllUserRoomMetaRes.roomsMeta);
      print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
      for (UserRoomMeta userRoomMeta in getAllUserRoomMetaRes.roomsMeta) {
        print("------------------------------------");
        print(userRoomMeta);
        var room =
            await _roomDao.getByRoomIdFuture(userRoomMeta.roomUid.asString());

        print("room: $room");

        if (room != null &&
            room.lastMessageId != null &&
            room.lastMessageId >= userRoomMeta.lastMessageId.toInt() &&
            room.lastMessageId != 0) {
          continue;
        }
        try {
          var fetchMessagesRes = await _queryServiceClient.fetchMessages(
              FetchMessagesReq()
                ..roomUid = userRoomMeta.roomUid
                ..pointer = userRoomMeta.lastMessageId
                ..type = FetchMessagesReq_Type.FORWARD_FETCH
                ..limit = 2,
              options: CallOptions(timeout: Duration(seconds: 1), metadata: {
                'accessToken': await _accountRepo.getAccessToken()
              }));
          List<Message> messages =
              await _saveFetchMessages(fetchMessagesRes.messages);

          if (userRoomMeta.roomUid.category != Categories.USER) {
            await _mucRepo.saveMucInfo(userRoomMeta.roomUid);
          }

          // TODO if there is Pending Message this line has a bug!!
          _roomDao.insertRoomCompanion(RoomsCompanion.insert(
              roomId: userRoomMeta.roomUid.asString(),
              lastMessageId: Value(userRoomMeta.lastMessageId.toInt()),
              lastMessageDbId: Value(messages[0].dbId)));
        } catch (e) {
          print("EXCEPTIOOOOOOOOOOOOOOOOOOOOOOOOOOONNNNNNNNNNNNNNNNNNNNNN");
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }
    updatingStatus.add(TitleStatusConditions.Normal);

    // TODO, change the position of calling this function, maybe needed periodic sending
    _sendPendingMessages();
  }

  sendTextMessage(Uid room, String text,
      {int replyId, String forwardedFromAsString}) async {
    String packetId = _getPacketId();
    String json = (MessageProto.Text()..text = text).writeToJson();

    MessagesCompanion message = MessagesCompanion.insert(
      roomId: room.asString(),
      packetId: packetId,
      time: now(),
      from: _accountRepo.currentUserUid.asString(),
      to: room.asString(),
      replyToId: replyId != null ? Value(replyId) : Value.absent(),
      forwardedFrom: Value(forwardedFromAsString),
      type: MessageType.TEXT,
      json: json,
    );

    int dbId = await _messageDao.insertMessageCompanion(message);

    _savePendingMessage(room.asString(), dbId, packetId, SendingStatus.PENDING);

    _updateRoomLastMessage(
      room.asString(),
      dbId,
    );

    // Send Message
    _sendMessageToServer(dbId);
  }

  sendFileMessage(Uid room, String path,
      {String caption = "", int replyToId = -1}) async {
    String packetId = _getPacketId();

    // Create MessageCompanion
    var file = DartFile.File(path);

    // Get size of image
    var tempDimension = ImageSizeGetter.getSize(FileInput(file));
    if (tempDimension == Size.zero) {
      tempDimension = Size(200, 200);
    }

    // Get type with file name
    final tempType = _findType(path);

    final tempFileSize = file.statSync().size;

    FileProto.File sendingFakeFile = FileProto.File()
      ..uuid = packetId
      ..caption = caption ?? ""
      ..width = tempDimension.width
      ..height = tempDimension.height
      ..type = tempType
      ..size = Int64(tempFileSize)
      ..name = path.split('/').last
      ..duration = -1;

    await _fileRepo.cloneFileInLocalDirectory(
        file, packetId, file.path.split('/').last);

    MessagesCompanion message = MessagesCompanion.insert(
        roomId: room.asString(),
        packetId: packetId,
        time: now(),
        from: _accountRepo.currentUserUid.asString(),
        to: room.asString(),
        replyToId: Value(replyToId),
        type: MessageType.FILE,
        json: sendingFakeFile.writeToJson());

    // Insert in messages table
    int dbId = await _messageDao.insertMessageCompanion(message);

    // Insert in pending messages table
    await _savePendingMessage(
        room.asString(), dbId, packetId, SendingStatus.SENDING_FILE);

    // Send File
    await _sendFileToServerOfPendingMessage(dbId);

    // Send message
    await _sendMessageToServer(dbId);
  }

  _sendFileToServerOfPendingMessage(int dbId) async {
    var message = await _messageDao.getPendingMessage(dbId);
    var pendingMessage = await _pendingMessageDao.getByMessageDbId(dbId);

    if (!_canPendingMessageResendAndDecreaseRemainingRetries(
            pendingMessage, message) ||
        pendingMessage.status != SendingStatus.SENDING_FILE) {
      return;
    }

    var fakeFileInfo = FileProto.File.fromJson(message.json);

    var packetId = message.packetId;
    var roomId = message.roomId;

    // Upload to file server
    FileProto.File fileInfo =
        await _fileRepo.uploadClonedFile(packetId, fakeFileInfo.name);

    fileInfo.caption = fakeFileInfo.caption;

    var newJson = fileInfo.writeToJson();

    // Update in messages table
    await _messageDao.updateMessageTimeAndJson(roomId, dbId, newJson);

    // Update pending messages table
    await _savePendingMessage(roomId, dbId, packetId, SendingStatus.PENDING);

    // Update last message id of room
    _updateRoomLastMessage(
      roomId,
      dbId,
    );
  }

  _sendMessageToServer(int dbId) async {
    var message = await _messageDao.getPendingMessage(dbId);
    var pendingMessage = await _pendingMessageDao.getByMessageDbId(dbId);

    if (!_canPendingMessageResendAndDecreaseRemainingRetries(
            pendingMessage, message) ||
        pendingMessage.status != SendingStatus.PENDING) {
      return;
    }

    MessageProto.MessageByClient byClient = _createMessageByClient(message);

    if (message.replyToId != null)
      byClient.replyToId = Int64(message.replyToId);
    else
      byClient.replyToId = Int64(-1);

    if (message.forwardedFrom != null)
      byClient.forwardFrom = message.forwardedFrom.getUid();

    print("^^^^^^^^^^^^^^^^^^^^^^^^^^");
    print(byClient);

    _coreServices.sendMessage(byClient);
  }

  bool _canPendingMessageResendAndDecreaseRemainingRetries(
      PendingMessage pendingMessage, Message message) {
    if (pendingMessage == null) {
      if (message != null) {
        _messageDao.deleteMessage(message);
      }
      return false;
    }
    if (message == null) {
      _pendingMessageDao.deletePendingMessage(message.packetId);
      return false;
    }
    if (pendingMessage.remainingRetries > 0) {
      if (message.id == null) {
        _pendingMessageDao.insertPendingMessage(pendingMessage.copyWith(
            remainingRetries: pendingMessage.remainingRetries - 1));
        return true;
      } else
        _pendingMessageDao.deletePendingMessage(message.packetId);
    } else {
      _messageDao.deleteMessage(message);
      _pendingMessageDao.deletePendingMessage(message.packetId);
    }
    return false;
  }

  MessageProto.MessageByClient _createMessageByClient(Message message) {
    MessageProto.MessageByClient byClient = MessageProto.MessageByClient()
      ..packetId = message.packetId
      ..to = message.to.getUid();

    switch (message.type) {
      case MessageType.TEXT:
        byClient.text = MessageProto.Text.fromJson(message.json);
        break;
      case MessageType.FILE:
        byClient.file = FileProto.File.fromJson(message.json);
        break;
      default:
        break;
    }
    return byClient;
  }

  sendFileMessageDeprecated(Uid room, List<String> filesPath,
      {String caption, int replyToId}) async {
    for (var path in filesPath) {
      await sendFileMessage(room, path, caption: caption, replyToId: replyToId);
    }
  }

  _sendPendingMessages() async {
    List<PendingMessage> pendingMessages =
        await _pendingMessageDao.getAllPendingMessages();
    for (var pendingMessage in pendingMessages) {
      switch (pendingMessage.status) {
        case SendingStatus.SENDING_FILE:
          var dbId = pendingMessage.messageDbId;
          await _sendFileToServerOfPendingMessage(dbId);

          await _sendMessageToServer(dbId);

          break;
        case SendingStatus.PENDING:
          await _sendMessageToServer(pendingMessage.messageDbId);
          break;
      }
    }
  }

  _savePendingMessage(String roomId, int messageDbId, String messagePacketId,
      SendingStatus status) async {
    PendingMessage pendingMessage = PendingMessage(
      messageDbId: messageDbId,
      messagePacketId: messagePacketId,
      roomId: roomId,
      remainingRetries: MAX_REMAINING_RETRIES,
      status: status,
    );
    _pendingMessageDao.insertPendingMessage(pendingMessage);
  }

  sendSeenMessage(int messageId, Uid to, Uid roomId) {
    _coreServices.sendSeenMessage(SeenByClient()
      ..to = to
      ..id = Int64.parseInt(messageId.toString()));
  }

  _updateRoomLastMessage(String roomId, int dbId) async {
    await _roomDao.updateRoomLastMessage(roomId, dbId);
  }

  sendForwardedMessage(Uid room, List<Message> forwardedMessage) async {
    for (Message forwardedMessage in forwardedMessage) {
      String packetId = _getPacketId();

      int dbId = await _messageDao.insertMessage(Message(
          roomId: room.asString(),
          packetId: packetId,
          time: now(),
          type: forwardedMessage.type,
          from: _accountRepo.currentUserUid.asString(),
          to: room.asString(),
          forwardedFrom: forwardedMessage.from,
          json: forwardedMessage.json));

      _savePendingMessage(
          room.asString(), dbId, packetId, SendingStatus.PENDING);

      _updateRoomLastMessage(
        room.asString(),
        dbId,
      );

      // Send Message
      _sendMessageToServer(dbId);
    }
  }

  getPendingMessage(int dbId) async {
    return await _messageDao.getPendingMessage(dbId);
  }

  deleteMessage(List<Message> messages) {}

  String _getPacketId() {
    return now().microsecondsSinceEpoch.toString();
  }

  Future<List<Message>> getPage(int page, String roomId, int containsId,
      {int pageSize = 50}) async {
    var completer = _completerMap["$roomId-$page"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }

    completer = new Completer();
    _completerMap["$roomId-$page"] = completer;

    _messageDao.getPage(roomId, page).then((messages) async {
      if (messages.any((element) => element.id == containsId)) {
        completer.complete(messages);
      } else {
        try {
          var fetchMessagesRes = await _queryServiceClient.fetchMessages(
              FetchMessagesReq()
                ..roomUid = roomId.uid
                ..pointer = Int64(containsId)
                ..type = FetchMessagesReq_Type.FORWARD_FETCH
                ..limit = pageSize,
              options: CallOptions(metadata: {
                'accessToken': await _accountRepo.getAccessToken()
              }));
          completer
              .complete(await _saveFetchMessages(fetchMessagesRes.messages));
        } catch (e) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  Future<List<Message>> _saveFetchMessages(
      List<MessageProto.Message> messages) async {
    List<Message> msgList = [];
    for (MessageProto.Message message in messages) {
      msgList.add(await _coreServices.saveMessageInMessagesDB(message));
    }
    return msgList;
  }

  String _findType(String path) {
    return mime(path) ?? "application/octet-stream";
  }
}
