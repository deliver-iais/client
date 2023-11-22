// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';
import 'dart:io' as dart_file;
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/models/message_event.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/caching_repo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/services/serverless/serverless_message_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/random_vm.dart';
import 'package:deliver/utils/message_utils.dart';
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
import 'package:geolocator/geolocator.dart' as location;
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

enum TitleStatusConditions {
  Disconnected,
  Updating,
  Connecting,
  Syncing,
  Connected,
  LocalNetwork
}

enum PendingMessageRepeatedStatus {
  REPEATED_DETECTION_MESSAGE_OK,
  REPEATED_DETECTION_MESSAGE_FAILED,
  REPEATED_DETECTION_MESSAGE_REPEAT;
}

const EMPTY_MESSAGE = "{}";

const _sendingDelay = Duration(milliseconds: 100);

final messageEventSubject = BehaviorSubject<MessageEvent?>.seeded(null);

class MessageRepo {
  final _logger = GetIt.I.get<Logger>();
  final _i18n = GetIt.I.get<I18N>();

  final _messageDao = GetIt.I.get<MessageDao>();
  final _pendingMessageDao = GetIt.I.get<PendingMessageDao>();

  final _roomDao = GetIt.I.get<RoomDao>();
  final _seenDao = GetIt.I.get<SeenDao>();

  final _audioService = GetIt.I.get<AudioService>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _mucServices = GetIt.I.get<MucServices>();
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _dataStreamServices = GetIt.I.get<DataStreamServices>();
  final _fileService = GetIt.I.get<FileService>();
  final _cachingRepo = GetIt.I.get<CachingRepo>();

  // migrate to room repo
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _liveLocationRepo = GetIt.I.get<LiveLocationRepo>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _serverLessMessageService = GetIt.I.get<ServerLessMessageService>();
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _sendActivitySubject = BehaviorSubject.seeded(0);
  final updatingStatus =
      BehaviorSubject.seeded(TitleStatusConditions.Connected);
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();

  Future<void> createConnectionStatusHandler() async {
    _coreServices.connectionStatus.listen((mode) async {
      switch (mode) {
        case ConnectionStatus.Connected:
          unawaited(_update());
          break;
        case ConnectionStatus.Disconnected:
          updatingStatus.add(TitleStatusConditions.Disconnected);
          break;
        case ConnectionStatus.Connecting:
          updatingStatus.add(TitleStatusConditions.Connecting);
          break;
        case ConnectionStatus.LocalNetwork:
          updatingStatus.add(TitleStatusConditions.LocalNetwork);
      }
    });
  }

  final _completerMap = <String, Completer<List<Message?>>>{};

  Future<void> _update() async {
    updatingStatus.add(TitleStatusConditions.Connected);
    await updatingRooms();
    _roomRepo.fetchBlockedRoom().ignore();

    updatingStatus.add(TitleStatusConditions.Connected);

    sendPendingMessages().ignore();
    sendPendingEditedMessages().ignore();
    _logger.i('updating done -----------------');
  }

  // @visibleForTesting
  Future<void> updatingRooms() async {
    if (settings.lastRoomMetadataUpdateTime.value == 0 ||
        settings.lastRoomMetadataUpdateTime.value <
            _coreServices.lastRoomMetadataUpdateTime) {
      _logger.i('updating -----------------');
      var finished = false;
      var pointer = 0;
      final allRoomFetched = settings.allRoomFetched.value;
      if (!allRoomFetched) {
        updatingStatus.add(TitleStatusConditions.Syncing);
        _logger.i('syncing');
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
            if (await _updateRoom(
              roomMetadata,
              indexOfRoom:
                  getAllUserRoomMetaRes.roomsMeta.indexOf(roomMetadata),
            )) {
              if (allRoomFetched) {
                updatingStatus.add(TitleStatusConditions.Updating);
              }
            } else {
              if (allRoomFetched &&
                  updatingStatus.value != TitleStatusConditions.Connected) {
                updatingStatus.add(TitleStatusConditions.Connected);
              }
            }
          }

          if (!finished) {
            finished = getAllUserRoomMetaRes.finished;
            if (finished) {
              settings.allRoomFetched.set(true);
            }
          }
        } catch (e) {
          _logger.e(e);
        }
        pointer += FETCH_ROOM_METADATA_LIMIT;
      }

