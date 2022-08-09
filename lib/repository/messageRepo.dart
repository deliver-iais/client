// ignore_for_file: file_names

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
import 'package:deliver/models/message_event.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
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
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart'
    as location_pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/sticker.pb.dart'
    as sticker_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as location;
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:rxdart/rxdart.dart';

import '../shared/constants.dart';

enum TitleStatusConditions {
  Disconnected,
  Updating,
  Connecting,
  Syncing,
  Connected,
  Normal
}

const EMPTY_MESSAGE = "{}";

BehaviorSubject<MessageEvent?> messageEventSubject =
    BehaviorSubject.seeded(null);

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
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _mediaRepo = GetIt.I.get<MediaRepo>();
  final _dataStreamServices = GetIt.I.get<DataStreamServices>();
  final _sendActivitySubject = BehaviorSubject.seeded(0);
  final updatingStatus =
      BehaviorSubject.seeded(TitleStatusConditions.Disconnected);

  MessageRepo() {
    connectionStatusHandler();
  }

  Future<void> connectionStatusHandler() async {
    _coreServices.connectionStatus.listen((mode) async {
      switch (mode) {
        case ConnectionStatus.Connected:
          _logger.i('updating -----------------');
          await updatingMessages();
          await updatingLastSeen();
          _roomRepo.fetchBlockedRoom().ignore();
          updatingStatus.add(TitleStatusConditions.Connected);
          Timer(const Duration(seconds: 1), () {
            if (updatingStatus.value == TitleStatusConditions.Connected) {
              updatingStatus.add(TitleStatusConditions.Normal);
            }
          });
          sendPendingMessages().ignore();
          unawaited(_fetchNotSyncedRoom());

          _logger.i('updating done -----------------');
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

  Future<void> _fetchNotSyncedRoom() async {
    final rooms = await _roomDao.getNotSyncedRoom();
    if (rooms.isNotEmpty) {
      for (final room in rooms) {
        if (!room.synced) {
          await fetchRoomLastMessage(
            room.uid,
            room.lastMessageId,
            room.firstMessageId,
          );
        }
        if (!room.seenSynced) {
          _updateLastSeen(room).ignore();
        }
      }
    }
  }

  final _completerMap = <String, Completer<List<Message?>>>{};

  @visibleForTesting
  Future<void> updatingMessages() async {
    var finished = false;
    var pointer = 0;
    final allRoomFetched =
        await _sharedDao.getBoolean(SHARED_DAO_ALL_ROOMS_FETCHED);
    if (allRoomFetched) {
      updatingStatus.add(TitleStatusConditions.Updating);
    } else {
      updatingStatus.add(TitleStatusConditions.Syncing);
    }
    while (!finished && pointer < MAX_ROOM_METADATA_SIZE) {
      try {
        final getAllUserRoomMetaRes =
            await _sdr.queryServiceClient.getAllUserRoomMeta(
          GetAllUserRoomMetaReq()
            ..pointer = pointer
            ..limit = FETCH_ROOM_METADATA_LIMIT,
        );
        finished = getAllUserRoomMetaRes.finished;
        if (finished) {
          _sharedDao.putBoolean(SHARED_DAO_ALL_ROOMS_FETCHED, true).ignore();
        }
        for (final roomMetadata in getAllUserRoomMetaRes.roomsMeta) {
          final room = await _roomDao.getRoom(roomMetadata.roomUid.asString());
          if (roomMetadata.presenceType == PresenceType.ACTIVE) {
            if (room != null &&
                room.lastMessageId < roomMetadata.lastMessageId.toInt() &&
                hasFirebaseCapability) {
              _fireBaseServices
                  .sendGlitchReportForFirebaseNotification(
                    roomMetadata.roomUid.asString(),
                  )
                  .ignore();
            }
            if (room != null &&
                room.lastMessage != null &&
                room.lastMessage!.id != null &&
                room.lastMessage!.id! >= roomMetadata.lastMessageId.toInt() &&
                room.lastMessage!.id != 0 &&
                room.lastUpdateTime >= roomMetadata.lastUpdate.toInt()) {
              if (allRoomFetched) {
                finished = true;
              }
              break;
              // no more updating needed after this room

            }
            _roomDao
                .updateRoom(
                  uid: roomMetadata.roomUid.asString(),
                  deleted: false,
                  synced: false,
                  lastCurrentUserSentMessageId:
                      roomMetadata.lastCurrentUserSentMessageId.toInt(),
                  lastMessageId: roomMetadata.lastMessageId.toInt(),
                  firstMessageId: roomMetadata.firstMessageId.toInt(),
                  lastUpdateTime: roomMetadata.lastUpdate.toInt(),
                )
                .ignore();

            if (pointer <= FETCH_ROOM_METADATA_IN_SYNCING_SIZE) {
              await fetchRoomLastMessage(
                roomMetadata.roomUid.asString(),
                roomMetadata.lastMessageId.toInt(),
                roomMetadata.firstMessageId.toInt(),
              );
            }
          } else {
            _roomDao
                .updateRoom(
                  uid: roomMetadata.roomUid.asString(),
                  deleted: true,
                  lastMessageId: roomMetadata.lastMessageId.toInt(),
                  firstMessageId: roomMetadata.firstMessageId.toInt(),
                  lastUpdateTime: roomMetadata.lastUpdate.toInt(),
                )
                .ignore();
          }
        }
      } catch (e) {
        _logger.e(e);
      }
      pointer += FETCH_ROOM_METADATA_LIMIT;
    }
  }

  Future<void> fetchRoomLastMessage(
    String roomUid,
    int lastMessageId,
    int firstMessageId,
  ) async {
    await _dataStreamServices.fetchLastNotHiddenMessage(
      roomUid.asUid(),
      lastMessageId,
      firstMessageId,
    );

    await _dataStreamServices.getAndProcessLastIncomingCallsFromServer(
      roomUid.asUid(),
      lastMessageId,
    );

    if (roomUid.asUid().category == Categories.GROUP) {
      _fetchMentions(roomUid, lastMessageId).ignore();
    }
  }

  Future<void> updatingLastSeen() async {
    final rooms = await _roomDao.getAllRooms();
    for (final r in rooms) {
      await _updateLastSeen(r);
    }
  }

  Future<void> fetchRoomLastSeen(String roomUid) async {
    final room = await _roomDao.getRoom(roomUid);
    if (room != null) {
      _updateLastSeen(room).ignore();
    }
  }

  Future<void> _updateLastSeen(Room room) async {
    if (room.lastMessage == null || room.lastMessage!.id == null) return;
    if (!_authRepo.isCurrentUser(room.lastMessage!.from)) {
      await fetchCurrentUserLastSeen(room);
    } else {
      unawaited(_roomDao.updateRoom(uid: room.uid, seenSynced: true));
      final othersSeen = await _seenDao.getOthersSeen(room.lastMessage!.to);
      if (othersSeen == null || othersSeen.messageId < room.lastMessage!.id!) {
        fetchOtherSeen(room.uid.asUid()).toString();
      }
    }
  }

  Future<void> fetchHiddenMessageCount(Uid roomUid, int id) =>
      _sdr.queryServiceClient
          .countIsHiddenMessages(
            CountIsHiddenMessagesReq()
              ..roomUid = roomUid
              ..messageId = Int64(id + 1),
          )
          .then(
            (res) => _seenDao.updateMySeen(
              uid: roomUid.asString(),
              hiddenMessageCount: res.count,
            ),
          )
          .catchError((e) => _logger.e(e));

  Future<void> fetchOtherSeen(Uid roomUid) {
    if (roomUid.category == Categories.USER ||
        roomUid.category == Categories.GROUP) {
      return _sdr.queryServiceClient
          .fetchLastOtherUserSeenData(
            FetchLastOtherUserSeenDataReq()..roomUid = roomUid,
          )
          .then(
            (fetchLastOtherUserSeenData) => _seenDao.saveOthersSeen(
              Seen(
                uid: roomUid.asString(),
                messageId: fetchLastOtherUserSeenData.seen.id.toInt(),
                hiddenMessageCount: 0,
              ),
            ),
          )
          .catchError((e) {
        _logger
          ..wtf("roomUid: $roomUid")
          ..e(e);
      });
    } else {
      return Future.value();
    }
  }

  Future<void> fetchCurrentUserLastSeen(Room room) async {
    final seen = await _seenDao.getMySeen(room.uid);
    if (seen.messageId < room.lastMessage!.id!) {
      try {
        final fetchCurrentUserSeenData =
            await _sdr.queryServiceClient.fetchCurrentUserSeenData(
          FetchCurrentUserSeenDataReq()..roomUid = room.uid.asUid(),
        );

        final newSeenMessageId = max(
          fetchCurrentUserSeenData.seen.id.toInt(),
          room.lastCurrentUserSentMessageId,
        );

        await _seenDao.updateMySeen(
          uid: room.uid,
          messageId: newSeenMessageId,
        );

        return fetchHiddenMessageCount(
          room.uid.asUid(),
          newSeenMessageId,
        );
      } on GrpcError catch (e) {
        _logger
          ..wtf(room.uid)
          ..e(e);
        if (e.code == StatusCode.notFound) {
          unawaited(_roomDao.updateRoom(uid: room.uid, seenSynced: true));
          return _seenDao.updateMySeen(
            uid: room.uid,
            messageId: 0,
          );
        } else {
          unawaited(_roomDao.updateRoom(uid: room.uid, seenSynced: false));
        }
      } catch (e) {
        unawaited(_roomDao.updateRoom(uid: room.uid, seenSynced: false));
        _logger.e(e);
      }
    }
  }

  Future<void> _fetchMentions(
    String roomUid,
    int lastMessageId,
  ) {
    return _sdr.queryServiceClient
        .fetchMentionList(
      FetchMentionListReq()
        ..group = roomUid.asUid()
        ..afterId = Int64.parseInt(lastMessageId.toString()),
    )
        .then((mentionResult) {
      if (mentionResult.idList.isNotEmpty) {
        _roomDao.updateRoom(uid: roomUid, mentioned: true);
      }
    }).catchError((e) {
      _logger.e(e);
    });
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
      if (textsBlocks.last != text) text = "$text\n";
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
    location.Position locationData,
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

  Future<void> sendFileToChats(
    List<Uid> rooms,
    model.File file, {
    String? caption,
  }) async {
    final fileUuid = _getPacketId();
    await _fileRepo.cloneFileInLocalDirectory(
      dart_file.File(file.path),
      fileUuid,
      file.name,
    );
    final pendingMessages = <PendingMessage>[];
    for (final room in rooms) {
      final msg = buildMessageFromFile(room, file, fileUuid, caption: caption);
      final pm =
          _createPendingMessage(msg, SendingStatus.UPLOAD_FILE_INPROGRSS);

      await _savePendingMessage(pm);
      pendingMessages.add(pm);
    }

    final fileInfo = await _fileRepo.uploadClonedFile(
      fileUuid,
      file.name,
      sendActivity: (i) => _sendActivitySubject.add(i),
    );

    if (fileInfo != null) {
      final newJson = fileInfo.writeToJson();
      for (final pendingMessage in pendingMessages) {
        final newPm = pendingMessage.copyWith(
          msg: pendingMessage.msg.copyWith(json: newJson),
          status: SendingStatus.UPLOAD_FILE_COMPELED,
        );
        _sendMessageToServer(newPm);
        await _savePendingMessage(newPm);
        await _updateRoomLastMessage(newPm);
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
    final msg = buildMessageFromFile(
      room,
      file,
      packetId,
      replyToId: replyToId,
      caption: caption,
    );

    await _fileRepo.cloneFileInLocalDirectory(
      dart_file.File(file.path),
      packetId,
      file.name,
    );

    final pm = _createPendingMessage(msg, SendingStatus.UPLOAD_FILE_INPROGRSS);

    await _savePendingMessage(pm);

    final m = await _sendFileToServerOfPendingMessage(pm);
    if (m != null &&
        m.status == SendingStatus.UPLOAD_FILE_COMPELED &&
        _fileOfMessageIsValid(m.msg.json.toFile())) {
      _sendMessageToServer(m);
    } else if (m != null) {
      return _messageDao.savePendingMessage(m);
    }
  }

  Message buildMessageFromFile(
    Uid room,
    model.File file,
    String fileUuid, {
    String? caption,
    int replyToId = 0,
  }) {
    var tempDimension = Size.zero;
    int? tempFileSize;
    final tempType = file.extension ?? _findType(file.path);
    _fileRepo.initUploadProgress(fileUuid);

    final f = dart_file.File(file.path);
    // Get size of image
    try {
      if (tempType.split('/')[0] == 'image' ||
          tempType.contains("jpg") ||
          tempType.contains("png")) {
        tempDimension = ImageSizeGetter.getSize(FileInput(f));
        if (tempDimension == Size.zero) {
          tempDimension = const Size(200, 200);
        }
      }
      tempFileSize = f.statSync().size;
    } catch (_) {}

    // Create MessageCompanion

    // Get type with file name

    final sendingFakeFile = file_pb.File()
      ..uuid = fileUuid
      ..caption = caption ?? ""
      ..width = tempDimension.width
      ..height = tempDimension.height
      ..type = tempType
      ..size = file.size != null ? Int64(file.size!) : Int64(tempFileSize!)
      ..name = file.name
      ..duration = 0;

    return _createMessage(room, replyId: replyToId).copyWith(
      packetId: _getPacketId(),
      type: MessageType.FILE,
      json: sendingFakeFile.writeToJson(),
    );
  }

  Future<void> sendStickerMessage({
    required Uid room,
    required sticker_pb.Sticker sticker,
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

    // Upload to file server
    final fileInfo = await _fileRepo.uploadClonedFile(
      fakeFileInfo.uuid,
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

      await _updateRoomLastMessage(newPm);
      return newPm;
    } else {
      final p = await _messageDao.getPendingMessage(
        pm.packetId,
      ); //check pending message  delete when  file  uploading
      if (p != null) {
        final newPm = pm.copyWith(status: SendingStatus.UPLIOD_FILE_FAIL);
        return newPm;
      }
      return null;
    }
  }

  void _sendMessageToServer(PendingMessage pm) {
    if (pm.msg.id != null) {
      final updatedMessage = message_pb.MessageByClient()
        ..to = pm.msg.to.asUid()
        ..replyToId = Int64(pm.msg.replyToId)
        ..text = pm.msg.json.toText();
      updateMessageAtServer(updatedMessage, pm);
    } else {
      final byClient = _createMessageByClient(pm.msg);

      _coreServices.sendMessage(byClient);
    }
  }

  Future<void> updateMessageAtServer(
    message_pb.MessageByClient updatedMessage,
    PendingMessage pm,
  ) async {
    try {
      await _sdr.queryServiceClient.updateMessage(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(pm.msg.id ?? 0),
      );
      deletePendingMessage(pm.packetId);
    } catch (e) {
      _logger.e(e);
      await _savePendingMessage(
        pm.copyWith(
          failed: true,
        ),
      );
    }
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
        byClient.sticker = sticker_pb.Sticker.fromJson(message.json);
        break;
      case MessageType.FORM_RESULT:
        byClient.formResult = form_pb.FormResult.fromJson(message.json);
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
      case MessageType.TABLE:
        byClient.table = form_pb.Table.fromJson(message.json);
        break;
      case MessageType.LIVE_LOCATION:
      case MessageType.POLL:
      case MessageType.PERSISTENT_EVENT:
      case MessageType.NOT_SET:
      case MessageType.BUTTONS:
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
      case MessageType.TRANSACTION:
        break;
    }
    return byClient;
  }

  @visibleForTesting
  Future<void> sendPendingMessages() async {
    final pendingMessages = await _messageDao.getAllPendingMessages();
    for (final pendingMessage in pendingMessages) {
      if (!pendingMessage.failed ||
          pendingMessage.msg.type == MessageType.CALL) {
        switch (pendingMessage.status) {
          case SendingStatus.UPLOAD_FILE_INPROGRSS:
            break;
          case SendingStatus.PENDING:
          case SendingStatus.UPLOAD_FILE_COMPELED:
            _sendMessageToServer(pendingMessage);
            break;
          case SendingStatus.UPLIOD_FILE_FAIL:
            final pm = await _sendFileToServerOfPendingMessage(pendingMessage);
            if (pm != null &&
                pm.status == SendingStatus.UPLOAD_FILE_COMPELED &&
                _fileOfMessageIsValid(pm.msg.json.toFile())) {
              _sendMessageToServer(pm);
            }
            break;
        }
      }
    }
  }

  bool _fileOfMessageIsValid(file_pb.File file) =>
      (file.sign.isNotEmpty && file.hash.isNotEmpty);

  PendingMessage _createPendingMessage(Message msg, SendingStatus status) =>
      PendingMessage(
        roomUid: msg.roomUid,
        packetId: msg.packetId,
        msg: msg.copyWith(isHidden: isHiddenMessage(msg)),
        status: status,
      );

  Future<void> _savePendingMessage(PendingMessage pm) =>
      _messageDao.savePendingMessage(pm);

  Future<void> sendSeen(
    int messageId,
    Uid to, {
    bool useUnary = false,
  }) async {
    final seen = await _seenDao.getMySeen(to.asString());
    if (seen.messageId >= messageId) return;
    _coreServices.sendSeen(
      seen_pb.SeenByClient()
        ..to = to
        ..id = Int64.parseInt(messageId.toString()),
    );
  }

  Future<void> _updateRoomLastMessage(PendingMessage pm) => _roomDao.updateRoom(
        uid: pm.roomUid,
        lastMessage: pm.msg,
        lastMessageId: pm.msg.id,
        deleted: false,
      );

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
    int pageSize = PAGE_SIZE,
  }) {
    if (containsId > lastMessageId) {
      return Future.value([]);
    }

    var completer = _completerMap["$roomId-$page"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completerMap["$roomId-$page"] = completer;

    _messageDao.getMessagePage(roomId, page).then((messages) async {
      if (messages.any((element) => element.id == containsId)) {
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
    int lastMessageId,
  ) async {
    try {
      final fetchMessagesRes = await _sdr.queryServiceClient.fetchMessages(
        FetchMessagesReq()
          ..roomUid = roomId.asUid()
          ..pointer = Int64(page * pageSize)
          ..type = FetchMessagesReq_Type.FORWARD_FETCH
          ..limit = pageSize,
      );
      final nonRepeatedMessage =
          _nonRepeatedMessageForApplyingActions(fetchMessagesRes.messages);
      await _dataStreamServices.handleFetchMessagesActions(
        roomId,
        nonRepeatedMessage,
      );
      final res = await _dataStreamServices
          .saveFetchMessages(fetchMessagesRes.messages);
      completer.complete(res);
    } catch (e) {
      _logger.e(e);
      completer.complete([]);
    }
  }

  List<message_pb.Message> _nonRepeatedMessageForApplyingActions(
    List<message_pb.Message> fetchMessages,
  ) {
    final messagesMap = <Int64, message_pb.Message>{};
    for (final message in fetchMessages) {
      if (message.whichType() == message_pb.Message_Type.persistEvent) {
        if (message.persistEvent.whichType() ==
            PersistentEvent_Type.messageManipulationPersistentEvent) {
          messagesMap.putIfAbsent(
            message.persistEvent.messageManipulationPersistentEvent.messageId,
            () => message,
          );
        }
      } else {
        messagesMap.putIfAbsent(message.id, () => message);
      }
    }
    return messagesMap.values.toList();
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
    form_pb.FormResult formResult,
    int formMessageId,
  ) async {
    final jsonString = (formResult).writeToJson();
    final msg = _createMessage(
      botUid.asUid(),
      replyId: formMessageId,
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

  Future<void> sendPrivateDataAcceptanceMessage(
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

  Future<void> pinMessage(Message message) => _mucServices.pinMessage(message);

  Future<void> unpinMessage(Message message) =>
      _mucServices.unpinMessage(message);

  Future<void> sendLiveLocationMessage(
    Uid roomUid,
    int duration,
    location.Position position, {
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
      await _sdr.queryServiceClient.deleteMessage(
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
          unawaited(_mediaDao.deleteMedia(msg.roomUid, msg.id!));
        }
        if (msg.id == null) {
          deletePendingMessage(msg.packetId);
        } else {
          if (await _deleteMessage(msg)) {
            await _messageDao.saveMessage(msg);
            messageEventSubject.add(
              MessageEvent(
                message.roomUid,
                clock.now().millisecondsSinceEpoch,
                message.id!,
                MessageManipulationPersistentEvent_Action.DELETED,
              ),
            );

            final room = (await _roomRepo.getRoom(msg.roomUid))!;

            Message? lastNotHiddenMessage;

            if (msg.id == room.lastMessage?.id) {
              lastNotHiddenMessage =
                  await _dataStreamServices.fetchLastNotHiddenMessage(
                room.uid.asUid(),
                room.lastMessageId,
                room.firstMessageId,
              );
            }

            await _roomDao.updateRoom(
              uid: msg.roomUid,
              lastMessage: lastNotHiddenMessage,
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
  ) async {
    try {
      if (text == editableMessage.json.toText().text) {
        return;
      }
      final pm = _createPendingMessage(
        editableMessage
          ..json = (message_pb.Text()..text = text).writeToJson()
          ..edited = true,
        SendingStatus.PENDING,
      );
      await _savePendingMessage(pm);

      final updatedMessage = message_pb.MessageByClient()
        ..to = editableMessage.to.asUid()
        ..replyToId = Int64(editableMessage.replyToId)
        ..text = message_pb.Text(text: text);
      await _sdr.queryServiceClient.updateMessage(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(editableMessage.id ?? 0),
      );
      editableMessage
        ..json = (message_pb.Text()..text = text).writeToJson()
        ..edited = true;
      deletePendingMessage(editableMessage.packetId);
      await _messageDao.saveMessage(editableMessage);
      messageEventSubject.add(
        MessageEvent(
          editableMessage.roomUid,
          clock.now().millisecondsSinceEpoch,
          editableMessage.id!,
          MessageManipulationPersistentEvent_Action.EDITED,
        ),
      );
      final room = (await _roomDao.getRoom(editableMessage.roomUid))!;

      if (editableMessage.id == room.lastMessage?.id) {
        await _roomDao.updateRoom(
          uid: roomUid.asString(),
          lastMessage: editableMessage,
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
    try {
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
        if (caption == preFile.caption) {
          return;
        }
        updatedFile = file_pb.File.create()
          ..caption = caption ?? ""
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
      await _sdr.queryServiceClient.updateMessage(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(editableMessage.id ?? 0),
      );
      editableMessage
        ..json = updatedFile.writeToJson()
        ..edited = true;
      await _messageDao.saveMessage(editableMessage);
      await _mediaRepo.updateMedia(editableMessage);
      messageEventSubject.add(
        MessageEvent(
          editableMessage.roomUid,
          clock.now().millisecondsSinceEpoch,
          editableMessage.id!,
          MessageManipulationPersistentEvent_Action.EDITED,
        ),
      );

      final room = (await _roomDao.getRoom(editableMessage.roomUid))!;

      if (editableMessage.id == room.lastMessage?.id) {
        await _roomDao.updateRoom(
          uid: roomUid.asString(),
          lastMessage: editableMessage,
        );
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
