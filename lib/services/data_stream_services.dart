import 'dart:async';

import 'package:clock/clock.dart';
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
import 'package:deliver/box/seen.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/models/message_event.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
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
  final _sdr = GetIt.I.get<MucDao>();
  final _services = GetIt.I.get<ServicesDiscoveryRepo>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _messageExtractorServices = GetIt.I.get<MessageExtractorServices>();
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();

  Future<message_model.Message?> handleIncomingMessage(
    Message message, {
    String? roomName,
    required bool isOnlineMessage,
    bool saveInDatabase = true,
    bool isFirebaseMessage = false,
  }) async {
    final roomUid = getRoomUid(_authRepo, message);
    if (isOnlineMessage) {
      await _checkForReplyKeyBoard(message);
    }

    if (await _roomRepo.isRoomBlocked(roomUid.asString())) {
      return null;
    }
    if (message.whichType() == Message_Type.persistEvent) {
      switch (message.persistEvent.whichType()) {
        case PersistentEvent_Type.mucSpecificPersistentEvent:
          if (!isOnlineMessage) {
            break;
          }
          switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
            case MucSpecificPersistentEvent_Issue.DELETED:
              await _roomDao.updateRoom(uid: roomUid.asString(), deleted: true);
              return null;
            case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
              break;

            case MucSpecificPersistentEvent_Issue.KICK_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                await _roomDao.updateRoom(
                  uid: message.from.asString(),
                  deleted: true,
                );
              }
              break;
            case MucSpecificPersistentEvent_Issue.JOINED_USER:
            case MucSpecificPersistentEvent_Issue.ADD_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                await _roomDao.updateRoom(
                  uid: message.from.asString(),
                  deleted: false,
                );
              }
              break;

            case MucSpecificPersistentEvent_Issue.LEAVE_USER:
              if (_authRepo.isCurrentUserUid(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                await _roomDao.updateRoom(
                  uid: message.from.asString(),
                  deleted: true,
                );
              }
              await _sdr.deleteMember(
                Member(
                  memberUid: message
                      .persistEvent.mucSpecificPersistentEvent.issuer
                      .asString(),
                  mucUid: roomUid.asString(),
                ),
              );
              break;
            case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
              await _avatarRepo.fetchAvatar(message.from, forceToUpdate: true);
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
              await _onMessageEdited(
                roomUid,
                message,
                isOnlineMessage: isOnlineMessage,
              );
              break;
            case MessageManipulationPersistentEvent_Action.DELETED:
              await _onMessageDeleted(
                roomUid,
                message,
                isOnlineMessage: isOnlineMessage,
              );
              break;
          }
          break;
        case PersistentEvent_Type.adminSpecificPersistentEvent:
        case PersistentEvent_Type.botSpecificPersistentEvent:
        case PersistentEvent_Type.notSet:
          break;
      }
    } else if (message.whichType() == Message_Type.callEvent &&
        isOnlineMessage) {
      final callEvents = CallEvents.callEvent(
        message.callEvent,
        roomUid: message.from,
        callId: message.callEvent.callId,
        time: message.time.toInt(),
      );
      _callService
        ..addCallEvent(callEvents)
        ..shouldRemoveData = isFirebaseMessage;
    }

    final msg = (await saveMessageInMessagesDB(message))!;

    if (isOnlineMessage) {
      // Step 1 - Update Room Info

      // Check if Mentioned.
      bool? hasMentioned;
      if (roomUid.category == Categories.GROUP) {
        if (message.text.text
            .replaceAll("\n", " ")
            .split(" ")
            .contains("@${(await _accountRepo.getAccount())!.username}")) {
          hasMentioned = true;
        }
      }

      await _roomDao.updateRoom(
        uid: roomUid.asString(),
        lastMessage: msg.isHidden ? null : msg,
        lastMessageId: msg.id,
        lastUpdateTime: msg.time,
        mentioned: hasMentioned,
        deleted: false,
      );

      // Step 2 - Update User's Seen
      await _fetchMySeen(roomUid.asString());

      // Step 3 - Update Hidden Message Count
      if (msg.isHidden) {
        await _increaseHiddenMessageCount(roomUid.asString());
      }

      // Step 4 - Notify Message
      if (!msg.isHidden && await shouldNotifyForThisMessage(message)) {
        _notificationServices.notifyIncomingMessage(
          message,
          roomUid.asString(),
          roomName: roomName,
        );
      }

      // Step 5 - Update Activity to NO_ACTIVITY
      _roomRepo.updateActivity(
        Activity()
          ..from = message.from
          ..to = message.to
          ..typeOfActivity = ActivityType.NO_ACTIVITY,
      );

      // Step 6 - Update Activity Time of User
      if (message.from.category == Categories.USER) {
        _updateLastActivityTime(
          _lastActivityDao,
          message.from,
          message.time.toInt(),
        );
      }
    }

    return msg;
  }

  Future<void> _checkForReplyKeyBoard(Message message) async {
    final roomUid = getRoomUid(_authRepo, message);
    if (message.messageMarkup.replyKeyboardMarkup.rows.isNotEmpty) {
      await _roomRepo.updateReplyKeyboard(
        message.messageMarkup.replyKeyboardMarkup.writeToJson(),
        roomUid.asString(),
      );
    } else if (message.messageMarkup.removeReplyKeyboardMarkup) {
      await _roomRepo.updateReplyKeyboard(
        null,
        roomUid.asString(),
      );
    }
  }

  Future<void> _fetchMySeen(String roomUid) async {
    final mySeen = await _seenDao.getMySeen(roomUid);
    if (mySeen.messageId < 0) {
      await _seenDao.updateMySeen(
        uid: roomUid,
        messageId: 0,
        hiddenMessageCount: 0,
      );
    }
  }

  Future<void> _increaseHiddenMessageCount(String roomUid) async {
    final mySeen = await _seenDao.getMySeen(roomUid);

    await _seenDao.updateMySeen(
      uid: roomUid,
      hiddenMessageCount: mySeen.hiddenMessageCount + 1,
    );
  }

  Future<void> _onMessageDeleted(
    Uid roomUid,
    Message message, {
    required bool isOnlineMessage,
  }) async {
    final id = message.persistEvent.messageManipulationPersistentEvent.messageId
        .toInt();

    final deleteActionTime = message.time.toInt();

    if (isOnlineMessage) {
      final mySeen = await _seenDao.getMySeen(roomUid.asString());
      if (0 < mySeen.messageId && mySeen.messageId <= id) {
        await _increaseHiddenMessageCount(roomUid.asString());
      }
    }

    final savedMsg = await _messageDao.getMessage(roomUid.asString(), id);

    if (savedMsg != null) {
      final msg = savedMsg.copyDeleted();

      if (msg.type == MessageType.FILE && msg.id != null) {
        await _mediaDao.deleteMedia(roomUid.asString(), msg.id!);
      }

      await _messageDao.saveMessage(msg);

      if (isOnlineMessage) {
        final room = await _roomDao.getRoom(roomUid.asString());
        if (room!.lastMessage != null && room.lastMessage!.id == id) {
          final lastNotHiddenMessage = await fetchLastNotHiddenMessage(
            roomUid,
            room.lastMessageId,
            room.firstMessageId,
          );

          await _roomDao.updateRoom(
            uid: roomUid.asString(),
            lastMessage: lastNotHiddenMessage ?? savedMsg,
          );
        }
        _notificationServices.cancelNotificationById(id, roomUid.asString());
      }
      messageEventSubject.add(
        MessageEvent(
          roomUid.asString(),
          deleteActionTime,
          id,
          MessageEventAction.DELETE,
        ),
      );
    }
  }

  Future<void> _onMessageEdited(
    Uid roomUid,
    Message message, {
    required bool isOnlineMessage,
  }) async {
    final id = message.persistEvent.messageManipulationPersistentEvent.messageId
        .toInt();

    final time = message.time.toInt();

    //if from fetch that means non repeated and should be save
    final savedMsg = await _messageDao.getMessage(roomUid.asString(), id);

    // there is no message in db for editing, so if we fetch it eventually, it will be edited anyway
    if (savedMsg == null) return;

    final res = await _services.queryServiceClient.fetchMessages(
      FetchMessagesReq()
        ..roomUid = roomUid
        ..limit = 1
        ..pointer = Int64(id)
        ..type = FetchMessagesReq_Type.FORWARD_FETCH,
    );
    final msg = await saveMessageInMessagesDB(res.messages.first);

    if (isOnlineMessage) {
      final room = await _roomDao.getRoom(roomUid.asString());
      if (room != null && room.lastMessage?.id == id) {
        await _roomDao.updateRoom(
          uid: room.uid,
          lastMessage: msg,
        );
      }
    }

    messageEventSubject.add(
      MessageEvent(
        roomUid.asString(),
        time,
        id,
        MessageEventAction.EDIT,
      ),
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
      final room = await _roomDao.getRoom(roomId!.asString());
      int? hiddenMessageCount;

      if (room != null &&
          room.lastMessage != null &&
          room.lastMessage!.id != null &&
          room.lastMessage!.id == seen.id.toInt()) {
        hiddenMessageCount = 0;
      }

      await _seenDao.updateMySeen(
        uid: roomId.asString(),
        messageId: seen.id.toInt(),
        hiddenMessageCount: hiddenMessageCount,
      );
      _notificationServices.cancelRoomNotifications(roomId.asString());
    } else {
      await _seenDao.saveOthersSeen(
        Seen(
          uid: roomId!.asString(),
          messageId: seen.id.toInt(),
          hiddenMessageCount: 0,
        ),
      );
      _updateLastActivityTime(
        _lastActivityDao,
        seen.from,
        clock.now().millisecondsSinceEpoch,
      );
    }
  }

  void handleActivity(Activity activity) {
    _roomRepo.updateActivity(activity);
    _updateLastActivityTime(
      _lastActivityDao,
      activity.from,
      clock.now().millisecondsSinceEpoch,
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
        await _messageDao.deletePendingMessage(packetId);
      } catch (e) {
        _logger.e(e);
      }
      await _messageDao.saveMessage(msg);
      await _roomDao.updateRoom(
        uid: msg.roomUid,
        lastMessage: msg.isHidden ? null : msg,
        lastMessageId: msg.id,
      );
      _notificationServices
          .notifyOutgoingMessage(messageDeliveryAck.to.asString());
      final seen = await _roomRepo.getMySeen(msg.roomUid);
      if (messageDeliveryAck.id > seen.messageId) {
        _roomRepo
            .updateMySeen(
              uid: msg.roomUid,
              messageId: messageDeliveryAck.id.toInt(),
            )
            .ignore();
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
        lastUpdate: clock.now().millisecondsSinceEpoch,
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
    _callService.addCallEvent(callEvents);
  }

  void handleCallAnswer(call_pb.CallAnswer callAnswer) {
    final callEvents = CallEvents.callAnswer(
      callAnswer,
      roomUid: getRoomUidOf(_authRepo, callAnswer.from, callAnswer.to),
      callId: callAnswer.id,
    );
    _callService.addCallEvent(callEvents);
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

  Future<message_model.Message?> saveMessageInMessagesDB(
    Message message,
  ) async {
    try {
      final msg = _messageExtractorServices.extractMessage(message);
      await _messageDao.saveMessage(msg);
      return msg;
    } catch (e) {
      return null;
    }
  }

  Future<message_model.Message?> fetchLastNotHiddenMessage(
    Uid roomUid,
    int lastMessageId,
    int firstMessageId, {
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
            _roomDao
                .updateRoom(uid: roomUid.asString(), deleted: true)
                .ignore();
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
      } on GrpcError catch (e) {
        if (e.code == StatusCode.notFound) {
          _roomDao
              .updateRoom(
                uid: roomUid.asString(),
                deleted: true,
              )
              .ignore();
          break;
        }
      } catch (_) {
        return null;
      }
    }

    if (lastNotHiddenMessage != null) {
      _roomDao
          .updateRoom(
            uid: roomUid.asString(),
            firstMessageId: firstMessageId,
            lastMessageId: lastMessageId,
            synced: true,
            lastMessage: lastNotHiddenMessage,
          )
          .ignore();
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
    final fetchMessagesRes = await _services.queryServiceClient.fetchMessages(
      FetchMessagesReq()
        ..roomUid = roomUid
        ..pointer = Int64(pointer)
        ..justNotHiddenMessages = true
        ..type = FetchMessagesReq_Type.BACKWARD_FETCH
        ..limit = 1,
    );

    final messages =
        await saveFetchMessages(fetchMessagesRes.messages, isLastMessage: true);

    for (final msg in messages) {
      if (msg.id! <= firstMessageId && (msg.isHidden && msg.id == 1)) {
        await _roomDao.updateRoom(uid: roomUid.asString(), deleted: true);
        return null;
      } else if (!msg.isHidden) {
        return msg;
      }
    }

    return null;
  }

  Future<void> getAndProcessLastIncomingCallsFromServer(
    Uid roomUid,
    int lastMessageId,
  ) async {
    if (_callService.getUserCallState != UserCallState.NO_CALL) {
      return; // Dont do anything if there is an active call.
    }

    final pointer = lastMessageId;
    try {
      // TODO(hasan): Add just hidden message flag in protocol for better query to server just for hidden message of calls.
      final fetchMessagesRes = await _services.queryServiceClient.fetchMessages(
        FetchMessagesReq()
          ..roomUid = roomUid
          ..pointer = Int64(pointer)
          ..type = FetchMessagesReq_Type.FORWARD_FETCH
          ..limit = 10,
        options: CallOptions(timeout: const Duration(seconds: 3)),
      );
      for (final message in fetchMessagesRes.messages.reversed) {
        if (message.whichType() == Message_Type.callEvent) {
          final callEvents = CallEvents.callEvent(
            message.callEvent,
            roomUid: message.from,
            callId: message.callEvent.callId,
            time: message.time.toInt(),
          );
          _callService.addCallEvent(callEvents);
          break;
        }
      }
    } catch (_) {}
  }

  Future<void> handleFetchMessagesActions(
    String roomId,
    List<Message> messages,
  ) async {
    for (final message in messages) {
      if (message.whichType() == Message_Type.persistEvent) {
        // if message persistEvent they are one hundred percent be a messageManipulationPersistentEvent
        switch (
            message.persistEvent.messageManipulationPersistentEvent.action) {
          case MessageManipulationPersistentEvent_Action.EDITED:
            await _onMessageEdited(
              roomId.asUid(),
              message,
              isOnlineMessage: false,
            );
            break;
          case MessageManipulationPersistentEvent_Action.DELETED:
            await _onMessageDeleted(
              roomId.asUid(),
              message,
              isOnlineMessage: false,
            );
            break;
        }
        break;
      }
    }
  }

  Future<List<message_model.Message>> saveFetchMessages(
    List<Message> messages, {
    bool isLastMessage = false,
  }) async {
    final msgList = <message_model.Message>[];
    for (final message in messages) {
      if (messages.last.id - message.id < 100) {
        await _checkForReplyKeyBoard(message);
      }
      await _messageDao.deletePendingMessage(message.packetId);
      var appRunInForeground = false;

      try {
        appRunInForeground =
            isLastMessage && !_appLifecycleService.appIsActive();
      } catch (e) {
        _logger.e(e);
      }

      try {
        final m = await handleIncomingMessage(
          message,
          isOnlineMessage: appRunInForeground,
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
