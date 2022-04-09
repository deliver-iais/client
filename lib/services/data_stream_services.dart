import 'dart:async';

import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/message.dart' as message_model;
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
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
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';

/// All services about streams of data from Core service or Firebase Streams
class DataStreamServices {
  final _logger = GetIt.I.get<Logger>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _callService = GetIt.I.get<CallService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _lastActivityDao = GetIt.I.get<LastActivityDao>();
  final _mucDao = GetIt.I.get<MucDao>();
  final _queryServicesClient = GetIt.I.get<QueryServiceClient>();
  final _mediaDao = GetIt.I.get<MediaDao>();

  Future<message_model.Message?> handleIncomingMessage(
    Message message, {
    String? roomName,
    required bool isOnlineMessage,
    bool saveInDatabase = true,
  }) async {
    final roomUid = getRoomUid(_authRepo, message);
    if (await _roomRepo.isRoomBlocked(roomUid.asString())) {
      return null;
    }
    if (message.whichType() == Message_Type.persistEvent) {
      switch (message.persistEvent.whichType()) {
        case PersistentEvent_Type.mucSpecificPersistentEvent:
          switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
            case MucSpecificPersistentEvent_Issue.DELETED:
              _roomDao.updateRoom(uid: roomUid.asString(), deleted: true);
              return null;
            case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
              if (isOnlineMessage) {
                break;
              }
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

            case MucSpecificPersistentEvent_Issue.KICK_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                _roomDao.updateRoom(
                  uid: message.from.asString(),
                  deleted: true,
                );
                return null;
              }
              break;
            case MucSpecificPersistentEvent_Issue.JOINED_USER:
            case MucSpecificPersistentEvent_Issue.ADD_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                _roomDao.updateRoom(
                  uid: message.from.asString(),
                  deleted: false,
                );
              }
              break;

            case MucSpecificPersistentEvent_Issue.LEAVE_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                _roomDao.updateRoom(
                  uid: message.from.asString(),
                  deleted: true,
                );
                return null;
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
              await _onMessageEdited(roomUid, message);
              break;
            case MessageManipulationPersistentEvent_Action.DELETED:
              await _onMessageDeleted(roomUid, message);
              break;
          }
          break;
        case PersistentEvent_Type.adminSpecificPersistentEvent:
        case PersistentEvent_Type.botSpecificPersistentEvent:
        case PersistentEvent_Type.notSet:
          break;
      }
    } else if (message.whichType() == Message_Type.callEvent &&
        !isOnlineMessage) {
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

    final msg = (await saveMessageInMessagesDB(message))!;

    if (isOnlineMessage) {
      bool? hasMentioned;
      if (roomUid.category == Categories.GROUP) {
        if (message.text.text
            .split(" ")
            .contains("@${(await _accountRepo.getAccount()).userName}")) {
          hasMentioned = true;
        }
      }
      _roomDao.updateRoom(
        uid: roomUid.asString(),
        lastMessage: msg.isHidden ? null : msg,
        lastMessageId: msg.id,
        lastUpdateTime: msg.time,
        mentioned: hasMentioned,
        deleted: false,
      );
    }

    fetchSeen(roomUid.asString());

    if (isOnlineMessage &&
        !msg.isHidden &&
        await shouldNotifyForThisMessage(message)) {
      _notificationServices.notifyIncomingMessage(
        message,
        roomUid.asString(),
        roomName: roomName,
      );
    }

    if (isOnlineMessage && message.from.category == Categories.USER) {
      _updateLastActivityTime(
        _lastActivityDao,
        message.from,
        message.time.toInt(),
      );
    }

    return msg;
  }

  Future<void> _onMessageDeleted(Uid roomUid, Message message) async {
    final id = message.persistEvent.messageManipulationPersistentEvent.messageId
        .toInt();

    final time = message.time.toInt();

    final savedMsg = await _messageDao.getMessage(roomUid.asString(), id);

    if (savedMsg != null) {
      final msg = savedMsg.copyDeleted();

      if (msg.type == MessageType.FILE && msg.id != null) {
        _mediaDao.deleteMedia(roomUid.asString(), msg.id!);
      }

      _messageDao.saveMessage(msg);

      final room = await _roomDao.getRoom(roomUid.asString());

      if (room!.lastMessageId != id) {
        _roomDao.updateRoom(
          uid: roomUid.asString(),
          lastUpdatedMessageId: msg.id,
          lastUpdateTime: time,
        );
      } else {
        final lastNotHiddenMessage = await fetchLastNotHiddenMessage(
          roomUid,
          room.lastMessageId,
          room.firstMessageId,
          room,
        );

        _roomDao.updateRoom(
          uid: roomUid.asString(),
          lastMessage: lastNotHiddenMessage ?? savedMsg,
          lastUpdatedMessageId: msg.id,
          lastUpdateTime: time,
        );
      }
    }
  }

  Future<void> _onMessageEdited(Uid roomUid, Message message) async {
    final id = message.persistEvent.messageManipulationPersistentEvent.messageId
        .toInt();

    final time = message.time.toInt();

    final savedMsg = await _messageDao.getMessage(roomUid.asString(), id);

    // there is no message in db for editing, so if we fetch it eventually, it will be edited anyway
    if (savedMsg == null) return;

    final res = await _queryServicesClient.fetchMessages(
      FetchMessagesReq()
        ..roomUid = roomUid
        ..limit = 1
        ..pointer = Int64(id)
        ..type = FetchMessagesReq_Type.FORWARD_FETCH,
    );
    final msg = await saveMessageInMessagesDB(res.messages.first);
    final room = (await _roomDao.getRoom(roomUid.asString()))!;

    await _roomDao.updateRoom(
      uid: room.uid,
      lastMessage: room.lastMessageId != id ? null : msg,
      lastUpdateTime: time,
      lastUpdatedMessageId: res.messages.first.id.toInt(),
    );
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
        uid: msg.roomUid,
        lastMessage: msg,
        lastMessageId: msg.id,
      );

      _notificationServices
          .notifyOutgoingMessage(messageDeliveryAck.to.asString());
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
      uid: roomPresenceTypeChanged.uid.asString(),
      deleted: type == PresenceType.BANNED ||
          type == PresenceType.DELETED ||
          type == PresenceType.KICKED ||
          type == PresenceType.LEFT ||
          type != PresenceType.ACTIVE,
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

  Future<void> fetchSeen(String roomUid) async {
    final res = await _seenDao.getMySeen(roomUid);
    if (res.messageId == -1) {
      _seenDao.saveMySeen(Seen(uid: roomUid, messageId: 0));
    }
  }

  Future<message_model.Message?> saveMessageInMessagesDB(
    Message message,
  ) async {
    try {
      final msg = extractMessage(_authRepo, message);
      await _messageDao.saveMessage(msg);
      return msg;
    } catch (e) {
      return null;
    }
  }

  Future<message_model.Message?> fetchLastNotHiddenMessage(
    Uid roomUid,
    int lastMessageId,
    int firstMessageId,
    Room? room, {
    bool retry = true,
  }) async {
    var pointer = lastMessageId + 1;
    message_model.Message? lastNotHiddenMessage;
    while (pointer > 0) {
      pointer -= 1;

      try {
        final msg = await _messageDao.getMessage(roomUid.asString(), pointer);

        if (msg != null) {
          if (msg.id! <= firstMessageId || (msg.isHidden && msg.id == 1)) {
            _roomDao.updateRoom(uid: roomUid.asString(), deleted: true);
            break;
          } else if (!msg.isHidden) {
            lastNotHiddenMessage = msg;
            break;
          }
        } else {
          lastNotHiddenMessage = await _getLastNotHiddenMessageFromServer(
            roomUid,
            lastMessageId,
            firstMessageId,
          );
          break;
        }
      } catch (_) {
        break;
      }
    }

    if (lastNotHiddenMessage != null) {
      _roomDao.updateRoom(
        uid: roomUid.asString(),
        firstMessageId: firstMessageId,
        lastUpdateTime: lastNotHiddenMessage.time,
        lastMessageId: lastMessageId,
        lastMessage: lastNotHiddenMessage,
      );
      return lastNotHiddenMessage;
    } else {
      return null;
    }
  }

  Future<message_model.Message?> _getLastNotHiddenMessageFromServer(
    Uid roomUid,
    int pointer,
    int firstMessageId,
  ) async {
    final fetchMessagesRes = await _queryServicesClient.fetchMessages(
      FetchMessagesReq()
        ..roomUid = roomUid
        ..pointer = Int64(pointer)
        ..justNotHiddenMessages = true
        ..type = FetchMessagesReq_Type.BACKWARD_FETCH
        ..limit = 1,
      options: CallOptions(timeout: const Duration(seconds: 3)),
    );

    final messages = await saveFetchMessages(fetchMessagesRes.messages);

    for (final msg in messages) {
      if (msg.id! <= firstMessageId && (msg.isHidden && msg.id == 1)) {
        _roomDao.updateRoom(uid: roomUid.asString(), deleted: true);
        return null;
      } else if (!msg.isHidden) {
        return msg;
      }
    }

    return null;
  }

  Future<List<message_model.Message>> saveFetchMessages(
    List<Message> messages,
  ) async {
    final msgList = <message_model.Message>[];
    for (final message in messages) {
      _messageDao.deletePendingMessage(message.packetId);
      try {
        final m = await handleIncomingMessage(
          message,
          isOnlineMessage: false,
        );

        if (m == null) continue;

        msgList.add(m);
      } catch (e) {
        _logger.e(e);
      }
    }
    return msgList;
  }
}
