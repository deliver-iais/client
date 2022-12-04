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
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/models/message_event.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
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
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:rxdart/rxdart.dart';

enum TitleStatusConditions {
  Disconnected,
  Updating,
  Connecting,
  Syncing,
  Connected,
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
  final _i18n = GetIt.I.get<I18N>();
  final _sendActivitySubject = BehaviorSubject.seeded(0);
  final updatingStatus =
      BehaviorSubject.seeded(TitleStatusConditions.Connected);
  bool _updateState = false;
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();

  MessageRepo() {
    unawaited(createConnectionStatusHandler());
  }

  Future<void> createConnectionStatusHandler() async {
    if (_authRepo.isLoggedIn()) {
      await update();
    }
    _coreServices.connectionStatus.listen((mode) async {
      switch (mode) {
        case ConnectionStatus.Connected:
          unawaited(update());
          _updateState = true;
          break;
        case ConnectionStatus.Disconnected:
          updatingStatus.add(TitleStatusConditions.Disconnected);
          break;
        case ConnectionStatus.Connecting:
          if (updatingStatus.value != TitleStatusConditions.Connected) {
            updatingStatus.add(TitleStatusConditions.Connecting);
          }
          break;
      }
    });
  }

  final _completerMap = <String, Completer<List<Message?>>>{};

  Future<void> update() async {
    _logger.i('updating -----------------');
    updatingStatus.add(TitleStatusConditions.Connected);

    if (await updatingMessages()) {
      await updatingLastSeen();
      _roomRepo.fetchBlockedRoom().ignore();
    }
    updatingStatus.add(TitleStatusConditions.Connected);

    sendPendingMessages().ignore();
    sendPendingEditedMessages().ignore();
    _logger.i('updating done -----------------');
  }

  // @visibleForTesting
  Future<bool> updatingMessages() async {
    var finished = false;
    var pointer = 0;
    final allRoomFetched =
        await _sharedDao.getBoolean(SHARED_DAO_ALL_ROOMS_FETCHED);
    final appRunInForeground = !_appLifecycleService.appIsActive();
    if (!allRoomFetched && _updateState) {
      updatingStatus.add(TitleStatusConditions.Syncing);
    }
    while (!finished && pointer < MAX_ROOM_METADATA_SIZE) {
      try {
        var isFetchCorrectly = false;
        var getAllUserRoomMetaRes = GetAllUserRoomMetaRes.getDefault();
        var reTryFailedFetch = 3;
        while (!isFetchCorrectly && reTryFailedFetch > 0) {
          try {
            getAllUserRoomMetaRes =
                await _sdr.queryServiceClient.getAllUserRoomMeta(
              GetAllUserRoomMetaReq()
                ..pointer = pointer
                ..limit = FETCH_ROOM_METADATA_LIMIT,
            );
            if (getAllUserRoomMetaRes.finished ||
                getAllUserRoomMetaRes.roomsMeta.length ==
                    FETCH_ROOM_METADATA_LIMIT) {
              isFetchCorrectly = true;
            } else {
              reTryFailedFetch--;
            }
          } on GrpcError catch (e) {
            reTryFailedFetch--;
            _logger.e(e);
          } catch (e) {
            reTryFailedFetch--;
            _logger.e(e);
          }
        }

        for (final roomMetadata in getAllUserRoomMetaRes.roomsMeta) {
          try {
            await _updateRoom(
              roomMetadata,
              appRunInForeground: appRunInForeground,
              indexOfRoom:
                  getAllUserRoomMetaRes.roomsMeta.indexOf(roomMetadata),
            );

            if (allRoomFetched && _updateState) {
              updatingStatus.add(TitleStatusConditions.Updating);
            }
          } catch (e) {
            _logger.e(e);
          }
        }

        if (!finished) {
          finished = getAllUserRoomMetaRes.finished;
          if (finished) {
            _sharedDao.putBoolean(SHARED_DAO_ALL_ROOMS_FETCHED, true).ignore();
          }
        }
      } on GrpcError catch (e) {
        _logger.e(e);
        if (!_updateState) {
          _updateState = true;
          return false;
        }
      } catch (e) {
        _logger.e(e);
      }
      pointer += FETCH_ROOM_METADATA_LIMIT;
    }
    return true;
  }

