import 'dart:async';

import 'dart:io' as DartFile;
import 'dart:math';

import 'package:deliver_flutter/box/dao/message_dao.dart';
import 'package:deliver_flutter/box/dao/room_dao.dart';
import 'package:deliver_flutter/box/dao/seen_dao.dart';
import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/pending_message.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/box/sending_status.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/services/muc_services.dart';
import 'package:deliver_flutter/shared/constants.dart';
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
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart'
    as ProtocolSeen;
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';

enum TitleStatusConditions { Disconnected, Updating, Normal, Connecting }

class MessageRepo {
  final _logger = GetIt.I.get<Logger>();
  final _messageDao = GetIt.I.get<MessageDao>();

  // migrate to room repo
  final _roomDao = GetIt.I.get<RoomDao>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _mucServices = GetIt.I.get<MucServices>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _queryServiceClient = GetIt.I.get<QueryServiceClient>();
  final _sharedDao = GetIt.I.get<SharedDao>();

  final updatingStatus =
      BehaviorSubject.seeded(TitleStatusConditions.Disconnected);

  MessageRepo() {
    _coreServices.connectionStatus.listen((mode) async {
      switch (mode) {
        case ConnectionStatus.Connected:
          _logger.i('updating -----------------');

          updatingStatus.add(TitleStatusConditions.Updating);
          await updatingMessages();
          await updatingLastSeen();
          updatingStatus.add(TitleStatusConditions.Normal);

          sendPendingMessages();

          _roomRepo.fetchBlockedRoom();
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

  updateNewMuc(Uid roomUid, int lastMessageId) async {
    try {
      var fetchMessagesRes =
          await _queryServiceClient.fetchMessages(FetchMessagesReq()
            ..roomUid = roomUid
            ..pointer = Int64(lastMessageId)
            ..type = FetchMessagesReq_Type.BACKWARD_FETCH
            ..limit = 2);
      List<Message> messages =
          await _saveFetchMessages(fetchMessagesRes.messages);

      // TODO if there is Pending Message this line has a bug!!
      if (messages.isNotEmpty) {
        _roomDao.updateRoom(Room(
          uid: roomUid.asString(),
          lastMessage: messages.last,
        ));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  @visibleForTesting
  Future<void> updatingMessages() async {
    bool finished = false;
    int pointer = 0;
    var fetchAllRoom = await _sharedDao.get(SHARED_DAO_FETCH_ALL_ROOM);

    while (!finished && pointer < 10000) {
      try {
        var getAllUserRoomMetaRes =
            await _queryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq()
              ..pointer = pointer
              ..limit = 10);

        finished = getAllUserRoomMetaRes.finished;
        if (finished) _sharedDao.put(SHARED_DAO_FETCH_ALL_ROOM, "true");

        for (RoomMetadata roomMetadata in getAllUserRoomMetaRes.roomsMeta) {
          var room = await _roomDao.getRoom(roomMetadata.roomUid.asString());
          if (room != null &&
              room.lastMessage != null &&
              room.lastMessage.id != null &&
              room.lastMessage.id >= roomMetadata.lastMessageId.toInt() &&
              room.lastMessage.id != 0) {
            if (fetchAllRoom != null)
              finished = true; // no more updating needed after this room
            break;
          }
          fetchLastMessages(roomMetadata, room);
        }
      } catch (e) {
        _logger.e(e);
      }
      pointer += 10;
    }
  }

  Future<void> updatingLastSeen() async {
    var rooms = await _roomDao.getAllRooms();

    rooms.forEach((r) async {
      var category = r.lastMessage.to.asUid().category;
      if (r.lastMessage.id == null) return;
      if (!_authRepo.isCurrentUser(r.lastMessage.from) &&
          (category == Categories.GROUP || category == Categories.USER)) {
        var othersSeen = await _seenDao.getOthersSeen(r.lastMessage.to);
        if (othersSeen == null || othersSeen.messageId < r.lastMessage.id) {
          var rm = await _queryServiceClient.getUserRoomMeta(
              GetUserRoomMetaReq()..roomUid = r.uid.asUid());
          fetchLastSeen(rm.roomMeta);
        }
      }
    });
  }

  Future<void> fetchLastMessages(RoomMetadata roomMetadata, Room room,
      {bool retry = true}) async {
    try {
      var fetchMessagesRes = await _queryServiceClient.fetchMessages(
          FetchMessagesReq()
            ..roomUid = roomMetadata.roomUid
            ..pointer = roomMetadata.lastMessageId
            ..type = FetchMessagesReq_Type.FORWARD_FETCH
            ..limit = 2,
          options: CallOptions(timeout: Duration(seconds: 3)));
      List<Message> messages =
          await _saveFetchMessages(fetchMessagesRes.messages);

      if (messages.isNotEmpty) {
        _roomDao.updateRoom(Room(
          uid: roomMetadata.roomUid.asString(),
          lastMessage: messages.last,
        ));
      }

      if (room != null && room.uid.asUid().category == Categories.GROUP) {
        getMentions(room);
      }
    } catch (e) {
      _logger.e(e);
      if (retry) fetchLastMessages(roomMetadata, room, retry: false);
    }
  }

  Future<void> fetchLastSeen(RoomMetadata room) async {
    try {
      var fetchCurrentUserSeenData =
          await _queryServiceClient.fetchCurrentUserSeenData(
              FetchCurrentUserSeenDataReq()..roomUid = room.roomUid);

      var lastSeen = await _seenDao.getMySeen(room.roomUid.asString());
      if (lastSeen != null &&
          lastSeen.messageId >
              max(fetchCurrentUserSeenData.seen.id.toInt(),
                  room.lastCurrentUserSentMessageId.toInt())) return;
      _seenDao.saveMySeen(Seen(
          uid: room.roomUid.asString(),
          messageId: max(fetchCurrentUserSeenData.seen.id.toInt(),
              room.lastCurrentUserSentMessageId.toInt())));
    } catch (e) {
      _logger.e(e);
    }

    try {
      if (room.roomUid.category == Categories.USER ||
          room.roomUid.category == Categories.GROUP) {
        var fetchLastOtherUserSeenData =
            await _queryServiceClient.fetchLastOtherUserSeenData(
                FetchLastOtherUserSeenDataReq()..roomUid = room.roomUid);
        _seenDao.saveOthersSeen(Seen(
            uid: room.roomUid.asString(),
            messageId: fetchLastOtherUserSeenData.seen.id.toInt()));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future getMentions(Room room) async {
    try {
      var mentionResult =
          await _queryServiceClient.fetchMentionList(FetchMentionListReq()
            ..group = room.uid.asUid()
            ..afterId = Int64.parseInt(room.lastMessage.id.toString()));
      if (mentionResult.idList != null && mentionResult.idList.length > 0) {
        _roomDao.updateRoom(Room(uid: room.uid, mentioned: true));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendTextMessage(Uid room, String text,
      {int replyId, String forwardedFrom}) async {
    String json = (MessageProto.Text()..text = text).writeToJson();
    Message msg =
        _createMessage(room, replyId: replyId, forwardedFrom: forwardedFrom)
            .copyWith(type: MessageType.TEXT, json: json);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  _saveAndSend(PendingMessage pm) {
    _savePendingMessage(pm);
    _updateRoomLastMessage(pm);
    _sendMessageToServer(pm);
  }

  sendLocationMessage(Position locationData, Uid room,
      {String forwardedFrom, int replyId}) async {
    String json = (protoModel.Location()
          ..longitude = locationData.longitude
          ..latitude = locationData.latitude)
        .writeToJson();

    Message msg =
        _createMessage(room, replyId: replyId, forwardedFrom: forwardedFrom)
            .copyWith(type: MessageType.LOCATION, json: json);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  sendMultipleFilesMessages(Uid room, List<String> filesPath,
      {String caption, int replyToId}) async {
    for (var path in filesPath) {
      await sendFileMessage(room, path, caption: caption, replyToId: replyToId);
    }
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

    Message msg = _createMessage(room, replyId: replyToId).copyWith(
        packetId: packetId,
        type: MessageType.FILE,
        json: sendingFakeFile.writeToJson());

    await _fileRepo.cloneFileInLocalDirectory(
        file, packetId, path.split('.').last);


    var pm = _createPendingMessage(msg, SendingStatus.SENDING_FILE);

    await _savePendingMessage(pm);

    var m = await _sendFileToServerOfPendingMessage(pm);

    await _sendMessageToServer(m);
  }

  sendStickerMessage(
      {Uid room,
      Sticker sticker,
      int replyId,
      String forwardedFromAsString}) async {
    // FileProto.File sendingFakeFile = FileProto.File()
    //   ..uuid = sticker.uuid
    //   ..type = "image"
    //   ..name = sticker.name
    //   ..duration = 0;
    //
    // Message msg = _createMessage(room,
    //         replyId: replyId, forwardedFrom: forwardedFromAsString)
    //     .copyWith(
    //         type: MessageType.STICKER, json: sendingFakeFile.writeToJson());
    //
    // var pm = _createPendingMessage(msg, SendingStatus.PENDING);
    // _saveAndSend(pm);
  }

  Future<PendingMessage> _sendFileToServerOfPendingMessage(
      PendingMessage pm) async {
    var fakeFileInfo = FileProto.File.fromJson(pm.msg.json);

    var packetId = pm.msg.packetId;

    // Upload to file server
    FileProto.File fileInfo = await _fileRepo
        .uploadClonedFile(packetId, fakeFileInfo.name, sendActivity: () {
      sendActivity(pm.msg.to.asUid(), ActivityType.SENDING_FILE);
    });

    fileInfo.caption = fakeFileInfo.caption;

    var newJson = fileInfo.writeToJson();

    var newPm = pm.copyWith(
        msg: pm.msg.copyWith(json: newJson), status: SendingStatus.PENDING);

    // Update pending messages table
    await _savePendingMessage(newPm);

    _updateRoomLastMessage(newPm);
    return newPm;
  }

  _sendMessageToServer(PendingMessage pm) async {
    MessageProto.MessageByClient byClient = _createMessageByClient(pm.msg);

    _coreServices.sendMessage(byClient);
    // TODO remove later, we don't need send no activity after sending messages, every time we received message we should set activity of room as no activity
    sendActivity(byClient.to, ActivityType.NO_ACTIVITY);
  }

  MessageProto.MessageByClient _createMessageByClient(Message message) {
    MessageProto.MessageByClient byClient = MessageProto.MessageByClient()
      ..packetId = message.packetId
      ..to = message.to.asUid();

    if (message.replyToId != null)
      byClient.replyToId = Int64(message.replyToId);
    else
      byClient.replyToId = Int64(0);

    if (message.forwardedFrom != null)
      byClient.forwardFrom = message.forwardedFrom.asUid();

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
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        byClient.sharePrivateDataAcceptance =
            SharePrivateDataAcceptance.fromJson(message.json);
        break;
      default:
        break;
    }
    return byClient;
  }

  @visibleForTesting
  sendPendingMessages() async {
    List<PendingMessage> pendingMessages =
        await _messageDao.getAllPendingMessages();
    for (var pendingMessage in pendingMessages) {
      if (!pendingMessage.failed)
        switch (pendingMessage.status) {
          case SendingStatus.SENDING_FILE:
            await _sendFileToServerOfPendingMessage(pendingMessage);
            await _sendMessageToServer(pendingMessage);
            break;
          case SendingStatus.PENDING:
            await _sendMessageToServer(pendingMessage);
            break;
        }
    }
  }

  PendingMessage _createPendingMessage(Message msg, SendingStatus status) {
    return PendingMessage(
      roomUid: msg.roomUid,
      packetId: msg.packetId,
      msg: msg,
      status: status,
    );
  }

  _savePendingMessage(PendingMessage pm) async {
    _messageDao.savePendingMessage(pm);
  }

  sendSeen(int messageId, Uid to) {
    _coreServices.sendSeen(ProtocolSeen.SeenByClient()
      ..to = to
      ..id = Int64.parseInt(messageId.toString()));
  }

  _updateRoomLastMessage(PendingMessage pm) async {
    await _roomDao.updateRoom(Room(uid: pm.roomUid, lastMessage: pm.msg));
  }

  sendForwardedMessage(Uid room, List<Message> forwardedMessage) async {
    for (Message forwardedMessage in forwardedMessage) {
      Message msg = _createMessage(room, forwardedFrom: forwardedMessage.from)
          .copyWith(type: forwardedMessage.type, json: forwardedMessage.json);

      var pm = _createPendingMessage(msg, SendingStatus.PENDING);

      _saveAndSend(pm);
    }
  }

  Message _createMessage(Uid room, {int replyId, String forwardedFrom}) {
    return Message(
      roomUid: room.asString(),
      packetId: _getPacketId(),
      time: DateTime.now().millisecondsSinceEpoch,
      from: _authRepo.currentUserUid.asString(),
      to: room.asString(),
      replyToId: replyId,
      forwardedFrom: forwardedFrom,
    );
  }

  String _getPacketId() {
    return "${DateTime.now().microsecondsSinceEpoch.toString()}-${randomString(5)}";
  }

  Future<List<Message>> getPage(int page, String roomId, int containsId,
      {int pageSize = 40}) async {
    var completer = _completerMap["$roomId-$page"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = new Completer();
    _completerMap["$roomId-$page"] = completer;

    _messageDao.getMessagePage(roomId, page).then((messages) async {
      if (messages.any((element) => element.id == containsId)) {
        completer.complete(messages);
      } else {
        await getMessages(roomId, page, pageSize, completer);
      }
    });

    return completer.future;
  }

  Future<void> getMessages(
      String roomId, int page, int pageSize, Completer<List<Message>> completer,
      {bool retry = true}) async {
    try {
      var fetchMessagesRes =
          await _queryServiceClient.fetchMessages(FetchMessagesReq()
            ..roomUid = roomId.asUid()
            ..pointer = Int64(page * pageSize)
            ..type = FetchMessagesReq_Type.FORWARD_FETCH
            ..limit = pageSize);
      completer.complete(await _saveFetchMessages(fetchMessagesRes.messages));
    } catch (e) {
      _logger.e(e);
      if (retry)
        getMessages(roomId, page, pageSize, completer, retry: false);
      else
        completer.completeError(e);
    }
  }

  Future<List<Message>> _saveFetchMessages(
      List<MessageProto.Message> messages) async {
    List<Message> msgList = [];
    for (MessageProto.Message message in messages) {
      _messageDao.deletePendingMessage(message.packetId);
      try {
        if (message.whichType() == MessageProto.Message_Type.persistEvent) {
          switch (message.persistEvent.whichType()) {
            case PersistentEvent_Type.mucSpecificPersistentEvent:
              switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
                case MucSpecificPersistentEvent_Issue.DELETED:
                  _roomDao.updateRoom(
                      Room(uid: message.from.asString(), deleted: true));
                  continue;
                  break;
                case MucSpecificPersistentEvent_Issue.KICK_USER:
                  if (message.persistEvent.mucSpecificPersistentEvent.assignee
                      .isSameEntity(_authRepo.currentUserUid.asString())) {
                    _roomDao.updateRoom(
                        Room(uid: message.from.asString(), deleted: true));
                    continue;
                  }
                  break;
              }
              break;
            default:
              break;
          }
        } else {}
      } catch (e) {
        _logger.e(e);
      }
      msgList
          .add(await saveMessageInMessagesDB(_authRepo, _messageDao, message));
    }
    return msgList;
  }

  String _findType(String path) {
    return mime(path) ?? "application/octet-stream";
  }

  void setCoreSetting() {
    _coreServices.sendPing();
  }

  void sendActivity(Uid to, ActivityType activityType) {
    if (to.category == Categories.GROUP || to.category == Categories.USER) {
      ActivityByClient activityByClient = ActivityByClient()
        ..typeOfActivity = activityType
        ..to = to;
      _coreServices.sendActivity(activityByClient, _getPacketId());
    }
  }

  void sendFormResultMessage(
      String botUid, Map<String, String> formResultMap, int formMessageId,
      {String forwardFromAsString}) async {
    FormResult formResult = FormResult();
    for (var fileId in formResultMap.keys) {
      formResult.values[fileId] = formResultMap[fileId];
    }
    String jsonString = (formResult).writeToJson();

    Message msg = _createMessage(botUid.asUid(),
            replyId: formMessageId, forwardedFrom: forwardFromAsString)
        .copyWith(type: MessageType.FORM_RESULT, json: jsonString);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);

    _saveAndSend(pm);
  }

  void sendShareUidMessage(Uid room, MessageProto.ShareUid shareUid) async {
    String json = shareUid.writeToJson();

    Message msg =
        _createMessage(room).copyWith(type: MessageType.SHARE_UID, json: json);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  void sendPrivateMessageAccept(Uid to, PrivateDataType privateDataType,String token) async {
    SharePrivateDataAcceptance sharePrivateDataAcceptance =
        SharePrivateDataAcceptance()..data = privateDataType..token = token;
    String json = sharePrivateDataAcceptance.writeToJson();

    Message msg = _createMessage(to)
        .copyWith(type: MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE, json: json);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  Future<List<Message>> searchMessage(String str, String roomId) async {
    // TODO MIGRATION NEEDS
    return [];
  }

  Future<Message> getMessage(String roomUid, int id) =>
      _messageDao.getMessage(roomUid, id);

  Future<PendingMessage> getPendingMessage(String packetId) =>
      _messageDao.getPendingMessage(packetId);

  Stream<PendingMessage> watchPendingMessage(String packetId) =>
      _messageDao.watchPendingMessage(packetId);

  Stream<List<PendingMessage>> watchPendingMessages(String packetId) =>
      _messageDao.watchPendingMessages(packetId);

  void resendMessage(Message msg) async {
    var pm = await _messageDao.getPendingMessage(msg.packetId);
    _saveAndSend(pm);
  }

  void deletePendingMessage(Message message) {
    _messageDao.deletePendingMessage(message.packetId);
  }

  Future<bool> pinMessage(Message message) async {
    try {
      return await _mucServices.pinMessage(message);
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> unpinMessage(Message message) async {
    try {
      return await _mucServices.unpinMessage(message);
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }
}
