// ignore_for_file: file_names, constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io' as dart_file;
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/call.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
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
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:rxdart/rxdart.dart';

import '../models/call_event_type.dart';
import '../services/call_service.dart';
import '../shared/constants.dart';

enum TitleStatusConditions { Disconnected, Updating, Normal, Connecting }

const EMPTY_MESSAGE = "{}";

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
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _queryServiceClient = GetIt.I.get<QueryServiceClient>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _mediaRepo = GetIt.I.get<MediaRepo>();
  final _sendActivitySubject = BehaviorSubject.seeded(0);
  final _callService = GetIt.I.get<CallService>();

  Map<String, RoomMetadata> _allRoomMetaData = {};

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
          await _roomRepo.fetchBlockedRoom();

          updatingStatus.add(TitleStatusConditions.Normal);

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

  final _completerMap = <String, Completer<List<Message?>>>{};

  Future<void> updateNewMuc(Uid roomUid, int lastMessageId) async {
    try {
      _roomDao.updateRoom(
        Room(
          uid: roomUid.asString(),
          lastMessageId: lastMessageId,
          lastUpdateTime: clock.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  @visibleForTesting
  Future<void> updatingMessages() async {
    _allRoomMetaData = {};
    var finished = false;
    var pointer = 0;
    final fetchAllRoom = await _sharedDao.get(SHARED_DAO_FETCH_ALL_ROOM);

    while (!finished && pointer < 10000) {
      try {
        final getAllUserRoomMetaRes =
            await _queryServiceClient.getAllUserRoomMeta(
          GetAllUserRoomMetaReq()
            ..pointer = pointer
            ..limit = 10,
        );
        finished = getAllUserRoomMetaRes.finished;
        if (finished) _sharedDao.put(SHARED_DAO_FETCH_ALL_ROOM, "true");
        for (final roomMetadata in getAllUserRoomMetaRes.roomsMeta) {
          _allRoomMetaData[roomMetadata.roomUid.asString()] = roomMetadata;
          final room = await _roomDao.getRoom(roomMetadata.roomUid.asString());
          if (room == null) {
            _seenDao.saveMySeen(
              Seen(uid: roomMetadata.roomUid.asString(), messageId: -1),
            );
          }
          if (roomMetadata.presenceType == PresenceType.ACTIVE) {
            if (room != null &&
                room.lastMessageId != null &&
                room.lastMessageId! < roomMetadata.lastMessageId.toInt() &&
                hasFirebaseCapability) {
              await _fireBaseServices.sendGlitchReportForFirebaseNotification(
                roomMetadata.roomUid.asString(),
              );
            }
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

            _roomDao.updateRoom(
              Room(
                uid: roomMetadata.roomUid.asString(),
                deleted: false,
                lastMessageId: roomMetadata.lastMessageId.toInt(),
                firstMessageId: roomMetadata.firstMessageId.toInt(),
                lastUpdateTime: roomMetadata.lastUpdate.toInt(),
              ),
            );

            await fetchLastMessages(
              roomMetadata.roomUid,
              roomMetadata.lastMessageId.toInt(),
              roomMetadata.firstMessageId.toInt(),
              room,
              type: FetchMessagesReq_Type.BACKWARD_FETCH,
            );

            await fetchLastIncomingCalls(
              roomMetadata.roomUid,
              roomMetadata.lastMessageId.toInt(),
              type: FetchMessagesReq_Type.FORWARD_FETCH,
            );

            if (room != null &&
                room.lastMessageId != null &&
                roomMetadata.lastMessageId.toInt() > room.lastMessageId!) {
              await fetchHiddenMessageCount(
                roomMetadata.roomUid,
                room.lastMessageId!,
              );
            }
            if (room != null && room.uid.asUid().category == Categories.GROUP) {
              await getMentions(room);
            }
          } else {
            _roomDao.updateRoom(
              Room(
                uid: roomMetadata.roomUid.asString(),
                deleted: true,
                lastMessageId: roomMetadata.lastMessageId.toInt(),
                firstMessageId: roomMetadata.firstMessageId.toInt(),
                lastUpdateTime: roomMetadata.lastUpdate.toInt(),
              ),
            );
          }
        }
      } catch (e) {
        _logger.e(e);
      }
      pointer += 10;
    }
  }

  Future<void> updatingLastSeen() async {
    final rooms = await _roomDao.getAllRooms();
    for (final r in rooms) {
      if (r.lastMessage == null) return;
      final category = r.lastMessage!.to.asUid().category;
      if (r.lastMessage!.id == null) return;
      if (!_authRepo.isCurrentUser(r.lastMessage!.from) &&
          _allRoomMetaData[r.uid] != null &&
          (category == Categories.GROUP || category == Categories.USER)) {
        await fetchCurrentUserLastSeen(_allRoomMetaData[r.uid]!);
      }
      final othersSeen = await _seenDao.getOthersSeen(r.lastMessage!.to);
      if (othersSeen == null || othersSeen.messageId < r.lastMessage!.id!) {
        await fetchOtherSeen(r.uid.asUid());
      }
    }
  }

  Future<void> fetchHiddenMessageCount(Uid roomUid, int id) async {
    try {
      final res = await _queryServiceClient.countIsHiddenMessages(
        CountIsHiddenMessagesReq()
          ..roomUid = roomUid
          ..messageId = Int64(id + 1),
      );
      final s = await _seenDao.getMySeen(roomUid.asString());
      _seenDao.saveMySeen(
        s.copy(newUid: roomUid.asString(), newHiddenMessageCount: res.count),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<Message?> fetchLastMessages(
    Uid roomUid,
    int lastMessageId,
    int firstMessageId,
    Room? room, {
    bool retry = true,
    required FetchMessagesReq_Type type,
  }) async {
    var pointer = lastMessageId + 1;
    Message? lastMessage;
    while (pointer > 0) {
      pointer -= 1;

      try {
        final msg = await _messageDao.getMessage(roomUid.asString(), pointer);

        if (msg != null) {
          if (msg.id! <= firstMessageId || (msg.isHidden && msg.id == 1)) {
            _roomDao.updateRoom(Room(uid: roomUid.asString(), deleted: true));
            break;
          } else if (!msg.isHidden) {
            lastMessage = msg;
            break;
          }
        } else {
          lastMessage = await getLastMessageFromServer(
            roomUid,
            lastMessageId,
            lastMessageId,
            type,
            25,
            firstMessageId,
          );
          break;
        }
      } catch (_) {
        break;
      }
    }

    if (lastMessage != null) {
      _roomDao.updateRoom(
        Room(
          uid: roomUid.asString(),
          firstMessageId: firstMessageId,
          lastUpdateTime: lastMessage.time,
          lastMessageId: lastMessageId,
          lastMessage: lastMessage,
        ),
      );
      return lastMessage;
    } else {
      return null;
    }
  }

  Future<void> fetchLastIncomingCalls(
    Uid roomUid,
    int lastMessageId, {
    required FetchMessagesReq_Type type,
  }) async {
    var pointer = lastMessageId + 1;
    try {
      final fetchMessagesRes = await _queryServiceClient.fetchMessages(
        FetchMessagesReq()
          ..roomUid = roomUid
          ..pointer = Int64(pointer)
          ..type = type
          ..limit = 20,
        options: CallOptions(timeout: const Duration(seconds: 3)),
      );
      for (message_pb.Message message in fetchMessagesRes.messages.reversed) {
        if (_callService.getUserCallState != UserCallState.NOCALL &&
            message.whichType() == message_pb.Message_Type.callEvent) {
          _logger.i("its fetch from message Repo");
          var callEvents = CallEvents.callEvent(message.callEvent,
              roomUid: message.from, callId: message.callEvent.id);
          if (message.callEvent.callType == CallEvent_CallType.GROUP_AUDIO ||
              message.callEvent.callType == CallEvent_CallType.GROUP_VIDEO) {
            // its group Call
            _callService.addGroupCallEvent(callEvents);
          } else {
            _callService.addCallEvent(callEvents);
          }
        }
      }
    } catch (_) {}
  }

  Future<Message?> getLastMessageFromServer(
    Uid roomUid,
    int lastMessageId,
    int pointer,
    FetchMessagesReq_Type type,
    int limit,
    int firstMessageId,
  ) async {
    Message? lastMessage;
    final fetchMessagesRes = await _queryServiceClient.fetchMessages(
      FetchMessagesReq()
        ..roomUid = roomUid
        ..pointer = Int64(pointer)
        ..type = type
        ..limit = limit,
      options: CallOptions(timeout: const Duration(seconds: 3)),
    );

    final messages = await _saveFetchMessages(fetchMessagesRes.messages);

    for (final msg in messages) {
      if (msg.id! <= firstMessageId && (msg.isHidden && msg.id == 1)) {
        _roomDao.updateRoom(Room(uid: roomUid.asString(), deleted: true));
        break;
      } else if (!msg.isHidden) {
        lastMessage = msg;
        break;
      }
    }
    return lastMessage;
  }

  Future<void> fetchOtherSeen(Uid roomUid) async {
    try {
      if (roomUid.category == Categories.USER ||
          roomUid.category == Categories.GROUP) {
        final fetchLastOtherUserSeenData =
            await _queryServiceClient.fetchLastOtherUserSeenData(
          FetchLastOtherUserSeenDataReq()..roomUid = roomUid,
        );
        _seenDao.saveOthersSeen(
          Seen(
            uid: roomUid.asString(),
            messageId: fetchLastOtherUserSeenData.seen.id.toInt(),
          ),
        );
      }
    } catch (e) {
      _logger
        ..wtf("roomUid: $roomUid")
        ..e(e);
    }
  }

  Future<void> fetchCurrentUserLastSeen(RoomMetadata room) async {
    try {
      final fetchCurrentUserSeenData =
          await _queryServiceClient.fetchCurrentUserSeenData(
        FetchCurrentUserSeenDataReq()..roomUid = room.roomUid,
      );

      final lastSeen = await _seenDao.getMySeen(room.roomUid.asString());
      if (lastSeen.messageId != -1 &&
          lastSeen.messageId >
              max(
                fetchCurrentUserSeenData.seen.id.toInt(),
                room.lastCurrentUserSentMessageId.toInt(),
              )) return;
      _seenDao.saveMySeen(
        Seen(
          uid: room.roomUid.asString(),
          hiddenMessageCount: lastSeen.hiddenMessageCount ?? 0,
          messageId: max(
            fetchCurrentUserSeenData.seen.id.toInt(),
            room.lastCurrentUserSentMessageId.toInt(),
          ),
        ),
      );
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
      final mentionResult = await _queryServiceClient.fetchMentionList(
        FetchMentionListReq()
          ..group = room.uid.asUid()
          ..afterId = Int64.parseInt(room.lastMessage!.id.toString()),
      );
      if (mentionResult.idList.isNotEmpty) {
        _roomDao.updateRoom(Room(uid: room.uid, mentioned: true));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendTextMessage(
    Uid room,
    String text, {
    int replyId = 0,
    String? forwardedFrom,
  }) async {
    final textsBlocks = text.split("\n").toList();
    final result = <String>[];
    for (text in textsBlocks) {
      if (textsBlocks.last != text) text = text + "\n";
      if (text.length > TEXT_MESSAGE_MAX_LENGTH) {
        var i = 0;
        while (i < (text.length / TEXT_MESSAGE_MAX_LENGTH).ceil()) {
          result.add(
            text.substring(
              i * TEXT_MESSAGE_MAX_LENGTH,
              min((i + 1) * TEXT_MESSAGE_MAX_LENGTH, text.length),
            ),
          );
          i++;
        }
      } else {
        result.add(text);
      }
    }

    var i = 0;
    while (i < (result.length / TEXT_MESSAGE_MAX_LINE).ceil()) {
      _sendTextMessage(
        result
            .sublist(
              i * TEXT_MESSAGE_MAX_LINE,
              min((i + 1) * TEXT_MESSAGE_MAX_LINE, result.length),
            )
            .join(),
        room,
        replyId,
        forwardedFrom,
      );
      i++;
    }
  }

  void _sendTextMessage(
    String text,
    Uid room,
    int replyId,
    String? forwardedFrom,
  ) {
    final json = (message_pb.Text()..text = text).writeToJson();
    final msg =
        _createMessage(room, replyId: replyId, forwardedFrom: forwardedFrom)
            .copyWith(type: MessageType.TEXT, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  void _saveAndSend(PendingMessage pm) {
    _savePendingMessage(pm);
    _updateRoomLastMessage(pm);
    _sendMessageToServer(pm);
  }

  Future<void> sendCallMessage(
    call_pb.CallEvent_CallStatus newStatus,
    Uid room,
    String callId,
    int callDuration,
    int endOfCallDuration,
    call_pb.CallEvent_CallType callType,
  ) async {
    final json = (call_pb.CallEvent()
          ..newStatus = newStatus
          ..id = callId
          ..callDuration = Int64(callDuration)
          ..endOfCallTime = Int64(endOfCallDuration)
          ..callType = callType)
        .writeToJson();

    final msg =
        _createMessage(room).copyWith(type: MessageType.CALL, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  Future<void> sendCallMessageWithMemberOrCallOwnerPvp(
    call_pb.CallEvent_CallStatus newStatus,
    Uid room,
    String callId,
    int callDuration,
    int endOfCallDuration,
    Uid memberOrCallOwnerPvp,
    call_pb.CallEvent_CallType callType,
  ) async {
    final json = (call_pb.CallEvent()
          ..newStatus = newStatus
          ..id = callId
          ..callDuration = Int64(callDuration)
          ..endOfCallTime = Int64(endOfCallDuration)
          ..memberOrCallOwnerPvp = memberOrCallOwnerPvp
          ..callType = callType)
        .writeToJson();

    final msg =
        _createMessage(room).copyWith(type: MessageType.CALL, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  Future<void> sendLocationMessage(
    Position locationData,
    Uid room, {
    String? forwardedFrom,
    int replyId = 0,
  }) async {
    final json = (location_pb.Location()
          ..longitude = locationData.longitude
          ..latitude = locationData.latitude)
        .writeToJson();

    final msg =
        _createMessage(room, replyId: replyId, forwardedFrom: forwardedFrom)
            .copyWith(type: MessageType.LOCATION, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  Future<void> sendMultipleFilesMessages(
    Uid room,
    List<model.File> files, {
    String? caption,
    int replyToId = 0,
  }) async {
    for (final file in files) {
      if (files.last.path == file.path) {
        await sendFileMessage(
          room,
          file,
          caption: caption,
          replyToId: replyToId,
        );
      } else {
        await sendFileMessage(room, file, replyToId: replyToId);
      }
    }
  }

  Future<void> sendFileMessage(
    Uid room,
    model.File file, {
    String? caption = "",
    int replyToId = 0,
  }) async {
    final packetId = _getPacketId();
    var tempDimension = Size.zero;
    int? tempFileSize;
    final tempType = file.extension ?? _findType(file.path);
    _fileRepo.initUploadProgress(packetId);

    final f = dart_file.File(file.path);
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

    final sendingFakeFile = file_pb.File()
      ..uuid = packetId
      ..caption = caption ?? ""
      ..width = tempDimension.width
      ..height = tempDimension.height
      ..type = tempType
      ..size = file.size != null ? Int64(file.size!) : Int64(tempFileSize!)
      ..name = file.name
      ..duration = 0;

    final msg = _createMessage(room, replyId: replyToId).copyWith(
      packetId: packetId,
      type: MessageType.FILE,
      json: sendingFakeFile.writeToJson(),
    );

    await _fileRepo.cloneFileInLocalDirectory(f, packetId, file.name);

    final pm = _createPendingMessage(msg, SendingStatus.UPLOAD_FILE_INPROGRSS);

    await _savePendingMessage(pm);

    final m = await _sendFileToServerOfPendingMessage(pm);
    if (m != null && m.status == SendingStatus.UPLOAD_FILE_COMPELED) {
      await _sendMessageToServer(m);
    } else if (m != null) {
      _messageDao.savePendingMessage(m);
    }
  }

  Future<void> sendStickerMessage({
    required Uid room,
    required Sticker sticker,
    int? replyId,
    String? forwardedFromAsString,
  }) async {
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
    PendingMessage pm,
  ) async {
    _sendActivitySubject
        .throttleTime(const Duration(seconds: 10))
        .listen((value) {
      if (value != 0) {
        sendActivity(pm.msg.to.asUid(), ActivityType.SENDING_FILE);
      }
    });

    final fakeFileInfo = file_pb.File.fromJson(pm.msg.json);

    final packetId = pm.msg.packetId;

    // Upload to file server
    final fileInfo = await _fileRepo.uploadClonedFile(
      packetId,
      fakeFileInfo.name,
      sendActivity: (i) => _sendActivitySubject.add(i),
    );
    if (fileInfo != null) {
      fileInfo.caption = fakeFileInfo.caption;

      final newJson = fileInfo.writeToJson();

      final newPm = pm.copyWith(
        msg: pm.msg.copyWith(json: newJson),
        status: SendingStatus.UPLOAD_FILE_COMPELED,
      );

      // Update pending messages table
      await _savePendingMessage(newPm);

      _updateRoomLastMessage(newPm);
      return newPm;
    } else {
      final newPm = pm.copyWith(status: SendingStatus.UPLIOD_FILE_FAIL);
      return newPm;
    }
  }

  Future<void> _sendMessageToServer(PendingMessage pm) async {
    final byClient = _createMessageByClient(pm.msg);

    _coreServices.sendMessage(byClient);
    // TODO(dansi): remove later, we don't need send no activity after sending messages, every time we received message we should set activity of room as no activity, https://gitlab.iais.co/deliver/wiki/-/issues/427
    sendActivity(byClient.to, ActivityType.NO_ACTIVITY);
  }

  message_pb.MessageByClient _createMessageByClient(Message message) {
    final byClient = message_pb.MessageByClient()
      ..packetId = message.packetId
      ..to = message.to.asUid()
      ..replyToId = Int64(message.replyToId);

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
      case MessageType.CALL:
        byClient.callEvent = call_pb.CallEvent.fromJson(message.json);
        break;
      case MessageType.Table:
        byClient.table = form_pb.Table.fromJson(message.json);
        break;
      case MessageType.LIVE_LOCATION:
      case MessageType.POLL:
      case MessageType.PERSISTENT_EVENT:
      case MessageType.NOT_SET:
      case MessageType.BUTTONS:
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        break;
    }
    return byClient;
  }

  @visibleForTesting
  Future<void> sendPendingMessages() async {
    final pendingMessages = await _messageDao.getAllPendingMessages();
    for (final pendingMessage in pendingMessages) {
      if (!pendingMessage.failed) {
        switch (pendingMessage.status) {
          case SendingStatus.UPLOAD_FILE_INPROGRSS:
            break;
          case SendingStatus.PENDING:
          case SendingStatus.UPLOAD_FILE_COMPELED:
            await _sendMessageToServer(pendingMessage);
            break;
          case SendingStatus.UPLIOD_FILE_FAIL:
            final pm = await _sendFileToServerOfPendingMessage(pendingMessage);
            if (pm != null) {
              await _sendMessageToServer(pm);
            }
            break;
        }
      }
    }
  }

  PendingMessage _createPendingMessage(Message msg, SendingStatus status) =>
      PendingMessage(
        roomUid: msg.roomUid,
        packetId: msg.packetId,
        msg: msg.copyWith(isHidden: isHiddenMessage(msg)),
        status: status,
      );

  Future<void> _savePendingMessage(PendingMessage pm) async {
    _messageDao.savePendingMessage(pm);
  }

  Future<void> sendSeen(int messageId, Uid to) async {
    final seen = await _seenDao.getMySeen(to.asString());
    if (seen.messageId >= messageId) return;
    _coreServices.sendSeen(
      seen_pb.SeenByClient()
        ..to = to
        ..id = Int64.parseInt(messageId.toString()),
    );
  }

  Future<void> _updateRoomLastMessage(PendingMessage pm) async {
    await _roomDao.updateRoom(
      Room(
        uid: pm.roomUid,
        lastMessage: pm.msg,
        lastMessageId: pm.msg.id,
        deleted: false,
        lastUpdateTime: pm.msg.time,
      ),
    );
  }

  Future<void> sendForwardedMessage(
    Uid room,
    List<Message> forwardedMessage,
  ) async {
    for (final forwardedMessage in forwardedMessage) {
      final msg = _createMessage(room, forwardedFrom: forwardedMessage.from)
          .copyWith(type: forwardedMessage.type, json: forwardedMessage.json);

      final pm = _createPendingMessage(msg, SendingStatus.PENDING);

      _saveAndSend(pm);
    }
  }

  void sendForwardedMediaMessage(Uid roomUid, List<Media> forwardedMedias) {
    for (final media in forwardedMedias) {
      final json = jsonDecode(media.json) as Map;
      final file = file_pb.File()
        ..type = json["type"]
        ..name = json["name"]
        ..width = json["width"] ?? 0
        ..size = Int64(json["size"])
        ..height = json["height"] ?? 0
        ..uuid = json["uuid"]
        ..duration = json["duration"] ?? 0.0
        ..caption = json["caption"] ?? ""
        ..tempLink = json["tempLink"] ?? ""
        ..hash = json["hash"] ?? ""
        ..sign = json["sign"] ?? ""
        ..blurHash = json["blurHash"] ?? "";

      final msg =
          _createMessage(roomUid, replyId: -1, forwardedFrom: media.createdBy)
              .copyWith(type: MessageType.FILE, json: file.writeToJson());

      final pm = _createPendingMessage(msg, SendingStatus.PENDING);
      _saveAndSend(pm);
    }
  }

  Message _createMessage(Uid room, {int replyId = 0, String? forwardedFrom}) =>
      Message(
        roomUid: room.asString(),
        packetId: _getPacketId(),
        time: clock.now().millisecondsSinceEpoch,
        from: _authRepo.currentUserUid.asString(),
        to: room.asString(),
        replyToId: replyId,
        forwardedFrom: forwardedFrom,
        json: EMPTY_MESSAGE,
        isHidden: true,
      );

  String _getPacketId() => clock.now().microsecondsSinceEpoch.toString();

  Future<List<Message?>> getPage(
    int page,
    String roomId,
    int containsId,
    int lastMessageId, {
    int pageSize = 16,
  }) async {
    if (containsId > lastMessageId) {
      return [];
    }

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

  Future<void> getMessages(
    String roomId,
    int page,
    int pageSize,
    Completer<List<Message?>> completer,
    int lastMessageId, {
    bool retry = true,
  }) async {
    try {
      final fetchMessagesRes = await _queryServiceClient.fetchMessages(
        FetchMessagesReq()
          ..roomUid = roomId.asUid()
          ..pointer = Int64(page * pageSize)
          ..type = FetchMessagesReq_Type.FORWARD_FETCH
          ..limit = pageSize,
      );
      final res = await _saveFetchMessages(fetchMessagesRes.messages);
      if (res.isNotEmpty && res.last.id == lastMessageId) {
        _roomDao.updateRoom(
          Room(
            lastMessage: res.last,
            uid: roomId,
            lastMessageId: lastMessageId,
          ),
        );
      }
      completer.complete(res);
    } catch (e) {
      _logger.e(e);
      if (retry) {
        getMessages(
          roomId,
          page,
          pageSize,
          completer,
          lastMessageId,
          retry: false,
        );
      } else {
        completer
          ..complete([])
          ..completeError(e);
      }
    }
  }

// TODO(hasan): Some parts of this function should be transform to DataStreamServices class, https://gitlab.iais.co/deliver/wiki/-/issues/428
  Future<List<Message>> _saveFetchMessages(
    List<message_pb.Message> messages,
  ) async {
    final msgList = <Message>[];
    for (final message in messages) {
      _messageDao.deletePendingMessage(message.packetId);
      try {
        if (message.whichType() == message_pb.Message_Type.persistEvent) {
          switch (message.persistEvent.whichType()) {
            case PersistentEvent_Type.mucSpecificPersistentEvent:
              switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
                case MucSpecificPersistentEvent_Issue.DELETED:
                  _roomDao.updateRoom(
                    Room(uid: message.from.asString(), deleted: true),
                  );
                  continue;
                case MucSpecificPersistentEvent_Issue.ADD_USER:
                  _roomDao.updateRoom(
                    Room(uid: message.from.asString(), deleted: false),
                  );
                  break;
                case MucSpecificPersistentEvent_Issue.KICK_USER:
                  if (_authRepo.isCurrentUserUid(
                    message.persistEvent.mucSpecificPersistentEvent.assignee,
                  )) {
                    _roomDao.updateRoom(
                      Room(uid: message.from.asString(), deleted: true),
                    );
                    continue;
                  }
                  break;
                case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
                  _avatarRepo.fetchAvatar(message.from, forceToUpdate: true);
                  break;
                case MucSpecificPersistentEvent_Issue.JOINED_USER:
                case MucSpecificPersistentEvent_Issue.LEAVE_USER:
                case MucSpecificPersistentEvent_Issue.MUC_CREATED:
                case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
                case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
                  // TODO(dansi): Handle these cases, https://gitlab.iais.co/deliver/wiki/-/issues/417
                  break;
              }
              break;
            case PersistentEvent_Type.messageManipulationPersistentEvent:
              final roomUid = getRoomUid(_authRepo, message);
              switch (message
                  .persistEvent.messageManipulationPersistentEvent.action) {
                case MessageManipulationPersistentEvent_Action.EDITED:
                  fetchEditedMsg(
                    roomUid,
                    message.persistEvent.messageManipulationPersistentEvent
                        .messageId
                        .toInt(),
                  );
                  break;
                case MessageManipulationPersistentEvent_Action.DELETED:
                  final mes = await _messageDao.getMessage(
                    roomUid.asString(),
                    message.persistEvent.messageManipulationPersistentEvent
                        .messageId
                        .toInt(),
                  );
                  if (mes != null) {
                    if (mes.type == MessageType.FILE && mes.id != null) {
                      _mediaDao.deleteMedia(roomUid.asString(), mes.id!);
                    }
                    _messageDao.saveMessage(mes.copyDeleted());
                    _roomDao.updateRoom(
                      Room(
                        uid: roomUid.asString(),
                        lastUpdatedMessageId: mes.id,
                      ),
                    );
                  }

                  break;
              }
              break;
            case PersistentEvent_Type.adminSpecificPersistentEvent:
            case PersistentEvent_Type.botSpecificPersistentEvent:
            case PersistentEvent_Type.notSet:
              break;
          }
        } else {}
      } catch (e) {
        _logger.e(e);
      }
      final m = await saveMessageInMessagesDB(_authRepo, _messageDao, message);
      msgList.add(m!);
    }
    return msgList;
  }

  Future<void> fetchEditedMsg(
    Uid roomUid,
    int id,
  ) async {
    final res = await _queryServiceClient.fetchMessages(
      FetchMessagesReq()
        ..roomUid = roomUid
        ..limit = 1
        ..pointer = Int64(id)
        ..type = FetchMessagesReq_Type.FORWARD_FETCH,
    );
    final msg = await saveMessageInMessagesDB(
      _authRepo,
      _messageDao,
      res.messages.first,
    );
    final room = await _roomDao.getRoom(roomUid.asString());
    await _roomDao.updateRoom(
      room!.copyWith(
        lastUpdatedMessageId: id,
      ),
    );
    if (room.lastMessageId == id) {
      _roomDao.updateRoom(room.copyWith(lastMessage: msg));
    }
  }

  String _findType(String path) => mime(path) ?? "application/octet-stream";

  void sendActivity(Uid to, ActivityType activityType) {
    if (to.category == Categories.GROUP || to.category == Categories.USER) {
      final activityByClient = ActivityByClient()
        ..typeOfActivity = activityType
        ..to = to;
      _coreServices.sendActivity(activityByClient, _getPacketId());
    }
  }

  Future<void> sendFormResultMessage(
    String botUid,
    Map<String, String> formResultMap,
    int formMessageId, {
    String? forwardFromAsString,
  }) async {
    final formResult = FormResult();
    for (final fileId in formResultMap.keys) {
      formResult.values[fileId] = formResultMap[fileId]!;
    }
    final jsonString = (formResult).writeToJson();

    final msg = _createMessage(
      botUid.asUid(),
      replyId: formMessageId,
      forwardedFrom: forwardFromAsString,
    ).copyWith(type: MessageType.FORM_RESULT, json: jsonString);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);

    _saveAndSend(pm);
  }

  Future<void> sendShareUidMessage(
    Uid room,
    message_pb.ShareUid shareUid,
  ) async {
    final json = shareUid.writeToJson();

    final msg =
        _createMessage(room).copyWith(type: MessageType.SHARE_UID, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  Future<void> sendPrivateMessageAccept(
    Uid to,
    PrivateDataType privateDataType,
    String token,
  ) async {
    final sharePrivateDataAcceptance = SharePrivateDataAcceptance()
      ..data = privateDataType
      ..token = token;
    final json = sharePrivateDataAcceptance.writeToJson();

    final msg = _createMessage(to)
        .copyWith(type: MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  Future<List<Message>> searchMessage(String str, String roomId) async => [];

  Future<Message?> getMessage(String roomUid, int id) =>
      _messageDao.getMessage(roomUid, id);

  Future<PendingMessage?> getPendingMessage(String packetId) =>
      _messageDao.getPendingMessage(packetId);

  Stream<PendingMessage?> watchPendingMessage(String packetId) =>
      _messageDao.watchPendingMessage(packetId);

  Stream<List<PendingMessage>> watchPendingMessages(String roomUid) =>
      _messageDao.watchPendingMessages(roomUid);

  Future<List<PendingMessage>> getPendingMessages(String roomUid) =>
      _messageDao.getPendingMessages(roomUid);

  Future<void> resendMessage(Message msg) async {
    final pm = await _messageDao.getPendingMessage(msg.packetId);
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

  Future<void> sendLiveLocationMessage(
    Uid roomUid,
    int duration,
    Position position, {
    int replyId = 0,
    String? forwardedFrom,
  }) async {
    final res = await _liveLocationRepo.createLiveLocation(roomUid, duration);
    final location = location_pb.Location(
      longitude: position.longitude,
      latitude: position.latitude,
    );
    final json = (location_pb.LiveLocation()
          ..location = location
          ..from = _authRepo.currentUserUid
          ..uuid = res.uuid
          ..to = roomUid
          ..time = Int64(duration))
        .writeToJson();
    final msg =
        _createMessage(roomUid, replyId: replyId, forwardedFrom: forwardedFrom)
            .copyWith(type: MessageType.LIVE_LOCATION, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
    _liveLocationRepo.sendLiveLocationAsStream(res.uuid, duration, location);
  }

  Future<bool> _deleteMessage(Message message) async {
    try {
      await _queryServiceClient.deleteMessage(
        DeleteMessageReq()
          ..messageId = Int64(message.id!)
          ..roomUid = message.roomUid.asUid(),
      );
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<void> deleteMessage(List<Message> messages) async {
    try {
      for (final message in messages) {
        final msg = message.copyDeleted();

        if (msg.type == MessageType.FILE && msg.id != null) {
          _mediaDao.deleteMedia(msg.roomUid, msg.id!);
        }
        if (msg.id == null) {
          deletePendingMessage(msg.packetId);
        } else {
          if (await _deleteMessage(msg)) {
            final room = await _roomRepo.getRoom(msg.roomUid);
            if (room != null) {
              if (msg.id == room.lastMessageId) {
                _roomDao.updateRoom(
                  Room(
                    uid: msg.roomUid,
                    lastMessage: msg,
                    lastUpdateTime: clock.now().millisecondsSinceEpoch,
                  ),
                );
              }
            }

            _messageDao.saveMessage(msg);
            _roomDao.updateRoom(
              Room(uid: msg.roomUid, lastUpdatedMessageId: msg.id),
            );
          }
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> editTextMessage(
    Uid roomUid,
    Message editableMessage,
    String text,
    int? roomLastMessageId,
  ) async {
    try {
      final updatedMessage = message_pb.MessageByClient()
        ..to = editableMessage.to.asUid()
        ..replyToId = Int64(editableMessage.replyToId)
        ..text = message_pb.Text(text: text);
      await _queryServiceClient.updateMessage(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(editableMessage.id ?? 0),
      );
      editableMessage
        ..json = (message_pb.Text()..text = text).writeToJson()
        ..edited = true;
      _messageDao.saveMessage(editableMessage);
      _roomDao.updateRoom(
        Room(
          uid: roomUid.asString(),
          lastUpdatedMessageId: editableMessage.id,
        ),
      );
      if (editableMessage.id == roomLastMessageId) {
        _roomDao.updateRoom(
          Room(uid: roomUid.asString(), lastMessage: editableMessage),
        );
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> editFileMessage(
    Uid roomUid,
    Message editableMessage, {
    String? caption,
    model.File? file,
  }) async {
    file_pb.File? updatedFile;
    if (file != null) {
      final uploadKey = clock.now().millisecondsSinceEpoch.toString();
      await _fileRepo.cloneFileInLocalDirectory(
        dart_file.File(file.path),
        uploadKey,
        file.name,
      );

      updatedFile = await _fileRepo.uploadClonedFile(uploadKey, file.name);
      if (updatedFile != null && caption != null) {
        updatedFile.caption = caption;
      }
    } else {
      final preFile = editableMessage.json.toFile();
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
    final updatedMessage = message_pb.MessageByClient()
      ..to = editableMessage.to.asUid()
      ..file = updatedFile!;
    await _queryServiceClient.updateMessage(
      UpdateMessageReq()
        ..message = updatedMessage
        ..messageId = Int64(editableMessage.id ?? 0),
    );
    editableMessage
      ..json = updatedFile.writeToJson()
      ..edited = true;
    _messageDao.saveMessage(editableMessage);
    _mediaRepo.updateMedia(editableMessage);
    _roomDao.updateRoom(
      Room(
        uid: roomUid.asString(),
        lastUpdatedMessageId: editableMessage.id,
      ),
    );
  }
}
