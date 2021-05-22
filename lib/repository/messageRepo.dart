import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' as DartFile;
import 'dart:math';

import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart'
    as protoModel;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:flutter/foundation.dart';
import 'mucRepo.dart';

enum TitleStatusConditions { Disconnected, Updating, Normal, Connecting }

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
  var _seenDao = GetIt.I.get<SeenDao>();
  var _lastSeenDao = GetIt.I.get<LastSeenDao>();

  var _coreServices = GetIt.I.get<CoreServices>();

  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  BehaviorSubject<TitleStatusConditions> updatingStatus =
      BehaviorSubject.seeded(TitleStatusConditions.Disconnected);

  MessageRepo() {
    _coreServices.connectionStatus.listen((mode) {
      switch (mode) {
        case ConnectionStatus.Connected:
          print('updating -----------------');
          updating();
          sendPendingMessages();
          break;
        case ConnectionStatus.Disconnected:
          updatingStatus.add(TitleStatusConditions.Disconnected);
          break;
        case ConnectionStatus.Connecting:
          updatingStatus.add(TitleStatusConditions.Connecting);
          break;
      }
    });
  }

  var _completerMap = Map<String, Completer<List<Message>>>();

  // TODO: Refactor Needed
  @visibleForTesting
  updating() async {
    updatingStatus.add(TitleStatusConditions.Updating);
    try {
      var getAllUserRoomMetaRes = await _queryServiceClient.getAllUserRoomMeta(
          GetAllUserRoomMetaReq(),
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      for (RoomMetadata roomMetadata in getAllUserRoomMetaRes.roomsMeta) {
      
        //   baae6e7c-d880-4dd0-948e-f6b5d38a74d0
        var room =
            await _roomDao.getByRoomIdFuture(roomMetadata.roomUid.asString());
        if (room != null &&
            room.lastMessageId != null &&
            room.lastMessageId >= roomMetadata.lastMessageId.toInt() &&
            room.lastMessageId != 0) {
          continue;
        }
        try {
          var fetchMessagesRes = await _queryServiceClient.fetchMessages(
              FetchMessagesReq()
                ..roomUid = roomMetadata.roomUid
                ..pointer = roomMetadata.lastMessageId
                ..type = FetchMessagesReq_Type.FORWARD_FETCH
                ..limit = 2,
              options: CallOptions(timeout: Duration(seconds: 1), metadata: {
                'access_token': await _accountRepo.getAccessToken()
              }));
          List<Message> messages =
              await _saveFetchMessages(fetchMessagesRes.messages);

          // TODO if there is Pending Message this line has a bug!!
          if (messages.isNotEmpty) {
            _roomDao.insertRoomCompanion(RoomsCompanion.insert(
                roomId: roomMetadata.roomUid.asString(),
                lastMessageId: Value(messages.last.id),
                lastMessageDbId: Value(messages.last.dbId)));
          }

          fetchLastSeen(roomMetadata);

          if (room != null &&
              room.roomId.getUid().category == Categories.GROUP) {
            getMentions(room);
          }
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }
    updatingStatus.add(TitleStatusConditions.Normal);
    getBlockedRoom();
  }

  Future fetchLastSeen(RoomMetadata room) async {
    try {
      var fetchCurrentUserSeenData =
          await _queryServiceClient.fetchCurrentUserSeenData(
              FetchCurrentUserSeenDataReq()..roomUid = room.roomUid,
              options: CallOptions(metadata: {
                "access_token": await _accountRepo.getAccessToken()
              }));

      _lastSeenDao.insertLastSeen(LastSeen(
          roomId: room.roomUid.asString(),
          messageId: max(fetchCurrentUserSeenData.seen.id.toInt(),
              room.lastCurrentUserSentMessageId.toInt())));
    } catch (e) {
      print(e.toString());
    }
    if (room.roomUid.category == Categories.USER ||
        room.roomUid.category == Categories.GROUP) {
      var fetchLastOtherUserSeenData =
          await _queryServiceClient.fetchLastOtherUserSeenData(
              FetchLastOtherUserSeenDataReq()..roomUid = room.roomUid,
              options: CallOptions(metadata: {
                "access_token": await _accountRepo.getAccessToken()
              }));
      _seenDao.insertSeen(SeensCompanion(
          roomId: Value(room.roomUid.asString()),
          messageId: Value(fetchLastOtherUserSeenData.seen.id.toInt()),
          user: Value(fetchLastOtherUserSeenData.seen.from.asString())));
    }
  }

  Future getMentions(Room room) async {
    try {
      var mentionResult = await _queryServiceClient.fetchMentionList(
          FetchMentionListReq()
            ..group = room.roomId.getUid()
            ..afterId = Int64.parseInt(room.lastMessageId.toString()),
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      if (mentionResult.idList != null && mentionResult.idList.length > 0) {
        _roomDao.insertRoomCompanion(
            RoomsCompanion(roomId: Value(room.roomId), mentioned: Value(true)));
      }
    } catch (e) {
      e.toString();
    }
  }

  getBlockedRoom() async {
    var result = await _queryServiceClient.getBlockedList(GetBlockedListReq(),
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    for (var blockRoomUid in result.uidList) {
      _roomDao.insertRoomCompanion(RoomsCompanion(
          roomId: Value(blockRoomUid.asString()), isBlock: Value(true)));
    }
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
    await _savePendingMessage(
        room.asString(), dbId, packetId, SendingStatus.PENDING);
    _updateRoomLastMessage(
      room.asString(),
      dbId,
    );
    // Send Message
    await _sendMessageToServer(dbId);
  }

  sendLocationMessage(Position locationData, Uid room,
      {String forwardedFromAsString}) async {
    String packetId = _getPacketId();
    String json = (protoModel.Location()
          ..longitude = locationData.longitude
          ..latitude = locationData.latitude)
        .writeToJson();
    MessagesCompanion message = MessagesCompanion.insert(
      roomId: room.asString(),
      packetId: packetId,
      time: now(),
      from: _accountRepo.currentUserUid.asString(),
      to: room.asString(),
      forwardedFrom: Value(forwardedFromAsString),
      type: MessageType.LOCATION,
      json: json,
    );

    int dbId = await _messageDao.insertMessageCompanion(message);
    await _savePendingMessage(
        room.asString(), dbId, packetId, SendingStatus.PENDING);
    _updateRoomLastMessage(
      room.asString(),
      dbId,
    );
    // Send Message
    await _sendMessageToServer(dbId);
  }

  sendFileMessage(Uid room, String path,
      {String caption = "", int replyToId = 0}) async {
    String packetId = _getPacketId();
    _fileRepo.initUploadProgress(packetId);

    // Create MessageCompanion
    var file = DartFile.File(path);
    final tempType = _findType(path);
    var tempDimension = Size.zero;
    // Get size of image
    if (tempType.split('/')[0] == 'image') {
      tempDimension = ImageSizeGetter.getSize(FileInput(file));
      if (tempDimension == Size.zero) {
        tempDimension = Size(200, 200);
      }
    }

    // Get type with file name
    final tempFileSize = file.statSync().size;

    FileProto.File sendingFakeFile = FileProto.File()
      ..uuid = packetId
      ..caption = caption ?? ""
      ..width = tempDimension.width
      ..height = tempDimension.height
      ..type = tempType
      ..size = Int64(tempFileSize)
      ..name = path.split(".").last
      ..duration = 0;

    await _fileRepo.cloneFileInLocalDirectory(
        file, packetId, path.split('.').last);

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
    sendActivityMessage(message.to.value.getUid(), ActivityType.NO_ACTIVITY);
  }

  sendStickerMessage(
      {Uid roomUid,
      Sticker sticker,
      int replyId,
      String forwardedFromAsString}) async {
    FileProto.File sendingFakeFile = FileProto.File()
      ..uuid = sticker.uuid
      ..type = "image"
      ..name = sticker.name
      ..duration = 0;
    String packetId = _getPacketId();
    MessagesCompanion message = MessagesCompanion.insert(
      roomId: roomUid.asString(),
      packetId: packetId,
      time: now(),
      from: _accountRepo.currentUserUid.asString(),
      to: roomUid.asString(),
      replyToId: replyId != null ? Value(replyId) : Value.absent(),
      forwardedFrom: Value(forwardedFromAsString),
      type: MessageType.STICKER,
      json: sendingFakeFile.writeToJson(),
    );

    int dbId = await _messageDao.insertMessageCompanion(message);
    await _savePendingMessage(
        roomUid.asString(), dbId, packetId, SendingStatus.PENDING);
    _updateRoomLastMessage(
      roomUid.asString(),
      dbId,
    );
    // Send Message
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
    FileProto.File fileInfo = await _fileRepo
        .uploadClonedFile(packetId, fakeFileInfo.name, sendActivity: () {
      sendActivityMessage(message.to.uid, ActivityType.SENDING_FILE);
    });

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

  _sendMessageToServer(int dbId,{bool resend = false}) async {
    var message = await _messageDao.getPendingMessage(dbId);
    var pendingMessage = await _pendingMessageDao.getByMessageDbId(dbId);
    if (!resend && !_canPendingMessageResendAndDecreaseRemainingRetries(
            pendingMessage, message) ||
        pendingMessage.status != SendingStatus.PENDING) {
      return;
    }

    MessageProto.MessageByClient byClient = _createMessageByClient(message);

    if (message.replyToId != null)
      byClient.replyToId = Int64(message.replyToId);
    else
      byClient.replyToId = Int64(0);

    if (message.forwardedFrom != null)
      byClient.forwardFrom = message.forwardedFrom.getUid();
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
      _pendingMessageDao.deletePendingMessage(pendingMessage.messagePacketId);
      return false;
    }
    if(pendingMessage.remainingRetries<2){
      _messageDao.updateMessage(message.copyWith(sendingFailed: true));
      return false;
    }
    if (pendingMessage.remainingRetries > 0) {
      if (message.id == null) {
        if(pendingMessage.remainingRetries<3){
          _messageDao.updateMessage(message.copyWith(sendingFailed: true));
        }
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
      case MessageType.LOCATION:
        byClient.location = protoModel.Location.fromJson(message.json);
        break;
      case MessageType.STICKER:
        byClient.sticker = FileProto.File.fromJson(message.json);
        break;
      case MessageType.FORM_RESULT:
        byClient.formResult = FormResult.fromJson(message.json);
        break;
      case MessageType.SHARE_UID:
        byClient.shareUid = MessageProto.ShareUid.fromJson(message.json);
        break;
      case MessageType.sharePrivateDataAcceptance:
        byClient.sharePrivateDataAcceptance =
            SharePrivateDataAcceptance.fromJson(message.json);
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

  @visibleForTesting
  sendPendingMessages() async {
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

  sendSeenMessage(int messageId, Uid to) {
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
      {int pageSize = 20}) async {
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
                ..pointer = Int64(page * pageSize)
                ..type = FetchMessagesReq_Type.FORWARD_FETCH
                ..limit = pageSize,
              options: CallOptions(metadata: {
                'access_token': await _accountRepo.getAccessToken()
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
      // ignore: unrelated_type_equality_checks
      try{
        if (message.whichType() == MessageProto.Message_Type.persistEvent){
          switch(message.persistEvent.whichType()){
            case PersistentEvent_Type.mucSpecificPersistentEvent:
              switch(message.persistEvent.mucSpecificPersistentEvent.issue){
                case  MucSpecificPersistentEvent_Issue.DELETED:
                  _roomDao.updateRoom(RoomsCompanion(roomId:Value( message.from.asString()),deleted: Value(true)));
                  continue;
                  break;
                case MucSpecificPersistentEvent_Issue.KICK_USER:
                  if(message.persistEvent.mucSpecificPersistentEvent.assignee.isSameEntity(_accountRepo.currentUserUid.asString())){
                    _roomDao.updateRoom(RoomsCompanion(roomId:Value( message.from.asString()),deleted: Value(true)));
                    continue;
                  }
                  break;
              }
              break;
          }

        }else{
          print(e.toString());
        }
      }catch(e){
        print(e.toString());
      }

      msgList.add(
          await saveMessageInMessagesDB(_accountRepo, _messageDao, message));

    }
    return msgList;
  }

  String _findType(String path) {
    return mime(path) ?? "application/octet-stream";
  }

  void setCoreSetting() {
    _coreServices.sendPingMessage();
  }

  void sendActivityMessage(Uid to, ActivityType activityType) {
    if (to.category == Categories.GROUP || to.category == Categories.USER) {
      ActivityByClient activityByClient = ActivityByClient()
        ..typeOfActivity = activityType
        ..to = to;
      _coreServices.sendActivityMessage(activityByClient, _getPacketId());
    }
  }

  void sendFormMessage(
      String botUid, Map<String, String> formResultMap, int formMessageId,
      {String forwardFromAsString}) async {
    String packetId = _getPacketId();
    FormResult formResult = FormResult();
    for (var fileId in formResultMap.keys) {
      formResult.values[fileId] = formResultMap[fileId];
    }

    String jsonString = (formResult).writeToJson();
    MessagesCompanion message = MessagesCompanion.insert(
      roomId: botUid,
      packetId: packetId,
      time: now(),
      from: _accountRepo.currentUserUid.asString(),
      to: botUid,
      replyToId: Value(formMessageId),
      forwardedFrom: Value(forwardFromAsString),
      type: MessageType.FORM_RESULT,
      json: jsonString,
    );

    int dbId = await _messageDao.insertMessageCompanion(message);
    await _savePendingMessage(botUid, dbId, packetId, SendingStatus.PENDING);
    _updateRoomLastMessage(
      botUid,
      dbId,
    );
    // Send Message
    await _sendMessageToServer(dbId);
  }

  void sendShareUidMessage(Uid room, MessageProto.ShareUid shareUid) async {
    String packetId = _getPacketId();
    String json = shareUid.writeToJson();
    MessagesCompanion message = MessagesCompanion.insert(
      roomId: room.asString(),
      packetId: packetId,
      time: now(),
      from: _accountRepo.currentUserUid.asString(),
      to: room.asString(),
      replyToId: Value.absent(),
      type: MessageType.SHARE_UID,
      json: json,
    );

    int dbId = await _messageDao.insertMessageCompanion(message);
    await _savePendingMessage(
        room.asString(), dbId, packetId, SendingStatus.PENDING);
    _updateRoomLastMessage(
      room.asString(),
      dbId,
    );
    // Send Message
    await _sendMessageToServer(dbId);
  }

  Future<List<Message>> searchMessage(String str, String roomId) async {
    return _messageDao.searchMessage(str, roomId);
  }

  void sendPrivateMessageAccept(Uid to, PrivateDataType privateDataType) async {
    SharePrivateDataAcceptance sharePrivateDataAcceptance =
        SharePrivateDataAcceptance()..data = privateDataType;
    String json = sharePrivateDataAcceptance.writeToJson();
    String packetId = _getPacketId();
    MessagesCompanion message = MessagesCompanion.insert(
      roomId: to.asString(),
      packetId: packetId,
      time: now(),
      from: _accountRepo.currentUserUid.asString(),
      to: to.asString(),
      replyToId: Value.absent(),
      type: MessageType.sharePrivateDataAcceptance,
      json: json,
    );

    int dbId = await _messageDao.insertMessageCompanion(message);
    await _savePendingMessage(
        to.asString(), dbId, packetId, SendingStatus.PENDING);
    _updateRoomLastMessage(
      to.asString(),
      dbId,
    );
    // Send Message
    await _sendMessageToServer(dbId);
  }

  void ResendMessage(Message message) async{
    await _sendMessageToServer(message.dbId,resend: true);
    _updateRoomLastMessage(message.roomId, message.dbId);
  }
}
