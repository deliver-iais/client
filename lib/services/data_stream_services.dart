import 'dart:async';

import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/message.dart' as message_model;
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/call.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// All services about streams of data from Core service or Firebase Streams
class DataStreamServices {
  final _logger = GetIt.I.get<Logger>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _callService = GetIt.I.get<CallService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _lastActivityDao = GetIt.I.get<LastActivityDao>();
  final _mucDao = GetIt.I.get<MucDao>();
  final _queryServicesClient = GetIt.I.get<QueryServiceClient>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _mediaDao = GetIt.I.get<MediaDao>();

  Future<void> handleIncomingMessage(
    Message message, {
    String? roomName,
  }) async {
    final roomUid = getRoomUid(_authRepo, message);
    if (await _roomRepo.isRoomBlocked(roomUid.asString())) {
      return;
    }
    if (message.whichType() == Message_Type.persistEvent) {
      switch (message.persistEvent.whichType()) {
        case PersistentEvent_Type.mucSpecificPersistentEvent:
          switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
            case MucSpecificPersistentEvent_Issue.DELETED:
              _roomDao.updateRoom(Room(uid: roomUid.asString(), deleted: true));
              return;
            case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
              {
                final muc = await _mucDao.get(roomUid.asString());
                final pinMessages = muc!.pinMessagesIdList;
                pinMessages!.add(
                  message.persistEvent.mucSpecificPersistentEvent.messageId
                      .toInt(),
                );
                _mucDao.update(
                  muc.copyWith(
                    uid: muc.uid,
                    pinMessagesIdList: pinMessages,
                    showPinMessage: true,
                  ),
                );
                break;
              }

            case MucSpecificPersistentEvent_Issue.KICK_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                _roomDao.updateRoom(
                  Room(uid: message.from.asString(), deleted: true),
                );
                return;
              }
              break;
            case MucSpecificPersistentEvent_Issue.JOINED_USER:
            case MucSpecificPersistentEvent_Issue.ADD_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                _roomDao.updateRoom(
                  Room(uid: message.from.asString(), deleted: false),
                );
              }
              break;

            case MucSpecificPersistentEvent_Issue.LEAVE_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                _roomDao.updateRoom(
                  Room(uid: message.from.asString(), deleted: true),
                );
                return;
              }
              _mucDao.deleteMember(
                Member(
                  memberUid: message
                      .persistEvent.mucSpecificPersistentEvent.issuer
                      .asString(),
                  mucUid: roomUid.asString(),
                ),
              );
              break;
            case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
              _avatarRepo.fetchAvatar(message.from, forceToUpdate: true);
              break;
            case MucSpecificPersistentEvent_Issue.MUC_CREATED:
            case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
              // TODO(hasan): Handle these cases, https://gitlab.iais.co/deliver/wiki/-/issues/429
              break;
          }
          break;
        case PersistentEvent_Type.messageManipulationPersistentEvent:
          switch (
              message.persistEvent.messageManipulationPersistentEvent.action) {
            case MessageManipulationPersistentEvent_Action.EDITED:
              await _messageEdited(
                roomUid,
                message
                    .persistEvent.messageManipulationPersistentEvent.messageId
                    .toInt(),
                message.time.toInt(),
              );
              return;
            case MessageManipulationPersistentEvent_Action.DELETED:
              final mes = await _messageDao.getMessage(
                roomUid.asString(),
                message
                    .persistEvent.messageManipulationPersistentEvent.messageId
                    .toInt(),
              );
              if (mes != null &&
                  mes.type == MessageType.FILE &&
                  mes.id != null) {
                _mediaDao.deleteMedia(roomUid.asString(), mes.id!);
              }
              _messageDao.saveMessage(mes!..json = EMPTY_MESSAGE);
              _roomDao.updateRoom(
                Room(uid: roomUid.asString(), lastUpdatedMessageId: mes.id),
              );
              return;
          }
          break;
        case PersistentEvent_Type.adminSpecificPersistentEvent:
        case PersistentEvent_Type.botSpecificPersistentEvent:
          // TODO(hasan): Handle these cases, https://gitlab.iais.co/deliver/wiki/-/issues/429
          break;
        case PersistentEvent_Type.notSet:
          break;
      }
    } else if (message.whichType() == Message_Type.callEvent) {
      final callEvents = CallEvents.callEvent(
        message.callEvent,
        roomUid: message.from,
        callId: message.callEvent.id,
      );
      if (message.callEvent.callType == CallEvent_CallType.GROUP_AUDIO ||
          message.callEvent.callType == CallEvent_CallType.GROUP_VIDEO) {
        _callService.addGroupCallEvent(callEvents);
      } else {
        _callService.addCallEvent(callEvents);
      }
    }
    final msg = await saveMessage(message, roomUid);

    if (!msg.json.isEmptyMessage() &&
        await shouldNotifyForThisMessage(message)) {
      // TODO(hasan): this code should go to the notification service itself i think, https://gitlab.iais.co/deliver/wiki/-/issues/430
      if (_routingServices.isInRoom(roomUid.asString()) &&
          !isDesktop &&
          message.callEvent.newStatus != CallEvent_CallStatus.CREATED) {
        _notificationServices.playSoundIn();
      } else {
        _notificationServices.showTextNotification(message, roomName: roomName);
      }
    }
    if (message.from.category == Categories.USER) {
      _updateLastActivityTime(
        _lastActivityDao,
        message.from,
        message.time.toInt(),
      );
    }
  }

  Future<void> _messageEdited(Uid roomUid, int id, int time) async {
    final res = await _queryServicesClient.fetchMessages(
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
    if (room!.lastMessageId != id) {
      _roomDao.updateRoom(
        room.copyWith(
          lastUpdateTime: time,
          lastUpdatedMessageId: res.messages.first.id.toInt(),
        ),
      );
    } else {
      _roomDao.updateRoom(
        room.copyWith(
          lastMessage: msg,
          lastUpdateTime: time,
          lastUpdatedMessageId: res.messages.first.id.toInt(),
        ),
      );
    }
  }

  Future<void> handleSeen(seen_pb.Seen seen) async {
    Uid? roomId;
    switch (seen.to.category) {
      case Categories.USER:
        _authRepo.isCurrentUserUid(seen.to)
            ? roomId = seen.from
            : roomId = seen.to;
        break;
      case Categories.STORE:
      case Categories.SYSTEM:
      case Categories.GROUP:
      case Categories.CHANNEL:
      case Categories.BOT:
        roomId = seen.to;
        break;
    }
    if (_authRepo.isCurrentUser(seen.from.asString())) {
      _seenDao.saveMySeen(
        Seen(uid: roomId!.asString(), messageId: seen.id.toInt()),
      );
      _notificationServices.cancelRoomNotifications(roomId.asString());
    } else {
      _seenDao.saveOthersSeen(
        Seen(uid: roomId!.asString(), messageId: seen.id.toInt()),
      );
      _updateLastActivityTime(
        _lastActivityDao,
        seen.from,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  void handleActivity(Activity activity) {
    _roomRepo.updateActivity(activity);
    _updateLastActivityTime(
      _lastActivityDao,
      activity.from,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> handleAckMessage(MessageDeliveryAck messageDeliveryAck) async {
    if (messageDeliveryAck.id.toInt() == 0) {
      return;
    }
    final packetId = messageDeliveryAck.packetId;
    final id = messageDeliveryAck.id.toInt();
    final time = messageDeliveryAck.time.toInt();

    final pm = await _messageDao.getPendingMessage(packetId);
    if (pm != null) {
      final msg = pm.msg.copyWith(id: id, time: time);
      try {
        _messageDao.deletePendingMessage(packetId);
      } catch (e) {
        _logger.e(e);
      }
      _messageDao.saveMessage(msg);
      _roomDao.updateRoom(
        Room(uid: msg.roomUid, lastMessage: msg, lastMessageId: msg.id),
      );

      if (_routingServices.isInRoom(messageDeliveryAck.to.asString())) {
        _notificationServices.playSoundOut();
      }
      if (msg.type == MessageType.FILE) {
        _updateRoomMediaMetadata(msg.roomUid, msg);
      }
    }
  }

  void _updateLastActivityTime(
    LastActivityDao lastActivityDao,
    Uid userUid,
    int time,
  ) {
    lastActivityDao.save(
      LastActivity(
        uid: userUid.asString(),
        time: time,
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  void handleRoomPresenceTypeChange(
    RoomPresenceTypeChanged roomPresenceTypeChanged,
  ) {
    final type = roomPresenceTypeChanged.presenceType;
    _roomDao.updateRoom(
      Room(
        uid: roomPresenceTypeChanged.uid.asString(),
        deleted: type == PresenceType.BANNED ||
            type == PresenceType.DELETED ||
            type == PresenceType.KICKED ||
            type == PresenceType.LEFT ||
            type != PresenceType.ACTIVE,
      ),
    );
  }

  void handleCallOffer(call_pb.CallOffer callOffer) {
    final callEvents = CallEvents.callOffer(
      callOffer,
      roomUid: getRoomUidOf(_authRepo, callOffer.from, callOffer.to),
      callId: callOffer.id,
    );
    if (callOffer.callType == call_pb.CallEvent_CallType.GROUP_AUDIO ||
        callOffer.callType == call_pb.CallEvent_CallType.GROUP_VIDEO) {
      _callService.addGroupCallEvent(callEvents);
    } else {
      _callService.addCallEvent(callEvents);
    }
  }

  void handleCallAnswer(call_pb.CallAnswer callAnswer) {
    final callEvents = CallEvents.callAnswer(
      callAnswer,
      roomUid: getRoomUidOf(_authRepo, callAnswer.from, callAnswer.to),
      callId: callAnswer.id,
    );
    if (callAnswer.callType == call_pb.CallEvent_CallType.GROUP_AUDIO ||
        callAnswer.callType == call_pb.CallEvent_CallType.GROUP_VIDEO) {
      _callService.addGroupCallEvent(callEvents);
    } else {
      _callService.addCallEvent(callEvents);
    }
  }

  Future<bool> shouldNotifyForThisMessage(Message message) async {
    final authRepo = GetIt.I.get<AuthRepo>();
    final uxService = GetIt.I.get<UxService>();
    final roomRepo = GetIt.I.get<RoomRepo>();

    final roomUid = getRoomUid(authRepo, message);

    if (message.shouldBeQuiet) {
      return false;
    } else if (uxService.isAllNotificationDisabled ||
        await roomRepo.isRoomMuted(roomUid.asString())) {
      // If Notification is Off
      return false;
    } else if (authRepo.isCurrentUser(message.from.asString())) {
      // If Message is from Current User
      return false;
    } else if (message.whichType() == Message_Type.callEvent) {
      // CallEvent message should be handled in CallRepo instead of here.
      return false;
    } else if (message.whichType() == Message_Type.persistEvent &&
        message.persistEvent.whichType() ==
            PersistentEvent_Type.mucSpecificPersistentEvent) {
      // If Message is PE and Issuer is Current User
      return !authRepo.isCurrentUser(
        message.persistEvent.mucSpecificPersistentEvent.issuer.asString(),
      );
    }

    return true;
  }

  Future<message_model.Message> saveMessage(
    Message message,
    Uid roomUid,
  ) async {
    final msg = await saveMessageInMessagesDB(_authRepo, _messageDao, message);

    var isMention = false;
    if (roomUid.category == Categories.GROUP) {
      // TODO(chitsaz): bug: username1 = hasan , username2 = hasan2 => isMention will be triggered if @hasan2 be into the text.
      if (message.text.text
          .contains("@${(await _accountRepo.getAccount()).userName}")) {
        isMention = true;
      }
    }
    _roomDao.updateRoom(
      Room(
        uid: roomUid.asString(),
        lastMessage: msg,
        lastMessageId: msg!.id,
        mentioned: isMention,
        deleted: false,
        lastUpdateTime: msg.time,
      ),
    );
    if (message.whichType() == Message_Type.file) {
      _updateRoomMediaMetadata(roomUid.asString(), msg);
    }
    fetchSeen(roomUid.asString());

    return msg;
  }

  Future<void> fetchSeen(String roomUid) async {
    final res = await _seenDao.getMySeen(roomUid);
    if (res.messageId == -1) {
      _seenDao.saveMySeen(Seen(uid: roomUid, messageId: 0));
    }
  }

  // TODO(hasan): Maybe remove this later on, WHY just working with images ?!?!?!?!??!, https://gitlab.iais.co/deliver/wiki/-/issues/410
  Future<void> _updateRoomMediaMetadata(
    String roomUid,
    message_model.Message message,
  ) async {
    try {
      final file = message.json.toFile();
      if (file.type.contains("image") ||
          file.type.contains("jpg") ||
          file.type.contains("png")) {
        final mediaMetaData = await _mediaQueryRepo.getMediaMetaData(roomUid);
        if (mediaMetaData != null) {
          _mediaQueryRepo.saveMediaMetaData(
            mediaMetaData.copyWith(
              lastUpdateTime: message.time,
              imagesCount: mediaMetaData.imagesCount + 1,
            ),
          );
        } else {
          _mediaQueryRepo.saveMediaMetaData(
            MediaMetaData(
              roomId: roomUid,
              imagesCount: 1,
              musicsCount: 0,
              videosCount: 0,
              audiosCount: 0,
              documentsCount: 0,
              filesCount: 0,
              linkCount: 0,
              lastUpdateTime: message.time,
            ),
          );
        }
        _mediaQueryRepo.saveMediaFromMessage(message);
      }
    } catch (e) {
      // _logger.e(e);
    }
  }
}

Future<message_model.Message?> saveMessageInMessagesDB(
  AuthRepo authRepo,
  MessageDao messageDao,
  Message message,
) async {
  try {
    final msg = extractMessage(authRepo, message);
    await messageDao.saveMessage(msg);
    return msg;
  } catch (e) {
    return null;
  }
}
