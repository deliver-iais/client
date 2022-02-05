// ignore_for_file: file_names, constant_identifier_names

import 'dart:async';

import 'dart:io' as dart_file;
import 'dart:math';

import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart'
    as location_pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';

import '../shared/constants.dart';

enum TitleStatusConditions { Disconnected, Updating, Normal, Connecting }

const EMPTY_MESSAGE = "{}";
const DELETED_ROOM_MESSAGE = "{DELETED}";

class MessageRepo {
  final _logger = GetIt.I.get<Logger>();
  final _messageDao = GetIt.I.get<MessageDao>();

  // migrate to room repo
  final _roomDao = GetIt.I.get<RoomDao>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _liveLocationRepo = GetIt.I.get<LiveLocationRepo>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _mucServices = GetIt.I.get<MucServices>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _queryServiceClient = GetIt.I.get<QueryServiceClient>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _blockDao = GetIt.I.get<BlockDao>();

  final updatingStatus =
      BehaviorSubject.seeded(TitleStatusConditions.Disconnected);

  MessageRepo() {
    _coreServices.connectionStatus.listen((mode) async {
      switch (mode) {
        case ConnectionStatus.Connected:
          _logger.i('updating -----------------');

          updatingStatus.add(TitleStatusConditions.Updating);
          await updatingMessages();
          updatingLastSeen();
          fetchBlockedRoom();
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

  final _completerMap = <String, Completer<List<Message?>>>{};

  updateNewMuc(Uid roomUid, int lastMessageId) async {
    try {
      _roomDao.updateRoom(Room(
        uid: roomUid.asString(),
        lastMessageId: lastMessageId,
        lastUpdateTime: DateTime.now().millisecondsSinceEpoch,
      ));
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
          if (room == null) {
            _seenDao.saveMySeen(
                Seen(uid: roomMetadata.roomUid.asString(), messageId: -1));
          }
          if (roomMetadata.presenceType == PresenceType.ACTIVE) {
            if (room != null &&
                room.lastMessage != null &&
                room.lastMessage!.id != null &&
                room.lastMessage!.id! >= roomMetadata.lastMessageId.toInt() &&
                room.lastMessage!.id != 0 &&
                room.lastUpdateTime != null &&
                room.lastUpdateTime! >= roomMetadata.lastUpdate.toInt()) {
              if (fetchAllRoom != null) {
                finished = true;
              } // no more updating needed after this room
              break;
            }
            if (room != null && room.deleted != null && room.deleted!) {
              _roomDao.updateRoom(Room(
                  uid: room.uid,
                  deleted: false,
                  lastMessageId: roomMetadata.lastMessageId.toInt(),
                  firstMessageId: roomMetadata.firstMessageId.toInt(),
                  lastUpdateTime: roomMetadata.lastUpdate.toInt()));
            }
            await fetchLastMessages(
              roomMetadata.roomUid,
              roomMetadata.lastMessageId.toInt(),
              roomMetadata.firstMessageId.toInt(),
              room,
              type: FetchMessagesReq_Type.BACKWARD_FETCH,
              limit: 2,
              lastUpdateTime: roomMetadata.lastUpdate.toInt(),
            );
            if (room != null &&
                room.lastMessageId != null &&
                roomMetadata.lastMessageId.toInt() > room.lastMessageId!) {
              fetchHiddenMessageCount(
                  roomMetadata.roomUid, room.lastMessageId!);
            }
            if (room != null && room.uid.asUid().category == Categories.GROUP) {
              getMentions(room);
            }
          } else {
            _roomDao.updateRoom(Room(
                uid: roomMetadata.roomUid.asString(),
                deleted: true,
                lastMessageId: roomMetadata.lastMessageId.toInt(),
                firstMessageId: roomMetadata.firstMessageId.toInt(),
                lastUpdateTime: roomMetadata.lastUpdate.toInt()));
          }
        }
      } catch (e) {
        _logger.e(e);
      }
      pointer += 10;
    }
  }

  Future<void> updatingLastSeen() async {
    var rooms = await _roomDao.getAllRooms();

    for (var r in rooms) {
      var category = r.lastMessage!.to.asUid().category;
      if (r.lastMessage!.id == null) return;
      if (!_authRepo.isCurrentUser(r.lastMessage!.from) &&
          (category == Categories.GROUP || category == Categories.USER)) {
        var rm = await _queryServiceClient
            .getUserRoomMeta(GetUserRoomMetaReq()..roomUid = r.uid.asUid());
        fetchCurrentUserLastSeen(rm.roomMeta);
      }
      var othersSeen = await _seenDao.getOthersSeen(r.lastMessage!.to);
      if (othersSeen == null || othersSeen.messageId < r.lastMessage!.id!) {
        fetchOtherSeen(r.uid.asUid());
      }
    }
  }

  Future<void> fetchHiddenMessageCount(Uid roomUid, int id) async {
    try {
      var res = await _queryServiceClient
          .countIsHiddenMessages(CountIsHiddenMessagesReq()
            ..roomUid = roomUid
            ..messageId = Int64(id + 1));
      var s = await _seenDao.getMySeen(roomUid.asString());
      _seenDao.saveMySeen(
          s.copy(newUid: roomUid.asString(), newHiddenMessageCount: res.count));
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<Message?> fetchLastMessages(
      Uid roomUid, int lastMessageId, int? firstMessageId, Room? room,
      {bool retry = true,
      int? lastUpdateTime,
      required FetchMessagesReq_Type type,
      required int limit}) async {
    bool lastMessageIsSet = false;
    int pointer = lastMessageId;
    Message? lastMessage;
    try {
      var msg = await _messageDao.getMessage(roomUid.asString(), pointer);
      while (!lastMessageIsSet) {
        try {
          if (msg != null) {
            if (firstMessageId != null && msg.id! <= firstMessageId) {
              lastMessageIsSet = true;
              lastMessage = msg.copyWith(json: DELETED_ROOM_MESSAGE);
              break;
            } else if (!msg.json.isEmptyMessage()) {
              lastMessageIsSet = true;
              lastMessage = msg;
              break;
            } else if (msg.id == 1) {
              lastMessage = msg.copyWith(json: DELETED_ROOM_MESSAGE);
              lastMessageIsSet = true;
              break;
            } else {
              pointer = pointer - 1;
              msg = await _messageDao.getMessage(roomUid.asString(), pointer);
            }
          } else {
            lastMessage = await getLastMessageFromServer(roomUid, lastMessageId,
                lastMessageId, type, limit, firstMessageId, lastUpdateTime);
            lastMessageIsSet = true;
            break;
          }
        } catch (e) {
          lastMessageIsSet = true;
          break;
        }
      }
      await _roomDao.updateRoom(Room(
        uid: roomUid.asString(),
        firstMessageId: firstMessageId != null ? firstMessageId.toInt() : 0,
        lastUpdateTime: lastMessage!.time,
        lastMessageId: lastMessageId,
        lastMessage: lastMessage,
      ));
      return lastMessage;
    } catch (e) {
      _roomDao.updateRoom(Room(
        uid: roomUid.asString(),
        firstMessageId: firstMessageId!.toInt(),
        lastUpdateTime: lastUpdateTime,
        lastMessageId: lastMessageId.toInt(),
      ));
      _logger.wtf(roomUid);
      _logger.wtf(room);

      _logger.e(e);
      return null;
    }
  }

  Future<Message> getLastMessageFromServer(
      Uid roomUid,
      int lastMessageId,
      int pointer,
      FetchMessagesReq_Type type,
      int limit,
      int? firstMessageId,
      int? lastUpdateTime) async {
    Message? lastMessage;
    var fetchMessagesRes = await _queryServiceClient.fetchMessages(
        FetchMessagesReq()
          ..roomUid = roomUid
          ..pointer = Int64(pointer)
          ..type = type
          ..limit = limit,
        options: CallOptions(timeout: const Duration(seconds: 3)));
    List<Message> messages =
        await _saveFetchMessages(fetchMessagesRes.messages);
    for (var element in messages) {
      if (firstMessageId != null && element.id! <= firstMessageId) {
        lastMessage = element.copyWith(json: DELETED_ROOM_MESSAGE);
        break;
      } else if (!element.json.isEmptyMessage()) {
        lastMessage = element;
        break;
      } else if (element.id == 1) {
        lastMessage = element.copyWith(json: DELETED_ROOM_MESSAGE);
      }
    }
    if (lastMessage != null) {
      return lastMessage;
    } else {
      return getLastMessageFromServer(
          roomUid,
          lastMessageId,
          pointer > limit ? pointer - limit : pointer,
          type,
          limit,
          firstMessageId,
          lastUpdateTime);
    }
  }

  Future<void> fetchOtherSeen(Uid roomUid) async {
    try {
      if (roomUid.category == Categories.USER ||
          roomUid.category == Categories.GROUP) {
        var fetchLastOtherUserSeenData =
            await _queryServiceClient.fetchLastOtherUserSeenData(
                FetchLastOtherUserSeenDataReq()..roomUid = roomUid);
        _seenDao.saveOthersSeen(Seen(
            uid: roomUid.asString(),
            messageId: fetchLastOtherUserSeenData.seen.id.toInt()));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> fetchCurrentUserLastSeen(RoomMetadata room) async {
    try {
      var fetchCurrentUserSeenData =
          await _queryServiceClient.fetchCurrentUserSeenData(
              FetchCurrentUserSeenDataReq()..roomUid = room.roomUid);

      var lastSeen = await _seenDao.getMySeen(room.roomUid.asString());
      if (lastSeen.messageId != -1 &&
          lastSeen.messageId >
              max(fetchCurrentUserSeenData.seen.id.toInt(),
                  room.lastCurrentUserSentMessageId.toInt())) return;
      _seenDao.saveMySeen(Seen(
          uid: room.roomUid.asString(),
          hiddenMessageCount: lastSeen.hiddenMessageCount ?? 0,
          messageId: max(fetchCurrentUserSeenData.seen.id.toInt(),
              room.lastCurrentUserSentMessageId.toInt())));
    } on GrpcError catch (e) {
      _logger.e(e);
      if (e.code == StatusCode.notFound) {
        _seenDao.saveMySeen(Seen(uid: room.roomUid.asString(), messageId: 0));
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
            ..afterId = Int64.parseInt(room.lastMessage!.id.toString()));
      if (mentionResult.idList.isNotEmpty) {
        _roomDao.updateRoom(Room(uid: room.uid, mentioned: true));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendTextMessage(Uid room, String text,
      {int? replyId, String? forwardedFrom}) async {
    final List<String> textsBlocks = text.split("\n").toList();
    final List<String> result = [];
    for (text in textsBlocks) {
      if (text.length > TEXT_MESSAGE_MAX_LENGTH) {
        int i = 0;
        while (i < (text.length / TEXT_MESSAGE_MAX_LENGTH).ceil()) {
          result.add(text.substring(i * TEXT_MESSAGE_MAX_LENGTH,
              min((i + 1) * TEXT_MESSAGE_MAX_LENGTH, text.length)));
          i++;
        }
      } else {
        result.add(text);
      }
    }

    int i = 0;
    while (i < (result.length / TEXT_MESSAGE_MAX_LINE).ceil()) {
      _sendTextMessage(
          result
              .sublist(i * TEXT_MESSAGE_MAX_LINE,
                  min((i + 1) * TEXT_MESSAGE_MAX_LINE, result.length))
              .join(),
          room,
          replyId,
          forwardedFrom);
      i++;
    }
  }

  void _sendTextMessage(
      String text, Uid room, int? replyId, String? forwardedFrom) {
    String json = (message_pb.Text()..text = text).writeToJson();
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
      {String? forwardedFrom, int? replyId}) async {
    String json = (location_pb.Location()
          ..longitude = locationData.longitude
          ..latitude = locationData.latitude)
        .writeToJson();

    Message msg =
        _createMessage(room, replyId: replyId, forwardedFrom: forwardedFrom)
            .copyWith(type: MessageType.LOCATION, json: json);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  sendMultipleFilesMessages(Uid room, List<model.File> files,
      {String? caption, int? replyToId}) async {
    for (var file in files) {
      if (files.last.path == file.path) {
        await sendFileMessage(room, file,
            caption: caption!, replyToId: replyToId);
      } else {
        await sendFileMessage(room, file, caption: "", replyToId: replyToId);
      }
    }
  }

  sendFileMessage(Uid room, model.File file,
      {String? caption = "", int? replyToId = 0}) async {
    String packetId = _getPacketId();
    var tempDimension = Size.zero;
    int? tempFileSize;
    final tempType = file.extension ?? _findType(file.path);
    _fileRepo.initUploadProgress(packetId);

    var f = dart_file.File(file.path);
    // Get size of image
    try {
      if (tempType.split('/')[0] == 'image' ||
          tempType.contains("jpg") ||
          tempType.contains("png")) {
        tempDimension = ImageSizeGetter.getSize(FileInput(f));
        if (tempDimension == Size.zero) {
          tempDimension = Size(200, 200);
        }
      }
      tempFileSize = f.statSync().size;
    } catch (_) {}

    // Create MessageCompanion

    // Get type with file name

    file_pb.File sendingFakeFile = file_pb.File()
      ..uuid = packetId
      ..caption = caption ?? ""
      ..width = tempDimension.width
      ..height = tempDimension.height
      ..type = tempType
      ..size = file.size != null ? Int64(file.size!) : Int64(tempFileSize!)
      ..name = file.name
      ..duration = 0;

    Message msg = _createMessage(room, replyId: replyToId).copyWith(
        packetId: packetId,
        type: MessageType.FILE,
        json: sendingFakeFile.writeToJson());

    await _fileRepo.cloneFileInLocalDirectory(f, packetId, file.name);

    var pm = _createPendingMessage(msg, SendingStatus.SENDING_FILE);

    await _savePendingMessage(pm);

    var m = await _sendFileToServerOfPendingMessage(pm);
    if (m != null) {
      await _sendMessageToServer(m);
    }
  }

  sendStickerMessage(
      {required Uid room,
      required Sticker sticker,
      int? replyId,
      String? forwardedFromAsString}) async {
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

  Future<PendingMessage?> _sendFileToServerOfPendingMessage(
      PendingMessage pm) async {
    BehaviorSubject<int> sendActivitySubject = BehaviorSubject.seeded(0);
    sendActivitySubject
        .throttleTime(const Duration(seconds: 10))
        .listen((value) {
      if (value != 0) {
        sendActivity(pm.msg.to.asUid(), ActivityType.SENDING_FILE);
      }
    });

    var fakeFileInfo = file_pb.File.fromJson(pm.msg.json);

    var packetId = pm.msg.packetId;

    // Upload to file server
    file_pb.File? fileInfo = await _fileRepo.uploadClonedFile(
        packetId, fakeFileInfo.name,
        sendActivity: (int i) => sendActivitySubject.add(i));
    if (fileInfo != null) {
      fileInfo.caption = fakeFileInfo.caption;

      var newJson = fileInfo.writeToJson();

      var newPm = pm.copyWith(
          msg: pm.msg.copyWith(json: newJson), status: SendingStatus.PENDING);

      // Update pending messages table
      await _savePendingMessage(newPm);

      _updateRoomLastMessage(newPm);
      return newPm;
    }
  }

  _sendMessageToServer(PendingMessage pm) async {
    message_pb.MessageByClient byClient = _createMessageByClient(pm.msg);

    _coreServices.sendMessage(byClient);
    // TODO remove later, we don't need send no activity after sending messages, every time we received message we should set activity of room as no activity
    sendActivity(byClient.to, ActivityType.NO_ACTIVITY);
  }

  message_pb.MessageByClient _createMessageByClient(Message message) {
    message_pb.MessageByClient byClient = message_pb.MessageByClient()
      ..packetId = message.packetId
      ..to = message.to.asUid();

    if (message.replyToId != null) {
      byClient.replyToId = Int64(message.replyToId!);
    } else {
      byClient.replyToId = Int64(0);
    }

    if (message.forwardedFrom != null) {
      byClient.forwardFrom = message.forwardedFrom!.asUid();
    }

    switch (message.type) {
      case MessageType.TEXT:
        byClient.text = message_pb.Text.fromJson(message.json);
        break;
      case MessageType.FILE:
        byClient.file = file_pb.File.fromJson(message.json);
        break;
      case MessageType.LOCATION:
        byClient.location = location_pb.Location.fromJson(message.json);
        break;
      case MessageType.STICKER:
        byClient.sticker = file_pb.File.fromJson(message.json);
        break;
      case MessageType.FORM_RESULT:
        byClient.formResult = FormResult.fromJson(message.json);
        break;
      case MessageType.SHARE_UID:
        byClient.shareUid = message_pb.ShareUid.fromJson(message.json);
        break;
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        byClient.sharePrivateDataAcceptance =
            SharePrivateDataAcceptance.fromJson(message.json);
        break;
      case MessageType.FORM:
        byClient.form = message.json.toForm();
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
      if (!pendingMessage.failed) {
        switch (pendingMessage.status) {
          case SendingStatus.SENDING_FILE:
            var pm = await _sendFileToServerOfPendingMessage(pendingMessage);
            if (pm != null) {
              await _sendMessageToServer(pm);
            }
            break;
          case SendingStatus.PENDING:
            await _sendMessageToServer(pendingMessage);
            break;
        }
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

  sendSeen(int messageId, Uid to) async {
    var seen = await _seenDao.getMySeen(to.asString());
    if (seen.messageId >= messageId) return;
    _coreServices.sendSeen(seen_pb.SeenByClient()
      ..to = to
      ..id = Int64.parseInt(messageId.toString()));
  }

  _updateRoomLastMessage(PendingMessage pm) async {
    await _roomDao.updateRoom(Room(
        uid: pm.roomUid,
        lastMessage: pm.msg,
        lastMessageId: pm.msg.id,
        deleted: false,
        lastUpdateTime: pm.msg.time));
  }

  sendForwardedMessage(Uid room, List<Message> forwardedMessage) async {
    for (Message forwardedMessage in forwardedMessage) {
      Message msg = _createMessage(room, forwardedFrom: forwardedMessage.from)
          .copyWith(type: forwardedMessage.type, json: forwardedMessage.json);

      var pm = _createPendingMessage(msg, SendingStatus.PENDING);

      _saveAndSend(pm);
    }
  }

  Message _createMessage(Uid room, {int? replyId, String? forwardedFrom}) {
    return Message(
        roomUid: room.asString(),
        packetId: _getPacketId(),
        time: DateTime.now().millisecondsSinceEpoch,
        from: _authRepo.currentUserUid.asString(),
        to: room.asString(),
        replyToId: replyId,
        forwardedFrom: forwardedFrom,
        json: EMPTY_MESSAGE);
  }

  String _getPacketId() {
    return "${DateTime.now().microsecondsSinceEpoch.toString()}-${randomString(5)}";
  }

  Future<List<Message?>> getPage(
      int page, String roomId, int containsId, int lastMessageId,
      {int pageSize = 16}) async {
    var completer = _completerMap["$roomId-$page"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completerMap["$roomId-$page"] = completer;

    _messageDao.getMessagePage(roomId, page)!.then((messages) async {
      if (messages.any((element) => element!.id == containsId)) {
        completer!.complete(messages);
      } else {
        await getMessages(roomId, page, pageSize, completer!, lastMessageId);
      }
    });

    return completer.future;
  }

  Future<void> getMessages(String roomId, int page, int pageSize,
      Completer<List<Message?>> completer, int lastMessageId,
      {bool retry = true}) async {
    try {
      var fetchMessagesRes =
          await _queryServiceClient.fetchMessages(FetchMessagesReq()
            ..roomUid = roomId.asUid()
            ..pointer = Int64(page * pageSize)
            ..type = FetchMessagesReq_Type.FORWARD_FETCH
            ..limit = pageSize);
      var res = await _saveFetchMessages(fetchMessagesRes.messages);
      if (res.last.id == lastMessageId) {
        _roomDao.updateRoom(Room(
            lastMessage: res.last, uid: roomId, lastMessageId: lastMessageId));
      }
      completer.complete(res);
    } catch (e) {
      _logger.e(e);
      if (retry) {
        getMessages(roomId, page, pageSize, completer, lastMessageId,
            retry: false);
      } else {
        completer.complete([]);
        completer.completeError(e);
      }
    }
  }

  Future<List<Message>> _saveFetchMessages(
      List<message_pb.Message> messages) async {
    List<Message> msgList = [];
    for (message_pb.Message message in messages) {
      _messageDao.deletePendingMessage(message.packetId);
      try {
        if (message.whichType() == message_pb.Message_Type.persistEvent) {
          switch (message.persistEvent.whichType()) {
            case PersistentEvent_Type.mucSpecificPersistentEvent:
              switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
                case MucSpecificPersistentEvent_Issue.DELETED:
                  _roomDao.updateRoom(
                      Room(uid: message.from.asString(), deleted: true));
                  continue;
                case MucSpecificPersistentEvent_Issue.ADD_USER:
                  _roomDao.updateRoom(
                      Room(uid: message.from.asString(), deleted: false));
                  break;
                case MucSpecificPersistentEvent_Issue.KICK_USER:
                  if (message.persistEvent.mucSpecificPersistentEvent.assignee
                      .isSameEntity(_authRepo.currentUserUid.asString())) {
                    _roomDao.updateRoom(
                        Room(uid: message.from.asString(), deleted: true));
                    continue;
                  }
                  break;
                case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
                  _avatarRepo.fetchAvatar(message.from, true);
                  break;
                case MucSpecificPersistentEvent_Issue.JOINED_USER:
                  // TODO: Handle this case.
                  break;
                case MucSpecificPersistentEvent_Issue.LEAVE_USER:
                  // TODO: Handle this case.
                  break;
                case MucSpecificPersistentEvent_Issue.MUC_CREATED:
                  // TODO: Handle this case.
                  break;
                case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
                  // TODO: Handle this case.
                  break;
                case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
                  // TODO: Handle this case.
                  break;
              }
              break;
            case PersistentEvent_Type.messageManipulationPersistentEvent:
              Uid roomUid = getRoomUid(_authRepo, message);
              switch (message
                  .persistEvent.messageManipulationPersistentEvent.action) {
                case MessageManipulationPersistentEvent_Action.EDITED:
                  getEditedMsg(
                      roomUid,
                      message.persistEvent.messageManipulationPersistentEvent
                          .messageId
                          .toInt());
                  break;
                case MessageManipulationPersistentEvent_Action.DELETED:
                  var mes = await _messageDao.getMessage(
                      roomUid.asString(),
                      message.persistEvent.messageManipulationPersistentEvent
                          .messageId
                          .toInt());
                  _messageDao.saveMessage(mes!..json = EMPTY_MESSAGE);
                  _roomDao.updateRoom(Room(
                      uid: roomUid.asString(), lastUpdatedMessageId: mes.id));
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
      Message? m =
          await saveMessageInMessagesDB(_authRepo, _messageDao, message);
      msgList.add(m!);
    }
    return msgList;
  }

  getEditedMsg(
    Uid roomUid,
    int id,
  ) async {
    var res = await _queryServiceClient.fetchMessages(FetchMessagesReq()
      ..roomUid = roomUid
      ..limit = 1
      ..pointer = Int64(id)
      ..type = FetchMessagesReq_Type.FORWARD_FETCH);
    var msg = await saveMessageInMessagesDB(
        _authRepo, _messageDao, res.messages.first);
    var room = await _roomDao.getRoom(roomUid.asString());
    await _roomDao.updateRoom(room!.copyWith(
      lastUpdatedMessageId: id,
    ));
    if (room.lastMessageId == id) {
      _roomDao.updateRoom(room.copyWith(lastMessage: msg));
    }
  }

  String _findType(String path) {
    return mime(path) ?? "application/octet-stream";
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
      {String? forwardFromAsString}) async {
    FormResult formResult = FormResult();
    for (var fileId in formResultMap.keys) {
      formResult.values[fileId] = formResultMap[fileId]!;
    }
    String jsonString = (formResult).writeToJson();

    Message msg = _createMessage(botUid.asUid(),
            replyId: formMessageId, forwardedFrom: forwardFromAsString)
        .copyWith(type: MessageType.FORM_RESULT, json: jsonString);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);

    _saveAndSend(pm);
  }

  void sendShareUidMessage(Uid room, message_pb.ShareUid shareUid) async {
    String json = shareUid.writeToJson();

    Message msg =
        _createMessage(room).copyWith(type: MessageType.SHARE_UID, json: json);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  void sendPrivateMessageAccept(
      Uid to, PrivateDataType privateDataType, String token) async {
    SharePrivateDataAcceptance sharePrivateDataAcceptance =
        SharePrivateDataAcceptance()
          ..data = privateDataType
          ..token = token;
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

  Future<Message?> getMessage(String roomUid, int id) =>
      _messageDao.getMessage(roomUid, id);

  Future<PendingMessage?> getPendingMessage(String packetId) =>
      _messageDao.getPendingMessage(packetId);

  Stream<PendingMessage?> watchPendingMessage(String packetId) =>
      _messageDao.watchPendingMessage(packetId);

  Stream<List<PendingMessage>> watchPendingMessages(String roomUid) =>
      _messageDao.watchPendingMessages(roomUid);

  void resendMessage(Message msg) async {
    var pm = await _messageDao.getPendingMessage(msg.packetId);
    _saveAndSend(pm!);
  }

  void deletePendingMessage(String packetId) {
    _messageDao.deletePendingMessage(packetId);
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

  void sendLiveLocationMessage(Uid roomUid, int duration, Position position,
      {int? replyId, String? forwardedFrom}) async {
    var res = await _liveLocationRepo.createLiveLocation(roomUid, duration);
    location_pb.Location location = location_pb.Location(
        longitude: position.longitude, latitude: position.latitude);
    String json = (location_pb.LiveLocation()
          ..location = location
          ..from = _authRepo.currentUserUid
          ..uuid = res.uuid
          ..to = roomUid
          ..time = Int64(duration))
        .writeToJson();
    Message msg =
        _createMessage(roomUid, replyId: replyId, forwardedFrom: forwardedFrom)
            .copyWith(type: MessageType.LIVE_LOCATION, json: json);

    var pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
    _liveLocationRepo.sendLiveLocationAsStream(res.uuid, duration, location);
  }

  Future<bool> _deleteMessage(Message message) async {
    try {
      await _queryServiceClient.deleteMessage(DeleteMessageReq()
        ..messageId = Int64(message.id!)
        ..roomUid = message.roomUid.asUid());
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  deleteMessage(List<Message> messages) async {
    try {
      for (var msg in messages) {
        if (msg.id == null) {
          deletePendingMessage(msg.packetId);
        } else {
          if (await _deleteMessage(msg)) {
            Room? room = await _roomRepo.getRoom(msg.roomUid);
            if (room != null) {
              if (msg.id == room.lastMessageId) {
                _roomDao.updateRoom(Room(
                    uid: msg.roomUid,
                    lastMessage: msg.copyWith(json: EMPTY_MESSAGE),
                    lastUpdateTime: DateTime.now().millisecondsSinceEpoch));
              }
            }

            msg.json = EMPTY_MESSAGE;
            _messageDao.saveMessage(msg);
            _roomDao.updateRoom(
                Room(uid: msg.roomUid, lastUpdatedMessageId: msg.id));
          }
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void editTextMessage(Uid roomUid, Message editableMessage, String text,
      roomLastMessageId) async {
    try {
      var updatedMessage = message_pb.MessageByClient()
        ..to = editableMessage.to.asUid()
        ..replyToId = Int64(editableMessage.replyToId ?? 0)
        ..text = message_pb.Text(text: text);
      await _queryServiceClient.updateMessage(UpdateMessageReq()
        ..message = updatedMessage
        ..messageId = Int64(editableMessage.id!));
      editableMessage.json = (message_pb.Text()..text = text).writeToJson();
      editableMessage.edited = true;
      _messageDao.saveMessage(editableMessage);
      _roomDao.updateRoom(Room(
          uid: roomUid.asString(), lastUpdatedMessageId: editableMessage.id));
      if (editableMessage.id == roomLastMessageId) {
        _roomDao.updateRoom(
            Room(uid: roomUid.asString(), lastMessage: editableMessage));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  editFileMessage(Uid roomUid, Message editableMessage,
      {String? caption, model.File? file}) async {
    file_pb.File? updatedFile;
    if (file != null) {
      String uploadKey = DateTime.now().millisecondsSinceEpoch.toString();
      await _fileRepo.cloneFileInLocalDirectory(
          dart_file.File(file.path), uploadKey, file.name);
      updatedFile = await _fileRepo.uploadClonedFile(uploadKey, file.name);
      if (updatedFile != null) {
        updatedFile.caption = caption!;
      }
    } else {
      var preFile = editableMessage.json.toFile();
      updatedFile = file_pb.File.create()
        ..caption = caption!
        ..name = preFile.name
        ..uuid = preFile.uuid
        ..type = preFile.type
        ..blurHash = preFile.blurHash
        ..size = preFile.size
        ..duration = preFile.duration
        ..height = preFile.height
        ..width = preFile.width
        ..tempLink = preFile.tempLink
        ..hash = preFile.hash
        ..sign = preFile.sign;
    }
    var updatedMessage = message_pb.MessageByClient()
      ..to = editableMessage.to.asUid()
      ..file = updatedFile!;
    await _queryServiceClient.updateMessage(UpdateMessageReq()
      ..message = updatedMessage
      ..messageId = Int64(editableMessage.id!));
    editableMessage.json = updatedFile.writeToJson();
    editableMessage.edited = true;
    _messageDao.saveMessage(editableMessage);
    _roomDao.updateRoom(Room(
        uid: roomUid.asString(), lastUpdatedMessageId: editableMessage.id));
  }

  void fetchBlockedRoom() async {
    try {
      GetBlockedListRes res =
          await _queryServiceClient.getBlockedList(GetBlockedListReq());
      if (res.uidList.isNotEmpty) {
        for (var uid in res.uidList) {
          _blockDao.block(uid.asString());
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