  Future<void> _updateRoom(
    RoomMetadata roomMetadata, {
    bool appRunInForeground = false,
    int indexOfRoom = 0,
  }) async {
    try {
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
        if (room == null ||
            (roomMetadata.lastUpdate.toInt() != room.lastUpdateTime ||
                room.deleted)) {
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
          if (appRunInForeground &&
              (room == null ||
                  (indexOfRoom < FETCH_ROOM_METADATA_IN_BACKGROUND_RECONNECT &&
                      roomMetadata.lastMessageId.toInt() >
                          room.lastMessageId))) {
            unawaited(_updateRoomInBackground(roomMetadata));
          }
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
    } catch (e, t) {
      _logger
        ..e(e)
        ..e(t);
    }
  }

  Future<void> _updateRoomInBackground(RoomMetadata roomMetadata) async {
    final seen = await _roomRepo.getMySeen(roomMetadata.roomUid.asString());

    if (roomMetadata.lastMessageId <= seen.messageId) {
      return;
    }

    await fetchRoomLastSeen(roomMetadata.roomUid.asString());

    final updatedSeen =
        await _roomRepo.getMySeen(roomMetadata.roomUid.asString());

    if (roomMetadata.lastMessageId > updatedSeen.messageId) {
      unawaited(
        fetchRoomLastMessage(
          roomMetadata.roomUid.asString(),
          roomMetadata.lastMessageId.toInt(),
          roomMetadata.firstMessageId.toInt(),
          appRunInForeground: true,
        ),
      );
    }
  }

  Future<void> fetchRoomLastMessage(
    String roomUid,
    int lastMessageId,
    int firstMessageId, {
    bool appRunInForeground = false,
  }) async {
    await _dataStreamServices.fetchLastNotHiddenMessage(
      roomUid.asUid(),
      lastMessageId,
      firstMessageId,
      appRunInForeground: appRunInForeground,
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
      await _updateLastSeen(room);
    }
  }

  Future<void> _updateLastSeen(Room room) async {
    if (room.lastMessage == null || room.lastMessage!.id == null) return;
    if (!_authRepo.isCurrentUser(room.lastMessage!.from)) {
      await fetchCurrentUserLastSeen(room);
    } else {
      await _roomDao.updateRoom(uid: room.uid, seenSynced: true);
      unawaited(
        _roomRepo.updateMySeen(
          uid: room.uid,
          messageId: room.lastMessageId,
        ),
      );
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
      var reTryFailedFetch = 3;
      while (reTryFailedFetch > 0) {
        try {
          reTryFailedFetch--;

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
          if (reTryFailedFetch == 0) {
            if (e.code == StatusCode.notFound) {
              unawaited(_roomDao.updateRoom(uid: room.uid, seenSynced: true));
              return _seenDao.updateMySeen(
                uid: room.uid,
                messageId: 0,
              );
            } else {
              unawaited(_roomDao.updateRoom(uid: room.uid, seenSynced: false));
            }
          }
        } catch (e) {
          if (reTryFailedFetch == 0) {
            unawaited(_roomDao.updateRoom(uid: room.uid, seenSynced: false));
          }
          _logger.e(e);
        }
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
    String? packetId,
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
        packetId,
      );
      i++;
    }
  }

  void _sendTextMessage(
    String text,
    Uid room,
    int replyId,
    String? forwardedFrom,
    String? packetId,
  ) {
    final json = (message_pb.Text()..text = text).writeToJson();
    final msg = _createMessage(
      room,
      replyId: replyId,
      forwardedFrom: forwardedFrom,
      packetId: packetId,
    ).copyWith(type: MessageType.TEXT, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  void _saveAndSend(PendingMessage pm) {
    _savePendingMessage(pm);
    _updateRoomLastMessage(pm);
    _sendMessageToServer(pm);
  }

  Future<void> sendCallMessage(
    call_pb.CallEvent_CallStatus callStatus,
    Uid room,
    String callId,
    int callDuration,
    call_pb.CallEvent_CallType callType,
  ) async {
    final json = (call_pb.CallEvent()
          ..callStatus = callStatus
          ..callId = callId
          ..callDuration = Int64(callDuration)
          ..callType = callType)
        .writeToJson();

    final msg =
        _createMessage(room).copyWith(type: MessageType.CALL, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    _saveAndSend(pm);
  }

  Future<void> sendLocationMessage(
    LatLng locationData,
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
    await _fileRepo.saveInFileInfo(
      dart_file.File(file.path),
      fileUuid,
      file.name,
    );
    final pendingMessages = <PendingMessage>[];
    final pendingMessagePacketId = <String>[];
    for (final room in rooms) {
      final msg = buildMessageFromFile(room, file, fileUuid, caption: caption);
      final pm =
          _createPendingMessage(msg, SendingStatus.UPLOAD_FILE_IN_PROGRESS);
      pendingMessagePacketId.add(pm.packetId);
      await _savePendingMessage(pm);
      pendingMessages.add(pm);
    }

    final fileInfo = await _fileRepo.uploadClonedFile(
      fileUuid,
      file.name,
      packetIds: pendingMessagePacketId,
      sendActivity: (i) => _sendActivitySubject.add(i),
    );

    if (fileInfo != null) {
      final newJson = fileInfo.writeToJson();
      for (final pendingMessage in pendingMessages) {
        final newPm = pendingMessage.copyWith(
          msg: pendingMessage.msg.copyWith(json: newJson),
          status: SendingStatus.UPLOAD_FILE_COMPLETED,
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

    await _fileRepo.saveInFileInfo(
      dart_file.File(file.path),
      packetId,
      file.name,
    );

    final pm =
        _createPendingMessage(msg, SendingStatus.UPLOAD_FILE_IN_PROGRESS);

    await _savePendingMessage(pm);

    final m = await _sendFileToServerOfPendingMessage(pm);
    if (m != null &&
        m.status == SendingStatus.UPLOAD_FILE_COMPLETED &&
        _fileOfMessageIsValid(m.msg.json.toFile())) {
      _sendMessageToServer(m);
    } else if (m != null) {
      try {
        ToastDisplay.showToast(
          toastText: _i18n.get("error_occurred"),
        );
      } catch (e) {
        _logger.e(e);
      }
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
    final sendingFakeFile = _createFakeSendFile(file, fileUuid, caption);

    return _createMessage(room, replyId: replyToId).copyWith(
      packetId: _getPacketId(),
      type: MessageType.FILE,
      json: sendingFakeFile.writeToJson(),
    );
  }

  file_pb.File _createFakeSendFile(
    model.File file,
    String fileUuid,
    String? caption,
  ) {
    var tempDimension = Size.zero;
    var tempFileSize = 0;
    var tempType = "";

    try {
      tempType = _findType(isWeb ? file.name : file.path);
    } catch (e) {
      _logger.e("Error in getting file type", e);
    }

    final f = dart_file.File(file.path);

    try {
      if (!isWeb) {
        tempFileSize = f.statSync().size;
      }
      _logger.d(
        "File size set to file size: $tempFileSize",
      );
    } catch (e) {
      _logger.e("Error in fetching fake file size", e);
    }

    // Get size of image
    try {
      if (tempType.split('/')[0] == 'image' ||
          tempType.contains("jpg") ||
          tempType.contains("png")) {
        tempDimension = ImageSizeGetter.getSize(FileInput(f));
        _logger.d(
          "File dimensions size fetched: ${tempDimension.width}x${tempDimension.height}",
        );
        if (tempDimension == Size.zero) {
          tempDimension =
              const Size(DEFAULT_FILE_DIMENSION, DEFAULT_FILE_DIMENSION);
          _logger.d(
            "File dimensions set to default size because it was zero to zero, 200x200",
          );
        }
      }
    } catch (e) {
      _logger.e("Error in fetching fake file dimensions", e);
    }

    return file_pb.File()
      ..uuid = fileUuid
      ..caption = caption ?? ""
      ..width = tempDimension.width
      ..height = tempDimension.height
      ..type = tempType
      ..size = file.size != null ? Int64(file.size!) : Int64(tempFileSize)
      ..name = file.name
      ..duration = 0;
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

  Future<file_pb.File?> _sendFileToServerOfPendingEditedMessage(
    PendingMessage pm,
  ) async {
    file_pb.File? updatedFile;
    final file = file_pb.File.fromJson(pm.msg.json);
    await _savePendingEditedMessage(
      pm.copyWith(status: SendingStatus.UPLOAD_FILE_IN_PROGRESS),
    );
    updatedFile = await _fileRepo
        .uploadClonedFile(file.uuid, file.name, packetIds: [pm.packetId]);
    if (updatedFile != null) {
      await _savePendingEditedMessage(
        pm.copyWith(
          msg: pm.msg.copyWith(json: updatedFile.writeToJson()),
          status: SendingStatus.UPLOAD_FILE_COMPLETED,
        ),
      );
    } else {
      await _savePendingEditedMessage(
        pm.copyWith(
          status: SendingStatus.UPLOAD_FILE_FAIL,
        ),
      );
    }
    return updatedFile;
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
      packetIds: [pm.packetId],
      sendActivity: (i) => _sendActivitySubject.add(i),
    );
    if (fileInfo != null) {
      fileInfo.caption = fakeFileInfo.caption;

      final newJson = fileInfo.writeToJson();

      final newPm = pm.copyWith(
        msg: pm.msg.copyWith(json: newJson),
        status: SendingStatus.UPLOAD_FILE_COMPLETED,
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
        final newPm = pm.copyWith(status: SendingStatus.UPLOAD_FILE_FAIL);
        return newPm;
      }
      return null;
    }
  }

  void _sendMessageToServer(PendingMessage pm) {
    final byClient = _createMessageByClient(pm.msg);

    _coreServices.sendMessage(byClient);
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
      case MessageType.PAYMENT_INFORMATION:
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
          case SendingStatus.UPLOAD_FILE_IN_PROGRESS:
            break;
          case SendingStatus.PENDING:
          case SendingStatus.UPLOAD_FILE_COMPLETED:
            _sendMessageToServer(pendingMessage);
            break;
          case SendingStatus.UPLOAD_FILE_FAIL:
            await resendFileMessage(pendingMessage);
            break;
        }
      }
    }
  }

  Future<void> resendFileMessage(PendingMessage pendingMessage) async {
    final pm = await _sendFileToServerOfPendingMessage(pendingMessage);
    if (pm != null &&
        pm.status == SendingStatus.UPLOAD_FILE_COMPLETED &&
        _fileOfMessageIsValid(pm.msg.json.toFile())) {
      _sendMessageToServer(pm);
    }
  }

  Future<void> sendPendingEditedMessages() async {
    final pendingMessages = await _messageDao.getAllPendingEditedMessages();

    for (final pendingMessage in pendingMessages) {
      if (!pendingMessage.failed) {
        switch (pendingMessage.status) {
          case SendingStatus.UPLOAD_FILE_IN_PROGRESS:
            break;
          case SendingStatus.PENDING:
          case SendingStatus.UPLOAD_FILE_COMPLETED:
            await updateMessageAtServer(pendingMessage);
            break;
          case SendingStatus.UPLOAD_FILE_FAIL:
            final updatedFile = await _sendFileToServerOfPendingEditedMessage(
              pendingMessage,
            );
            if (updatedFile != null) {
              await updateMessageAtServer(
                pendingMessage.copyWith(
                  msg: pendingMessage.msg
                      .copyWith(json: updatedFile.writeToJson()),
                  status: SendingStatus.UPLOAD_FILE_COMPLETED,
                ),
              );
            }
            break;
        }
      }
    }
  }

  Future<void> updateMessageAtServer(
    PendingMessage pendingMessage,
  ) async {
    try {
      final updatedMessage = _createMessageByClient(pendingMessage.msg);
      await _sdr.queryServiceClient.updateMessage(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(pendingMessage.msg.id ?? 0),
      );
      deletePendingEditedMessage(
        pendingMessage.roomUid,
        pendingMessage.msg.id,
      );
    } catch (e) {
      _logger.e(e);
      await _savePendingEditedMessage(
        pendingMessage.copyWith(
          failed: true,
        ),
      );
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

  Future<void> _savePendingEditedMessage(PendingMessage pm) =>
      _messageDao.savePendingEditedMessage(pm);

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
        lastMessage: pm.msg.isHidden ? null : pm.msg,
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

  Message _createMessage(
    Uid room, {
    int replyId = 0,
    String? forwardedFrom,
    String? packetId,
  }) =>
      Message(
        roomUid: room.asString(),
        packetId: packetId ?? _getPacketId(),
        time: clock.now().millisecondsSinceEpoch,
        from: _authRepo.currentUserUid.asString(),
        to: room.asString(),
        replyToId: replyId,
        forwardedFrom: forwardedFrom,
        json: EMPTY_MESSAGE,
        isHidden: true,
      );

  String _getPacketId() =>
      clock.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(100000).toString();

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

  String _findType(String path) => mime(path) ?? DEFAULT_FILE_TYPE;

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

  Future<PendingMessage?> getPendingEditedMessage(String roomUid, int? index) =>
      _messageDao.getPendingEditedMessage(roomUid, index);

  Stream<PendingMessage?> watchPendingMessage(String packetId) =>
      _messageDao.watchPendingMessage(packetId);

  Stream<List<PendingMessage>> watchPendingMessages(String roomUid) =>
      _messageDao.watchPendingMessages(roomUid);

  Stream<List<PendingMessage>> watchPendingEditedMessages(String roomUid) =>
      _messageDao.watchPendingEditedMessages(roomUid);

  Stream<PendingMessage?> watchPendingEditedMessage(String roomUid, int? id) =>
      _messageDao.watchPendingEditedMessage(roomUid, id);

  Future<List<PendingMessage>> getPendingMessages(String roomUid) =>
      _messageDao.getPendingMessages(roomUid);

  Future<void> resendMessage(Message msg) async {
    final pm = await _messageDao.getPendingMessage(msg.packetId);
    _saveAndSend(pm!);
  }

  void deletePendingMessage(String packetId) {
    _messageDao.deletePendingMessage(packetId);
  }

  void deletePendingEditedMessage(String roomUid, int? index) {
    _messageDao.deletePendingEditedMessage(roomUid, index);
    messageEventSubject.add(
      MessageEvent(
        roomUid,
        clock.now().millisecondsSinceEpoch,
        index ?? 0,
        MessageEventAction.PENDING_DELETE,
      ),
    );
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
                MessageEventAction.DELETE,
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
      final updatedMessage = message_pb.MessageByClient()
        ..to = editableMessage.to.asUid()
        ..replyToId = Int64(editableMessage.replyToId)
        ..text = message_pb.Text(text: text);
      final pm = _createPendingMessage(
        editableMessage.copyWith(
          json: (message_pb.Text()..text = text).writeToJson(),
          edited: true,
        ),
        SendingStatus.PENDING,
      );
      await _savePendingEditedMessage(pm);
      messageEventSubject.add(
        MessageEvent(
          editableMessage.roomUid,
          clock.now().millisecondsSinceEpoch,
          editableMessage.id!,
          MessageEventAction.PENDING_EDIT,
        ),
      );
      await _sdr.queryServiceClient.updateMessage(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(editableMessage.id ?? 0),
      );
      editableMessage
        ..json = (message_pb.Text()..text = text).writeToJson()
        ..edited = true;
      deletePendingEditedMessage(
        editableMessage.roomUid,
        editableMessage.id,
      );
      await _messageDao.saveMessage(editableMessage);
      messageEventSubject.add(
        MessageEvent(
          editableMessage.roomUid,
          clock.now().millisecondsSinceEpoch,
          editableMessage.id!,
          MessageEventAction.EDIT,
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
        final uploadKey = _getPacketId();
        await _fileRepo.saveInFileInfo(
          dart_file.File(file.path),
          uploadKey,
          file.name,
        );
        messageEventSubject.add(
          MessageEvent(
            editableMessage.roomUid,
            clock.now().millisecondsSinceEpoch,
            editableMessage.id!,
            MessageEventAction.PENDING_EDIT,
          ),
        );
        updatedFile = await _sendFileToServerOfPendingEditedMessage(
          _createPendingMessage(
            editableMessage.copyWith(
              json: _createFakeSendFile(file, uploadKey, caption).writeToJson(),
              edited: true,
            ),
            SendingStatus.UPLOAD_FILE_IN_PROGRESS,
          ),
        );
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
        final pm = _createPendingMessage(
          editableMessage.copyWith(
            json: updatedFile.writeToJson(),
            edited: true,
          ),
          SendingStatus.PENDING,
        );
        await _savePendingEditedMessage(pm);
        messageEventSubject.add(
          MessageEvent(
            editableMessage.roomUid,
            clock.now().millisecondsSinceEpoch,
            editableMessage.id!,
            MessageEventAction.PENDING_EDIT,
          ),
        );
      }
      final updatedMessage = message_pb.MessageByClient()
        ..to = editableMessage.to.asUid()
        ..file = updatedFile!;
      await _sdr.queryServiceClient.updateMessage(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(editableMessage.id ?? 0),
      );
      deletePendingEditedMessage(editableMessage.roomUid, editableMessage.id);
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
          MessageEventAction.EDIT,
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