      settings.lastRoomMetadataUpdateTime
          .set(_coreServices.lastRoomMetadataUpdateTime);
    }
  }

  /// return true if have new room or new message
  Future<bool> _updateRoom(
    RoomMetadata roomMetadata, {
    int indexOfRoom = 0,
  }) async {
    try {
      final room = await _roomDao.getRoom(roomMetadata.roomUid);
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
        unawaited(
          processSeen(
            roomMetadata,
            needFetchHiddenMessageCountAndMentions:
                room == null || roomMetadata.lastMessageId > room.lastMessageId,
          ),
        );

        if (room == null ||
            (roomMetadata.lastUpdate.toInt() != room.lastUpdateTime ||
                room.deleted)) {
          unawaited(
            _roomDao.updateRoom(
              uid: roomMetadata.roomUid,
              deleted: false,
              synced: false,
              lastCurrentUserSentMessageId:
                  roomMetadata.lastCurrentUserSentMessageId.toInt(),
              lastMessageId: max(
                  roomMetadata.lastMessageId.toInt(), room?.lastMessageId ?? 0),
              firstMessageId: roomMetadata.firstMessageId.toInt(),
              lastUpdateTime: roomMetadata.lastUpdate.toInt(),
            ),
          );
          unawaited(_roomRepo.getName(roomMetadata.roomUid));
          return true;
        }
      } else {
        _roomDao
            .updateRoom(
              uid: roomMetadata.roomUid,
              deleted: true,
              lastMessageId: roomMetadata.lastMessageId.toInt(),
              firstMessageId: roomMetadata.firstMessageId.toInt(),
              lastUpdateTime: roomMetadata.lastUpdate.toInt(),
            )
            .ignore();
        return false;
      }
    } catch (e, t) {
      _logger
        ..e(e)
        ..e(t);
    }
    return false;
  }

  Future<void> processSeen(
    RoomMetadata roomMetadata, {
    bool needFetchHiddenMessageCountAndMentions = false,
  }) async {
    try {
      final seen = await _seenDao.getMySeen(roomMetadata.roomUid.asString());
      final roomSeen =
          await _seenDao.getRoomSeen(roomMetadata.roomUid.asString());
      final int lastSeenId =
          max(seen.messageId, roomMetadata.lastSeenId.toInt());
      if (roomSeen == null &&
          roomMetadata.lastMessageId.toInt() != 0 &&
          roomMetadata.lastMessageId.toInt() -
                  max(
                    lastSeenId,
                    roomMetadata.lastCurrentUserSentMessageId.toInt(),
                  ) !=
              0) {
        await _seenDao.addRoomSeen(roomMetadata.roomUid.asString());
      }
      if (lastSeenId > 0) {
        await _updateCurrentUserLastSeen(
          max(
            lastSeenId,
            roomMetadata.lastCurrentUserSentMessageId.toInt(),
          ),
          roomMetadata.roomUid.asString(),
          roomMetadata.lastMessageId.toInt(),
          needFetchHiddenMessageCountAndMentions,
        );
      } else {
        final room = await _roomDao.getRoom(roomMetadata.roomUid);
        if (room == null || !room.seenSynced) {
          unawaited(
            _fetchSeen(
              roomMetadata.roomUid.asString(),
              roomMetadata.lastCurrentUserSentMessageId.toInt(),
              roomMetadata.lastMessageId.toInt(),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _updateCurrentUserLastSeen(
    int lastSeenMessageId,
    String roomUid,
    int lastMessageId,
    bool needFetchHiddenMessageCountAndMentions,
  ) async {
    unawaited(
      (_seenDao.updateMySeen(
        uid: roomUid,
        messageId: lastSeenMessageId,
      )),
    );
    if (needFetchHiddenMessageCountAndMentions) {
      unawaited(fetchHiddenMessageCount(roomUid.asUid(), lastSeenMessageId));
    }

    if (roomUid.isGroup()) {
      unawaited(
        _updateRoomMention(lastSeenMessageId, roomUid),
      );
      if (needFetchHiddenMessageCountAndMentions &&
          lastMessageId > lastSeenMessageId) {
        await _fetchMentions(roomUid, lastSeenMessageId);
      }
    }
  }

  Future<void> _notifyOfflineMessagesWhenAppInBackground(
    RoomMetadata roomMetadata,
  ) async {
    if (roomMetadata.lastMessageId > roomMetadata.lastSeenId) {
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
    if (roomUid.isGroup() || roomUid.isUser()) {
      unawaited(_updateOtherSeen(roomUid));
    }

    // unawaited(
    //   _dataStreamServices.getAndProcessLastIncomingCallsFromServer(
    //     roomUid.asUid(),
    //     lastMessageId,
    //   ),
    // );
  }

  Future<void> _updateOtherSeen(String roomUid) async {
    try {
      final room = await _roomDao.getRoom(roomUid.asUid());
      if (room != null && room.lastMessage != null) {
        final othersSeen = await _seenDao.getOthersSeen(roomUid);
        if (othersSeen == null ||
            othersSeen.messageId < (room.lastMessage?.id ?? 0)) {
          if (_authRepo.isCurrentUserSender(room.lastMessage!)) {
            _fetchOtherLastSeen(roomUid);
          } else {
            await _seenDao.saveOthersSeen(
              Seen(
                uid: roomUid,
                messageId: room.lastMessage!.id!,
                hiddenMessageCount: 0,
              ),
            );
          }
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void _fetchOtherLastSeen(String roomUid) {
    _sdr.queryServiceClient
        .fetchLastOtherUserSeenData(
          FetchLastOtherUserSeenDataReq()..roomUid = roomUid.asUid(),
        )
        .then(
          (fetchLastOtherUserSeenData) => _seenDao.saveOthersSeen(
            Seen(
              uid: roomUid,
              messageId: fetchLastOtherUserSeenData.seen.id.toInt(),
              hiddenMessageCount: 0,
            ),
          ),
        )
        .catchError((e) {
      _logger
        ..f("roomUid: $roomUid")
        ..e(e);
    });
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

  Future<void> _fetchSeen(
    String roomUid,
    int lastCurrentUserSentMessageId,
    int lastMessageId,
  ) async {
    var reTryFailedFetch = 3;
    while (reTryFailedFetch > 0) {
      try {
        reTryFailedFetch--;

        final fetchCurrentUserSeenData =
            await _sdr.queryServiceClient.fetchCurrentUserSeenData(
          FetchCurrentUserSeenDataReq()..roomUid = roomUid.asUid(),
        );

        final newSeenMessageId = max(
          fetchCurrentUserSeenData.seen.id.toInt(),
          lastCurrentUserSentMessageId,
        );
        unawaited(sendSeen(newSeenMessageId, roomUid.asUid()));
        unawaited(
          _updateCurrentUserLastSeen(
            newSeenMessageId,
            roomUid,
            lastMessageId,
            false,
          ),
        );
      } on GrpcError catch (e) {
        _logger
          ..w(roomUid)
          ..e(e);
        if (e.code == StatusCode.notFound) {
          unawaited(sendSeen(lastCurrentUserSentMessageId, roomUid.asUid()));
          return _seenDao.updateMySeen(
            uid: roomUid,
            messageId: lastCurrentUserSentMessageId,
          );
        }
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  Future<void> _updateRoomMention(int messageId, String roomUid) async {
    try {
      final room = await _roomRepo.getRoom(roomUid.asUid());
      if (room != null && room.mentionsId.isNotEmpty) {
        unawaited(
          _roomRepo.updateMentionIds(
            room.uid,
            room.mentionsId.where((element) => element > messageId).toList(),
          ),
        );
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _fetchMentions(
    String roomUid,
    int messageId,
  ) async {
    await _sdr.queryServiceClient
        .fetchMentionList(
      FetchMentionListReq()
        ..group = roomUid.asUid()
        ..afterId = Int64(messageId + 1),
    )
        .then((mentionResult) async {
      if (mentionResult.idList.isNotEmpty) {
        await _roomRepo.processMentionIds(
          roomUid.asUid(),
          mentionResult.idList.map((e) => e.toInt()).toList(),
        );
      }
    }).catchError((e) {
      _logger.e(e);
    });
  }

  Future<void> sendTextMessage(
    Uid room,
    String text, {
    int replyId = 0,
    Uid? forwardedFrom,
    String? packetId,
    bool fromNotification = false,
  }) async {
    final textsBlocks = text.split("\n").toList();
    final result = <String>[];
    for (text in textsBlocks) {
      if (textsBlocks.last != text) {
        text = "$text\n";
      }
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
      await _sendTextMessage(
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
        fromNotification: fromNotification,
      );
      i++;
    }
  }

  Future<void> _sendTextMessage(
    String text,
    Uid room,
    int replyId,
    Uid? forwardedFrom,
    String? packetId, {
    bool fromNotification = false,
  }) async {
    final json = (message_pb.Text()..text = text).writeToJson();
    final msg = (await _createMessage(
      room,
      replyId: replyId,
      forwardedFrom: forwardedFrom,
      packetId: packetId,
    ))
        .copyWith(type: MessageType.TEXT, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    return _saveAndSend(pm, fromNotification: fromNotification);
  }

  Future<void> _saveAndSend(
    PendingMessage pm, {
    bool fromNotification = false,
  }) async {
    if (fromNotification) {
      await _savePendingMessage(pm)
          .then(
            (value) => {
              _analyticsService.sendLogEvent(
                "replyToMessageFromNotificationSavePendingSuccess",
                parameters: {
                  "packetId": pm.packetId,
                  "roomUid": pm.roomUid,
                },
              )
            },
          )
          .onError(
            (error, stackTrace) => {
              _analyticsService.sendLogEvent(
                "replyToMessageFromNotificationSavePendingFailed",
                parameters: {
                  "packetId": pm.packetId,
                  "roomUid": pm.roomUid,
                },
              )
            },
          );
    } else {
      unawaited(_savePendingMessage(pm));
    }
    unawaited(_updateRoomLastMessage(pm));
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

    final msg = (await _createMessage(room))
        .copyWith(type: MessageType.CALL, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    return _saveAndSend(pm);
  }

  Future<void> sendLocationMessage(
    LatLng locationData,
    Uid room, {
    Uid? forwardedFrom,
    int replyId = 0,
  }) async {
    final json = (location_pb.Location()
          ..longitude = locationData.longitude
          ..latitude = locationData.latitude)
        .writeToJson();

    final msg = (await _createMessage(
      room,
      replyId: replyId,
      forwardedFrom: forwardedFrom,
    ))
        .copyWith(type: MessageType.LOCATION, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    return _saveAndSend(pm);
  }

  Future<void> sendMultipleFilesMessages(
    Uid room,
    List<model.File> files, {
    String? caption,
    int replyToId = 0,
  }) async {
    for (final file in files) {
      await sendFileMessage(
        room,
        file,
        caption: files.last.path == file.path ? caption : "",
        replyToId: replyToId,
      );

      await Future.delayed(_sendingDelay);
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
      final msg =
          await buildMessageFromFile(room, file, fileUuid, caption: caption);
      final pm =
          _createPendingMessage(msg, SendingStatus.UPLOAD_FILE_IN_PROGRESS);
      pendingMessagePacketId.add(pm.packetId);
      await _savePendingMessage(pm);
      pendingMessages.add(pm);
    }

    final fileInfo = await _fileRepo.uploadClonedFile(
      fileUuid,
      file.name,
      uid: rooms.first,
      packetIds: pendingMessagePacketId,
      sendActivity: (i) => _sendActivitySubject.add(i),
    );

    if (fileInfo != null) {
      fileInfo.caption = caption ?? "";
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
    final packetId = await _getPacketIdWithLastMessageId(room);

    //first we compress the file if possible
    file = await _fileService.compressFile(file);

    final msg = await buildMessageFromFile(
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
      return _pendingMessageDao.savePendingMessage(m);
    }
  }

  Future<Message> buildMessageFromFile(
    Uid room,
    model.File file,
    String fileUuid, {
    String? caption,
    int replyToId = 0,
  }) async {
    final sendingFakeFile = await _createFakeSendFile(file, fileUuid, caption);
    final packetId = await _getPacketIdWithLastMessageId(room);

    return (await _createMessage(room, replyId: replyToId)).copyWith(
      packetId: packetId,
      type: MessageType.FILE,
      json: sendingFakeFile.writeToJson(),
    );
  }

  Future<file_pb.File> _createFakeSendFile(
    model.File file,
    String fileUuid,
    String? caption,
  ) async {
    var tempDimension = Size.zero;
    var tempFileSize = 0;
    var tempType = DEFAULT_FILE_TYPE;

    try {
      tempType = detectFileMimeByFileModel(file);
    } catch (e) {
      _logger.e("Error in getting file type", error: e);
    }

    try {
      if (!isWeb) {
        tempFileSize = getFileSizeSync(file.path);
      }
      _logger.d(
        "File size set to file size: $tempFileSize",
      );
    } catch (e) {
      _logger.e("Error in fetching fake file size", error: e);
    }

    // Get size of image
    try {
      if (isImageFileType(tempType)) {
        tempDimension = getImageDimension(file.path);

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
      _logger.e("Error in fetching fake file dimensions", error: e);
    }
    final file_pb.AudioWaveform audioWaveForm;
    if (file.isVoice ?? false) {
      audioWaveForm = file_pb.AudioWaveform(
        length: 100,
        bits: 8,
        data:
            (await _audioService.getAudioWave(file.path)).map((e) => e.toInt()),
      );
    } else {
      audioWaveForm = file_pb.AudioWaveform.getDefault();
    }

    return file_pb.File()
      ..uuid = fileUuid
      ..caption = caption ?? ""
      ..width = tempDimension.width
      ..height = tempDimension.height
      ..type = tempType
      ..size = file.size != null ? Int64(file.size!) : Int64(tempFileSize)
      ..name = file.name
      ..audioWaveform = audioWaveForm
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
    await _savePendingMessage(
      pm.copyWith(status: SendingStatus.UPLOAD_FILE_IN_PROGRESS),
    );
    updatedFile = await _fileRepo
        .uploadClonedFile(file.uuid, file.name, packetIds: [pm.packetId]);
    if (updatedFile != null) {
      await _savePendingMessage(
        pm.copyWith(
          msg: pm.msg.copyWith(json: updatedFile.writeToJson()),
          status: SendingStatus.UPLOAD_FILE_COMPLETED,
        ),
      );
    } else {
      await _savePendingMessage(
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
        sendActivity(pm.msg.to, ActivityType.SENDING_FILE);
      }
    });

    final fakeFileInfo = file_pb.File.fromJson(pm.msg.json);

    // Upload to file server
    final fileInfo = await _fileRepo.uploadClonedFile(
      fakeFileInfo.uuid,
      fakeFileInfo.name,
      uid: pm.roomUid,
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
      final p = await _pendingMessageDao.getPendingMessage(
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
    final byClient = MessageUtils.createMessageByClient(pm.msg);
    _coreServices.sendMessage(byClient);
  }

  void sendBroadcastMessageToServer(Message message) {
    final byClient = MessageUtils.createMessageByClient(message);
    _coreServices.sendMessage(byClient);
  }

  @visibleForTesting
  Future<void> sendPendingMessages() async {
    final pendingMessages = await _pendingMessageDao.getAllPendingMessages();
    final pendingFailedByRoom = <String>{};
    for (final pendingMessage in pendingMessages) {
      if (pendingFailedByRoom.contains(pendingMessage.roomUid.asString())) {
        break;
      } else {
        final status = await checkMessageRepeated(pendingMessage);
        switch (status) {
          case PendingMessageRepeatedStatus.REPEATED_DETECTION_MESSAGE_OK:
            if (!pendingMessage.failed ||
                pendingMessage.msg.type == MessageType.CALL ||
                pendingMessage.msg.type == MessageType.CALL_LOG) {
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
            break;
          case PendingMessageRepeatedStatus.REPEATED_DETECTION_MESSAGE_REPEAT:
            deletePendingMessage(pendingMessage.packetId);
            break;
          case PendingMessageRepeatedStatus.REPEATED_DETECTION_MESSAGE_FAILED:
            pendingFailedByRoom.add(pendingMessage.roomUid.asString());
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
    final pendingMessages =
        await _pendingMessageDao.getAllPendingEditedMessages();

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

  Future<PendingMessageRepeatedStatus> checkMessageRepeated(
    PendingMessage pm,
  ) async {
    try {
      final lastDeliveryAck = settings.lastMessageDeliveryAck.value;
      final msg = pm.msg;
      final lastDeliveryAckPacketId = lastDeliveryAck.packetId;
      final lastDeliveryAckTo = lastDeliveryAck.to;
      final lastDeliveryAckFrom = lastDeliveryAck.from;
      if (lastDeliveryAckPacketId == pm.packetId &&
          lastDeliveryAckTo == msg.to &&
          lastDeliveryAckFrom == msg.from) {
        return PendingMessageRepeatedStatus.REPEATED_DETECTION_MESSAGE_REPEAT;
      } else if (lastDeliveryAckTo == msg.to &&
          lastDeliveryAckFrom == msg.from) {
        final timeLastMessageDeliveryAck =
            int.parse(lastDeliveryAckPacketId.split("-")[0]);
        final lastMessageIdLastMessageDeliveryAck =
            int.parse(lastDeliveryAckPacketId.split("-")[1]);
        final timeMessage = int.parse(msg.packetId.split("-")[0]);
        final lastMessageIdMessage = int.parse(msg.packetId.split("-")[1]);
        if ((timeLastMessageDeliveryAck - timeMessage) >
                REPEATED_DETECTION_TIME ||
            (lastMessageIdLastMessageDeliveryAck - lastMessageIdMessage) >=
                REPEATED_DETECTION_COUNT) {
          return PendingMessageRepeatedStatus.REPEATED_DETECTION_MESSAGE_REPEAT;
        }
      } else {
        final timeLastMessageDeliveryAck =
            int.parse(lastDeliveryAckPacketId.split("-")[0]);
        final lastMessageIdLastMessageDeliveryAck =
            await _roomRepo.getRoomLastMessageId(pm.roomUid);
        final timeMessage = int.parse(msg.packetId.split("-")[0]);
        final lastMessageIdMessage = int.parse(msg.packetId.split("-")[1]);
        if ((timeLastMessageDeliveryAck - timeMessage) >=
                REPEATED_DETECTION_TIME ||
            (lastMessageIdLastMessageDeliveryAck - lastMessageIdMessage) >=
                REPEATED_DETECTION_COUNT) {
          return PendingMessageRepeatedStatus.REPEATED_DETECTION_MESSAGE_FAILED;
        }
      }

      return PendingMessageRepeatedStatus.REPEATED_DETECTION_MESSAGE_OK;
    } catch (_) {
      // fail message on parsing error in pending message or some other errors.
      return PendingMessageRepeatedStatus.REPEATED_DETECTION_MESSAGE_FAILED;
    }
  }

  Future<void> updateMessageAtServer(
    PendingMessage pendingMessage,
  ) async {
    try {
      final updatedMessage =
          MessageUtils.createMessageByClient(pendingMessage.msg);
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
      await _savePendingMessage(
        pendingMessage.copyWith(
          failed: true,
        ),
      );
    }
  }

  bool _fileOfMessageIsValid(file_pb.File file) =>
      settings.localNetworkMessenger.value ||
      (file.sign.isNotEmpty && file.hash.isNotEmpty);

  PendingMessage _createPendingMessage(Message msg, SendingStatus status) =>
      PendingMessage(
        roomUid: msg.roomUid,
        packetId: msg.packetId,
        msg: msg.copyWith(isHidden: isHiddenMessage(msg)),
        status: status,
      );

  Future<void> _savePendingMessage(PendingMessage pm) async =>
      _pendingMessageDao.savePendingMessage(pm);

  Future<void> sendSeen(
    int messageId,
    Uid to, {
    bool useUnary = false,
  }) async {
    final seen = await _seenDao.getMySeen(to.asString());
    if (seen.messageId >= messageId) {
      return;
    }
    // it's look better if w8 for sending seen and make it safer
    await _coreServices.sendSeen(
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
    for (var i = 0; i < forwardedMessage.length; i++) {
      final fm = forwardedMessage[i];
      final msg = (await _createMessage(
        room,
        forwardedFrom: fm.forwardedFrom?.node.isEmpty ?? true
            ? fm.roomUid.isChannel()
                ? fm.roomUid
                : fm.from
            : fm.forwardedFrom,
      ))
          .copyWith(
        type: fm.type,
        json: fm.json,
        markup: fm.markup,
      );

      final pm = _createPendingMessage(msg, SendingStatus.PENDING);

      await _saveAndSend(pm);

      await Future.delayed(_sendingDelay);
    }
  }

  Future<void> sendForwardedMetaMessage(
    Uid roomUid,
    List<Meta> forwardedMetas,
  ) async {
    for (final meta in forwardedMetas) {
      final msg = (await _createMessage(
        roomUid,
        replyId: -1,
        forwardedFrom: meta.createdBy.asUid(),
      ))
          .copyWith(type: MessageType.FILE, json: meta.json);

      final pm = _createPendingMessage(msg, SendingStatus.PENDING);
      await _saveAndSend(pm);

      await Future.delayed(_sendingDelay);
    }
  }

  Future<Message> _createMessage(
    Uid room, {
    int replyId = 0,
    Uid? forwardedFrom,
    String? packetId,
  }) async {
    final packetId = await _getPacketIdWithLastMessageId(room);
    return Message(
      roomUid: room,
      packetId: packetId,
      time: clock.now().millisecondsSinceEpoch,
      from: _authRepo.currentUserUid,
      to: room,
      replyToId: replyId,
      forwardedFrom: forwardedFrom,
      json: EMPTY_MESSAGE,
      isHidden: true,
    );
  }

  String _getPacketId() =>
      "${clock.now().millisecondsSinceEpoch}${randomVM.nextInt(RANDOM_SIZE)}";

  Future<String> _getPacketIdWithLastMessageId(
    Uid roomUid, {
    bool isBroadcastMessage = false,
    int? id,
  }) async {
    //get roomUid LastMessageId
    final lastMessageId = await _roomRepo.getRoomLastMessageId(roomUid);
    //if message is broadcast set 1 and if is normal message set 0;
    final broadcast = isBroadcastMessage ? 1 : 0;
    return "${clock.now().millisecondsSinceEpoch}-$lastMessageId-$broadcast-$id-${randomVM.nextInt(RANDOM_SIZE)}";
  }

  Future<String> createBroadcastMessagePackedId(
    Uid broadcastRoomUid,
    int broadcastMessageId,
  ) {
    return _getPacketIdWithLastMessageId(
      broadcastRoomUid,
      isBroadcastMessage: true,
      id: broadcastMessageId,
    );
  }

  FutureOr<Message?> getMessage({
    required Uid roomUid,
    required int id,
    int? lastMessageId,
    bool useCache = true,
  }) async {
    if (lastMessageId == null || id <= lastMessageId) {
      if (useCache) {
        final msg = _cachingRepo.getMessage(roomUid, id);
        if (msg != null) {
          return msg;
        }
      }

      final page = (id / PAGE_SIZE).floor();
      await _getMessageFromDb(
        page,
        roomUid,
        id,
        lastMessageId: lastMessageId,
      );

      if (_cachingRepo.getMessage(roomUid, id) != null) {
        return _cachingRepo.getMessage(roomUid, id);
      }

      await _getMessagesFromServer(roomUid, page, PAGE_SIZE);
      return _cachingRepo.getMessage(roomUid, id);
    }
    return null;
  }

  Future<void> _getMessageFromDb(
    int page,
    Uid roomUid,
    int containsId, {
    int? lastMessageId,
  }) async {
    final key = "$roomUid-$page-db";
    var completer = _completerMap[key];
    if (completer == null || completer.isCompleted) {
      completer = Completer();
      _completerMap[key] = completer;

      await _messageDao.getMessagePage(roomUid, page).then((messages) async {
        _cachingRepo.setMessages(roomUid, messages);
        completer!.complete(messages);
      });
    } else {
      await completer.future;
    }
  }

  Future<void> _getMessagesFromServer(
    Uid roomUid,
    int page,
    int pageSize, {
    bool retry = true,
  }) async {
    if (!settings.localNetworkMessenger.value) {
      final key = "$roomUid-$page";
      var completer = _completerMap[key];
      if (completer == null || completer.isCompleted) {
        completer = Completer();
        _completerMap[key] = completer;
        try {
          final fetchMessagesRes = await _sdr.queryServiceClient.fetchMessages(
            FetchMessagesReq()
              ..roomUid = roomUid
              ..pointer = Int64(page * pageSize)
              ..type = FetchMessagesReq_Type.FORWARD_FETCH
              ..limit = pageSize,
          );
          final nonRepeatedMessage =
              _nonRepeatedMessageForApplyingActions(fetchMessagesRes.messages);
          await _dataStreamServices.handleFetchMessagesActions(
            roomUid,
            nonRepeatedMessage,
          );
          final messages = await _dataStreamServices
              .saveFetchMessages(fetchMessagesRes.messages);
          _cachingRepo.setMessages(
            roomUid,
            messages,
          );
          completer.complete([]);
        } catch (e) {
          _logger.e(e);
          completer.complete([]);
          if (retry) {
            await _getMessagesFromServer(roomUid, page, pageSize, retry: false);
          }
        }
      } else {
        await completer.future;
      }
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

  void sendActivity(Uid to, ActivityType activityType) {
    if (to.category == Categories.GROUP || to.category == Categories.USER) {
      final activityByClient = ActivityByClient()
        ..typeOfActivity = activityType
        ..to = to;
      _coreServices.sendActivity(activityByClient, _getPacketId());
    }
  }

  Future<void> sendFormResultMessage(
    Uid botUid,
    form_pb.FormResult formResult,
    int formMessageId,
  ) async {
    final jsonString = (formResult).writeToJson();
    final msg = (await _createMessage(
      botUid,
      replyId: formMessageId,
    ))
        .copyWith(type: MessageType.FORM_RESULT, json: jsonString);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);

    return _saveAndSend(pm);
  }

  Future<void> sendShareUidMessage(
    Uid uid,
    message_pb.ShareUid shareUid,
  ) async {
    final json = shareUid.writeToJson();

    final msg = (await _createMessage(uid))
        .copyWith(type: MessageType.SHARE_UID, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    return _saveAndSend(pm);
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

    final msg = (await _createMessage(to))
        .copyWith(type: MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    return _saveAndSend(pm);
  }

  Future<List<Message>> searchMessage(String str, String roomId) async => [];

  Future<Message?> getSingleMessageFromDb({
    required Uid roomUid,
    required int id,
    bool useCache = true,
  }) async {
    if (useCache) {
      final msg = _cachingRepo.getMessage(roomUid, id);
      if (msg != null) {
        return msg;
      }
    }
    return _messageDao.getMessageById(roomUid, id);
  }

  Future<PendingMessage?> getPendingMessage(String packetId) =>
      _pendingMessageDao.getPendingMessage(packetId);

  Future<PendingMessage?> getPendingEditedMessage(Uid roomUid, int? index) =>
      _pendingMessageDao.getPendingEditedMessage(roomUid, index);

  Stream<List<PendingMessage>> watchPendingMessages(Uid roomUid) =>
      _pendingMessageDao.watchPendingMessages(roomUid);

  Stream<List<PendingMessage>> watchPendingEditedMessages(Uid roomUid) =>
      _pendingMessageDao.watchPendingEditedMessages(roomUid);

  Future<List<PendingMessage>> getPendingMessages(String roomUid) =>
      _pendingMessageDao.getPendingMessages(roomUid);

  Future<void> resendMessage(Message msg) async {
    final pm = await _pendingMessageDao.getPendingMessage(msg.packetId);
    unawaited(_saveAndSend(pm!));
  }

  Future<void> onDeletePendingMessage(Message message) async {
    final room = (await _roomRepo.getRoom(message.roomUid));
    if (room != null) {
      await _dataStreamServices.fetchLastNotHiddenMessage(
        room.uid,
        room.lastMessageId,
        room.firstMessageId,
      );
    }
    if (message.type == MessageType.FILE) {
      _fileRepo.cancelUploadFile(message.json.toFile().uuid);
    }
  }

  void deletePendingMessage(String packetId) {
    _pendingMessageDao.deletePendingMessage(packetId);
  }

  void deletePendingEditedMessage(Uid roomUid, int? index) {
    _pendingMessageDao.deletePendingEditedMessage(roomUid, index);
    messageEventSubject.add(
      MessageEvent(
        roomUid,
        clock.now().millisecondsSinceEpoch,
        index ?? 0,
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
    Uid? forwardedFrom,
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
    final msg = (await _createMessage(
      roomUid,
      replyId: replyId,
      forwardedFrom: forwardedFrom,
    ))
        .copyWith(type: MessageType.LIVE_LOCATION, json: json);

    final pm = _createPendingMessage(msg, SendingStatus.PENDING);
    unawaited(_saveAndSend(pm));
    _liveLocationRepo.sendLiveLocationAsStream(res.uuid, duration, location);
  }

  Future<bool> _deleteMessage(Message message) async {
    try {
      final request = DeleteMessageReq()
        ..messageId = Int64(message.id!)
        ..roomUid = message.roomUid;
      if (settings.localNetworkMessenger.value) {
        _serverLessMessageService.deleteMessage(request);
      } else {
        await _sdr.queryServiceClient.deleteMessage(request);
      }

      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<void> deleteMessage(List<Message> messages) async {
    try {
      for (final message in messages) {
        if (message.id != null && _metaRepo.isMessageContainMeta(message)) {
          unawaited(_metaRepo.addDeletedMetaIndexFromMessage(message));
        }
        final msg = message.copyDeleted();

        if (msg.id == null) {
          deletePendingMessage(msg.packetId);
        } else {
          if (await _deleteMessage(msg)) {
            _cachingRepo.setMessage(
                msg.roomUid, msg.localNetworkMessageId!, msg);

            await _messageDao.updateMessage(msg);
            messageEventSubject.add(
              MessageEvent(
                message.roomUid,
                clock.now().millisecondsSinceEpoch,
                message.id!,
                message.localNetworkMessageId!,
                MessageEventAction.DELETE,
              ),
            );

            final room = (await _roomRepo.getRoom(msg.roomUid))!;

            Message? lastNotHiddenMessage;
            if (msg.id == room.lastMessage?.id) {
              lastNotHiddenMessage =
                  await _dataStreamServices.fetchLastNotHiddenMessage(
                room.uid,
                room.lastMessageId,
                room.firstMessageId,
              );
            }
            await _roomDao.updateRoom(
              uid: msg.roomUid,
              lastUpdateTime: settings.localNetworkMessenger.value
                  ? DateTime.now().millisecondsSinceEpoch
                  : null,
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
        ..to = editableMessage.to
        ..replyToId = Int64(editableMessage.replyToId)
        ..text = message_pb.Text(text: text);
      final pm = _createPendingMessage(
        editableMessage.copyWith(
          json: (message_pb.Text()..text = text).writeToJson(),
          edited: true,
        ),
        SendingStatus.PENDING,
      );
      await _savePendingMessage(pm);
      messageEventSubject.add(
        MessageEvent(
          editableMessage.roomUid,
          clock.now().millisecondsSinceEpoch,
          editableMessage.id!,
          editableMessage.localNetworkMessageId!,
          MessageEventAction.PENDING_EDIT,
        ),
      );

      await _edit(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(editableMessage.id ?? 0),
      );

      deletePendingEditedMessage(
        editableMessage.roomUid,
        editableMessage.id,
      );
      await _messageDao.updateMessage(
        editableMessage.copyWith(
          json: (message_pb.Text()..text = text).writeToJson(),
          edited: true,
        ),
      );
      messageEventSubject.add(
        MessageEvent(
          editableMessage.roomUid,
          clock.now().millisecondsSinceEpoch,
          editableMessage.id!,
          editableMessage.localNetworkMessageId!,
          MessageEventAction.EDIT,
        ),
      );
      final room = (await _roomDao.getRoom(editableMessage.roomUid))!;

      if (editableMessage.localNetworkMessageId == room.lastMessage?.id) {
        await _roomDao.updateRoom(
          uid: roomUid,
          lastUpdateTime: DateTime.now().millisecondsSinceEpoch,
          lastMessage: editableMessage.copyWith(
              json: (message_pb.Text()..text = text).writeToJson()),
        );
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _edit(UpdateMessageReq updateMessageReq) async {
    if (settings.localNetworkMessenger.value) {
      _serverLessMessageService.editMessage(
        messageByClient: updateMessageReq.message,
        messageId: updateMessageReq.messageId.toInt(),
      );
    } else {
      await _sdr.queryServiceClient.updateMessage(updateMessageReq);
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
            editableMessage.localNetworkMessageId!,
            MessageEventAction.PENDING_EDIT,
          ),
        );
        updatedFile = await _sendFileToServerOfPendingEditedMessage(
          _createPendingMessage(
            editableMessage.copyWith(
              json: (await _createFakeSendFile(file, uploadKey, caption))
                  .writeToJson(),
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
        await _savePendingMessage(pm);
        messageEventSubject.add(
          MessageEvent(
            editableMessage.roomUid,
            clock.now().millisecondsSinceEpoch,
            editableMessage.id!,
            editableMessage.localNetworkMessageId!,
            MessageEventAction.PENDING_EDIT,
          ),
        );
      }
      final updatedMessage = message_pb.MessageByClient()
        ..to = editableMessage.to
        ..file = updatedFile!;
      await _sdr.queryServiceClient.updateMessage(
        UpdateMessageReq()
          ..message = updatedMessage
          ..messageId = Int64(editableMessage.id ?? 0),
      );
      deletePendingEditedMessage(editableMessage.roomUid, editableMessage.id);
      editableMessage = editableMessage.copyWith(
        json: updatedFile.writeToJson(),
        edited: true,
      );
      await _messageDao.updateMessage(editableMessage);
      messageEventSubject.add(
        MessageEvent(
          editableMessage.roomUid,
          clock.now().millisecondsSinceEpoch,
          editableMessage.id!,
          editableMessage.localNetworkMessageId!,
          MessageEventAction.EDIT,
        ),
      );

      final room = (await _roomDao.getRoom(editableMessage.roomUid))!;

      if (editableMessage.id == room.lastMessage?.id) {
        await _roomDao.updateRoom(
          uid: roomUid,
          lastMessage: editableMessage,
        );
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
