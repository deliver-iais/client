import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
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
import 'package:deliver/repository/caching_repo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/broadcast_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/serverless/serverless_message_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/utils/message_utils.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
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

  final _messageDao = GetIt.I.get<MessageDao>();
  final _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _lastActivityDao = GetIt.I.get<LastActivityDao>();
  final _sdr = GetIt.I.get<MucDao>();

  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _services = GetIt.I.get<ServicesDiscoveryRepo>();

  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _messageExtractorServices = GetIt.I.get<MessageExtractorServices>();
  final _broadcastService = GetIt.I.get<BroadcastService>();
  final _callService = GetIt.I.get<CallService>();
  final _cachingRepo = GetIt.I.get<CachingRepo>();

  Future<message_model.Message?> handleIncomingMessage(
    Message message, {
    String? roomName,
    required bool isOnlineMessage,
    bool saveInDatabase = true,
    bool isFirebaseMessage = false,
    bool isLocalNetworkMessage = false,
  }) async {
    final roomUid = getRoomUid(_authRepo, message);

    if (await _roomRepo.isRoomBlocked(roomUid.asString())) {
      return null;
    }
    if (roomUid.isGroup() &&
        (await _messageDao.getMessageByPacketId(roomUid, message.packetId)) !=
            null) {
      return null;
    }
    //isOnlineMessage
    if (isOnlineMessage) {
      await _checkForReplyKeyBoard(message);
    }
    //is File type check for new Media
    if (message.whichType() == Message_Type.file) {
      await _checkForNewMedia(message.file, roomUid);
    }
    //is Call Type check for current call
    if (message.whichType() == Message_Type.callLog) {
      _checkCallLogMessage(message);
    }

    if (message.whichType() == Message_Type.persistEvent) {
      switch (message.persistEvent.whichType()) {
        case PersistentEvent_Type.mucSpecificPersistentEvent:
          if (!isOnlineMessage) {
            break;
          }
          switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
            case MucSpecificPersistentEvent_Issue.DELETED:
              await _roomDao.updateRoom(uid: roomUid, deleted: true);
              return null;
            case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
              break;

            case MucSpecificPersistentEvent_Issue.KICK_USER:
              if (_authRepo.isCurrentUser(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                await _roomDao.updateRoom(
                  uid: message.from,
                  deleted: true,
                );
              }
              break;
            case MucSpecificPersistentEvent_Issue.JOINED_USER:
            case MucSpecificPersistentEvent_Issue.ADD_USER:
              if (_authRepo.isCurrentUser(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                await _roomDao.updateRoom(
                  uid: message.from,
                  deleted: false,
                );
              }
              unawaited(
                _sdr.saveMember(
                  Member(
                    memberUid:
                        message.persistEvent.mucSpecificPersistentEvent.issuer,
                    mucUid: roomUid,
                  ),
                ),
              );
              break;

            case MucSpecificPersistentEvent_Issue.LEAVE_USER:
              if (_authRepo.isCurrentUser(
                message.persistEvent.mucSpecificPersistentEvent.assignee,
              )) {
                await _roomDao.updateRoom(
                  uid: message.from,
                  deleted: true,
                );
              }
              await _sdr.deleteMember(
                Member(
                  memberUid:
                      message.persistEvent.mucSpecificPersistentEvent.issuer,
                  mucUid: roomUid,
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
            case MessageManipulationPersistentEvent_Action.OTHER_DELETED:
              await _onOtherMessageDeleted(
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
    }
    final msg = (await saveMessageInMessagesDB(
      message,
      roomUid,
      needToBackup: isLocalNetworkMessage,
    ))!;
    MessageUtils.createMessageByClientOfLocalMessages(
        [msg], message.id.toInt());

    final isHidden = msg.isHidden || (message.edited && message.isLocalMessage);
    if (msg.edited && message.isLocalMessage) {
      unawaited(_editServerLessMessage(roomUid, message));
    }

    if (isOnlineMessage) {
      if (!isHidden) {
        await _seenDao.addRoomSeen(roomUid.asString());
      }

      // Step 1 - Update Room Info

      // Check if Mentioned.
      await _roomDao.updateRoom(
        uid: roomUid,
        lastMessage: isHidden ? null : msg,
        lastMessageId: !(message.edited) ? msg.localNetworkMessageId : null,
        lastUpdateTime: msg.time,
        deleted: false,
      );

      ///todo  update last message on  edit

      // if (settings.inLocalNetwork.value) {
      //   final room = await _roomDao.getRoom(roomUid);
      //   if (room != null && room.lastMessage?.id! == message.id.toInt()) {
      //     await _roomDao.updateRoom(uid: roomUid, lastMessage: msg);
      //   }
      // }

      if (roomUid.category == Categories.GROUP) {
        if (await isMentioned(message)) {
          unawaited(_roomRepo.processMentionIds(roomUid, [msg.id!]));
        }
      }

      // Step 3 - Update Hidden Message Count
      if (msg.isHidden) {
        await _increaseHiddenMessageCount(roomUid.asString());
      }

      // Step 4 - Notify Message
      if (!isHidden && await shouldNotifyForThisMessage(message)) {
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

      // Step 7 - Update Seen if Call Log from Current User
      if (message.whichType() == Message_Type.callLog) {
        final callLog = message.callLog;
        if (callLog.from.asStringWithSession() ==
            _authRepo.currentUserUid.asStringWithSession()) {
          await _seenDao.updateMySeen(
            uid: roomUid.asString(),
            messageId: message.id.toInt(),
          );
        }
      }
    }

    return msg;
  }

  Future<bool> isMentioned(Message message) async {
    return message.text.text
        .replaceAll("\n", " ")
        .split(" ")
        .contains("@${(_accountRepo.getAccount())!.username}");
  }

  Future<void> _checkForReplyKeyBoard(Message message) async {
    final roomUid = getRoomUid(_authRepo, message);
    if (message.messageMarkup.replyKeyboardMarkup.rows.isNotEmpty) {
      await _roomRepo.updateReplyKeyboard(
        message.messageMarkup.replyKeyboardMarkup.writeToJson(),
        roomUid,
      );
    } else if (message.messageMarkup.removeReplyKeyboardMarkup) {
      await _roomRepo.updateReplyKeyboard(
        null,
        roomUid,
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

    final savedMsg = await _messageDao.getMessageById(roomUid, id);

    if (savedMsg != null) {
      if (savedMsg.type == MessageType.FILE && savedMsg.id != null) {
        await _metaRepo.addDeletedMetaIndexFromMessage(savedMsg);
      }
      final msg = savedMsg.copyDeleted();
      _cachingRepo.setMessage(roomUid, id, msg);
      await _messageDao.updateMessage(msg);

      if (isOnlineMessage) {
        final room = await _roomDao.getRoom(roomUid);
        if (room!.lastMessage != null && room.lastMessage!.id == id) {
          final lastNotHiddenMessage = await fetchLastNotHiddenMessage(
              roomUid, room.lastMessageId, room.firstMessageId,
              localNetworkMessageCount: room.localNetworkMessageCount);

          await _roomDao.updateRoom(
            uid: roomUid,
            lastMessage: lastNotHiddenMessage ?? savedMsg,
          );
        }
        _notificationServices.cancelNotificationById(id, roomUid.asString());
        if (room.uid.isGroup()) {
          if (room.mentionsId.contains(id)) {
            var updatedList = <int>[];
            updatedList = List.of(room.mentionsId)..remove(id);
            await _roomDao.updateRoom(
              mentionsId: updatedList,
              uid: room.uid,
            );
          }
        }
      }
      messageEventSubject.add(
        MessageEvent(
          roomUid,
          deleteActionTime,
          id,
          savedMsg.localNetworkMessageId!,
          MessageEventAction.DELETE,
        ),
      );
    }
  }

  Future<void> _onOtherMessageDeleted(
    Uid roomUid,
    Message message, {
    required bool isOnlineMessage,
  }) async {
    final id = message.persistEvent.messageManipulationPersistentEvent.messageId
        .toInt();

    final deleteActionTime = message.time.toInt();

    final savedMsg = await _messageDao.getMessageById(roomUid, id);

    if (savedMsg != null && !_authRepo.isCurrentUserSender(savedMsg)) {
      if (savedMsg.type == MessageType.FILE && savedMsg.id != null) {
        await _metaRepo.addDeletedMetaIndexFromMessage(savedMsg);
      }
      final msg = savedMsg.copyDeleted();
      _cachingRepo.setMessage(roomUid, id, msg);
      await _messageDao.updateMessage(msg);

      if (isOnlineMessage) {
        final room = await _roomDao.getRoom(roomUid);
        if (room!.lastMessage != null && room.lastMessage!.id == id) {
          final lastNotHiddenMessage = await fetchLastNotHiddenMessage(
            roomUid,
            room.lastMessageId - 1,
            room.firstMessageId,
            localNetworkMessageCount: room.localNetworkMessageCount,
          );

          await _roomDao.updateRoom(
            uid: roomUid,
            lastMessage: lastNotHiddenMessage ?? savedMsg,
          );
        }
      }
      messageEventSubject.add(
        MessageEvent(
          roomUid,
          deleteActionTime,
          id,
          savedMsg.localNetworkMessageId!,
          MessageEventAction.DELETE,
        ),
      );
    }
  }

  Future<void> _editServerLessMessage(Uid roomUid, Message message) async {
    final time = message.time.toInt();
    final msg = _messageExtractorServices.extractMessage(message);
    await _messageDao.updateMessage(msg);
    _cachingRepo.setMessage(roomUid, message.id.toInt(), msg);
    messageEventSubject.add(
      MessageEvent(
        roomUid,
        time,
        message.id.toInt(),
        message.id.toInt(),
        MessageEventAction.EDIT,
      ),
    );
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
    final savedMsg = await _messageDao.getMessageById(roomUid, id);

    // there is no message in db for editing, so if we fetch it eventually, it will be edited anyway
    if (savedMsg == null) {
      return;
    }

    final res = await _services.queryServiceClient.fetchMessages(
      FetchMessagesReq()
        ..roomUid = roomUid
        ..limit = 1
        ..pointer = Int64(id)
        ..type = FetchMessagesReq_Type.FORWARD_FETCH,
    );

    final msg = _messageExtractorServices.extractMessage(res.messages.first);
    await _messageDao.updateMessage(msg);
    _cachingRepo.setMessage(roomUid, savedMsg.localNetworkMessageId!, msg);
    if (_metaRepo.isMessageContainMeta(msg)) {
      await _metaRepo.updateMeta(msg);
    }

    if (isOnlineMessage) {
      final room = await _roomDao.getRoom(roomUid);
      if (room != null && room.lastMessage?.id == id) {
        await _roomDao.updateRoom(
          uid: room.uid,
          lastMessage: msg,
        );

        if (room.uid.isGroup()) {
          if (room.mentionsId.contains(id)) {
            if (!await isMentioned(message)) {
              var updatedList = <int>[];
              updatedList = List.of(room.mentionsId)..remove(id);
              await _roomDao.updateRoom(
                mentionsId: updatedList,
                uid: room.uid,
              );
            }
          }
        }
      }

      await _notificationServices.editNotificationById(
        id,
        roomUid.asString(),
        res.messages.first,
      );
    }

    messageEventSubject.add(
      MessageEvent(
        roomUid,
        time,
        id,
        savedMsg.localNetworkMessageId!,
        MessageEventAction.EDIT,
      ),
    );
  }

  Future<void> handleSeen(seen_pb.Seen seen) async {
    Uid? roomId;
    switch (seen.to.category) {
      case Categories.USER:
        _authRepo.isCurrentUser(seen.to)
            ? roomId = seen.from
            : roomId = seen.to;
        break;
      case Categories.STORE:
      case Categories.BROADCAST:
      case Categories.SYSTEM:
      case Categories.GROUP:
      case Categories.CHANNEL:
      case Categories.BOT:
        roomId = seen.to;
        break;
    }
    if (_authRepo.isCurrentUser(seen.from)) {
      final room = await _roomDao.getRoom(roomId!);
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

      if (room != null && room.uid.isGroup()) {
        if (room.mentionsId.isNotEmpty) {
          unawaited(
            _roomRepo.updateMentionIds(
              room.uid,
              room.mentionsId
                  .where((element) => element > seen.id.toInt())
                  .toList(),
            ),
          );
        }
      }
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

  Future<void> handleCallEvent(call_pb.CallEventV2 callEventV2) async {
    final callEvents = CallEvents.callEvent(
      callEventV2,
    );
    _callService
      ..addCallEvent(callEvents)
      ..shouldRemoveData = true;

     await GetIt.I.get<CoreServices>().initStreamConnection();
   }

  void handleActivity(Activity activity) {
    _roomRepo.updateActivity(activity);
    _updateLastActivityTime(
      _lastActivityDao,
      activity.from,
      clock.now().millisecondsSinceEpoch,
    );
  }

  Future<message_model.Message?> handleAckMessage(
    MessageDeliveryAck messageDeliveryAck, {
    bool isLocalNetworkMessage = false,
    int localNetworkMessageId = 0,
  }) async {
    final serverLessMessageService = GetIt.I.get<ServerLessMessageService>();
    if (messageDeliveryAck.id.toInt() == 0) {
      return null;
    }
    final packetId = messageDeliveryAck.packetId;

    final time = messageDeliveryAck.time.toInt();
    if (_isBroadcastMessage(packetId)) {
      await _saveAndCreateBroadcastMessage(messageDeliveryAck);
    } else if (messageDeliveryAck.packetId.contains(LOCAL_MESSAGE_KEY)) {
      final mes = await _messageDao.getMessageByPacketId(
        messageDeliveryAck.to,
        packetId.replaceFirst(LOCAL_MESSAGE_KEY, ""),
      );
      if (mes != null) {
        unawaited(
          _messageDao.insertMessage(
            mes.copyWith(
              needToBackup: false,
            ),
          ),
        );
      }
    } else {
      final pm = await _pendingMessageDao.getPendingMessage(packetId);
      if (pm != null) {
        serverLessMessageService.removePendingFromCache(
          pm.roomUid.asString(),
          packetId,
        );

        final msg = pm.msg.copyWith(
          id: messageDeliveryAck.id.toInt(),
          localNetworkMessageId: messageDeliveryAck.id.toInt(),
          time: time,
          isLocalMessage: isLocalNetworkMessage,
          needToBackup: isLocalNetworkMessage,
        );
        if (msg.type == MessageType.FILE) {
          final file = msg.json.toFile();
          await _checkForNewMedia(file, msg.roomUid);
        }
        try {
          await _pendingMessageDao.deletePendingMessage(packetId);
        } catch (e) {
          _logger.e(e);
        }
        if (pm.roomUid.isBroadcast()) {
          unawaited(_broadcastService.startBroadcast(msg));
        }
        await _saveMessageAndUpdateRoomAndSeen(
          msg,
          messageDeliveryAck,
        );
        if (isLocalNetworkMessage) {
          final room = await _roomDao.getRoom(msg.roomUid);
          if (room != null) {
            await _roomDao.updateRoom(
              uid: room.uid,
              localNetworkMessageCount: 1,
              lastLocalNetworkMessageId: localNetworkMessageId,
            );
          }

          unawaited(
            serverLessMessageService.sendPendingMessage(msg.roomUid.asString()),
          );
          return msg;
        }
      } else {
        await _analyticsService.sendLogEvent(
          "nullPendingMessageOnAck",
          parameters: {
            "packetId": messageDeliveryAck.packetId,
          },
        );
      }
    }
    return null;
  }

  bool _isBroadcastMessage(
    String packetId,
  ) =>
      packetId.contains(BROADCAST_KEY);

  Future<void> _saveAndCreateBroadcastMessage(
    MessageDeliveryAck messageDeliveryAck,
  ) async {
    final broadcastRoomUid = _broadcastService
        .getBroadcastPendingMessage(messageDeliveryAck.packetId);
    if (broadcastRoomUid != null) {
      try {
        await _broadcastService.deletePendingBroadcastMessage(
          messageDeliveryAck.packetId,
          broadcastRoomUid,
        );
      } catch (e) {
        _logger.e(e);
      }
      final broadcastMessageId = _broadcastService
          .getBroadcastIdFromPacketId(messageDeliveryAck.packetId);

      final broadcastMessage = await _messageDao.getMessageById(
        broadcastRoomUid,
        broadcastMessageId,
      );
      final msg = broadcastMessage?.copyWith(
        to: messageDeliveryAck.to,
        from: messageDeliveryAck.from,
        time: messageDeliveryAck.time.toInt(),
        packetId: messageDeliveryAck.packetId,
        id: messageDeliveryAck.id.toInt(),
        roomUid: messageDeliveryAck.to,
      );
      if (msg != null) {
        await _saveMessageAndUpdateRoomAndSeen(
          msg,
          messageDeliveryAck,
          shouldNotifyOutgoingMessage: false,
        );
      }
    }
  }

  Future<void> _saveMessageAndUpdateRoomAndSeen(
    message_model.Message msg,
    MessageDeliveryAck messageDeliveryAck, {
    bool shouldNotifyOutgoingMessage = true,
  }) async {
    await _messageDao.insertMessage(msg);
    await _roomDao.updateRoom(
      uid: msg.roomUid,
      lastMessage: msg.isHidden ? null : msg,
      lastMessageId: msg.localNetworkMessageId,
    );
    if (msg.isHidden) {
      return _increaseHiddenMessageCount(msg.roomUid.asString());
    }
    if (shouldNotifyOutgoingMessage) {
      _notificationServices
          .notifyOutgoingMessage(messageDeliveryAck.to.asString());
    }
    final seen = await _roomRepo.getMySeen(msg.roomUid.asString());
    if (messageDeliveryAck.id > seen.messageId) {
      _roomRepo
          .updateMySeen(
            uid: msg.roomUid,
            messageId: messageDeliveryAck.id.toInt(),
          )
          .ignore();
    }
  }

  Future<void> _checkForNewMedia(File file, Uid roomUid) async {
    if (file.isImageFileProto() || file.isVideoFileProto()) {
      await _roomDao.updateRoom(
        uid: roomUid,
        shouldUpdateMediaCount: true,
      );
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
      uid: roomPresenceTypeChanged.uid,
      deleted: type == PresenceType.BANNED ||
          type == PresenceType.DELETED ||
          type == PresenceType.KICKED ||
          type == PresenceType.LEFT ||
          type != PresenceType.ACTIVE,
    );
  }

  Future<bool> shouldNotifyForThisMessage(Message message) async {
    final authRepo = GetIt.I.get<AuthRepo>();
    final roomRepo = GetIt.I.get<RoomRepo>();

    final roomUid = getRoomUid(authRepo, message);

    if (message.shouldBeQuiet) {
      return false;
    } else if (settings.isAllNotificationDisabled.value ||
        await roomRepo.isRoomMuted(roomUid.asString())) {
      // If Notification is Off
      return false;
    } else if (authRepo.isCurrentUser(message.from)) {
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
        message.persistEvent.mucSpecificPersistentEvent.issuer,
      );
    }

    return true;
  }

  Future<message_model.Message?> saveMessageInMessagesDB(
    Message message,
    Uid roomUid, {
    bool needToBackup = false,
  }) async {
    try {
      var msg = _messageExtractorServices.extractMessage(
        message,
        needToBackup: needToBackup,
      );
      msg = _checkIsDeleted(message, msg);

      await _messageDao.insertMessage(msg);
      return msg;
    } catch (e) {
      _logger.e("error in saving message", error: e);
      return _messageExtractorServices.extractMessage(message);
    }
  }

  Future<message_model.Message?> fetchLastNotHiddenMessage(
    Uid roomUid,
    int lastMessageId,
    int firstMessageId, {
    bool appRunInForeground = false,
    int localNetworkMessageCount = 0,
  }) async {
    var pointer = lastMessageId + 1;
    message_model.Message? lastNotHiddenMessage;

    try {
      final msg = await _messageDao.getMessageById(roomUid, pointer);

      if (msg != null) {
        if (msg.id! <= firstMessageId ||
            (msg.isHidden && msg.id == firstMessageId + 1)) {
          // TODO(bitbeter): revert back after core changes - https://gitlab.iais.co/deliver/wiki/-/issues/1084
          // _roomDao
          //     .updateRoom(uid: roomUid, deleted: true)
          //
          //     .ignore();
          // await _roomRepo.deleteRoom(roomUid);
          //todo check  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        } else if (!msg.isHidden) {
          lastNotHiddenMessage = msg;
        }
      } else {
        lastNotHiddenMessage = await _getLastNotHiddenMessageFromServer(
          roomUid,
          lastMessageId - localNetworkMessageCount,
          firstMessageId,
          appRunInForeground: appRunInForeground,
        );
      }
    } catch (_) {
      return null;
    }

    if (lastNotHiddenMessage != null) {
      await _roomDao.updateRoom(
        uid: roomUid,
        firstMessageId: firstMessageId,
        lastMessageId: lastMessageId,
        synced: true,
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
    int firstMessageId, {
    bool appRunInForeground = false,
  }) async {
    var retry = 3;
    while (retry > 0) {
      try {
        final fetchMessagesRes =
            await _services.queryServiceClient.fetchMessages(
          FetchMessagesReq()
            ..roomUid = roomUid
            ..pointer = Int64(pointer)
            ..justNotHiddenMessages = true
            ..type = FetchMessagesReq_Type.BACKWARD_FETCH
            ..limit = 1,
        );

        final messages = await saveFetchMessages(
          fetchMessagesRes.messages,
          appRunInForeground: appRunInForeground,
        );

        for (final msg in messages) {
          if (msg.id! <= firstMessageId) {
            // TODO(bitbeter): revert back after core changes - https://gitlab.iais.co/deliver/wiki/-/issues/1084
            // await _roomDao.updateRoom(uid: roomUid, deleted: true);
            // await _roomRepo.deleteRoom(roomUid);
            //todo check ...............
            return null;
          } else if (!msg.isHidden) {
            return msg;
          }
        }
        return null;
      } on GrpcError catch (e) {
        _logger.e(e);
        if (e.code == StatusCode.notFound) {
          unawaited(
            _roomDao.updateRoom(
              uid: roomUid,
              deleted: true,
            ),
          );
          return null;
        }
        retry--;
      } catch (e) {
        retry--;
        _logger.e(e);
      }
    }
    return null;
  }

  Future<void> handleFetchMessagesActions(
    Uid roomId,
    List<Message> messages,
  ) async {
    for (final message in messages) {
      if (message.whichType() == Message_Type.persistEvent) {
        // if message persistEvent they are one hundred percent be a messageManipulationPersistentEvent
        switch (
            message.persistEvent.messageManipulationPersistentEvent.action) {
          case MessageManipulationPersistentEvent_Action.EDITED:
            await _onMessageEdited(
              roomId,
              message,
              isOnlineMessage: false,
            );
            break;
          case MessageManipulationPersistentEvent_Action.DELETED:
            await _onMessageDeleted(
              roomId,
              message,
              isOnlineMessage: false,
            );
            break;
          case MessageManipulationPersistentEvent_Action.OTHER_DELETED:
            var msg = await _messageDao.getMessageById(
                roomId,
                message
                    .persistEvent.messageManipulationPersistentEvent.messageId
                    .toInt());
            if (msg != null) {
              msg = msg.copyDeleted();
              unawaited(_messageDao.insertMessage(msg));
            }
            break;
        }
        break;
      }
    }
  }

  Future<List<message_model.Message>> saveFetchMessages(
    List<Message> messages, {
    bool appRunInForeground = false,
  }) async {
    final msgList = <message_model.Message>[];
    for (final message in messages) {
      if (messages.last.id - message.id < 100) {
        unawaited(_checkForReplyKeyBoard(message));
      }
      if (_isBroadcastMessage(message.packetId)) {
        unawaited(
          _broadcastService.deletePendingBroadcastMessage(
            message.packetId,
            message.generatedBy,
          ),
        );
      } else if (_authRepo.isCurrentUser(message.from)) {
        await _pendingMessageDao.deletePendingMessage(message.packetId);
      }
      var msg = _messageExtractorServices.extractMessage(message);
      msg = _checkIsDeleted(message, msg);
      msgList.add(msg);
    }
    unawaited(_save(messages));
    return msgList;
  }

  message_model.Message _checkIsDeleted(
      Message message, message_model.Message msg) {
    if (message.deletedUid.isNotEmpty) {
      if (message.deletedUid
          .map((e) => e.asString())
          .contains(_authRepo.currentUserUid.asString())) {
        msg = msg.copyDeleted();
      }
    }
    return msg;
  }

  Future<void> _save(
    List<Message> messages,
  ) async {
    for (final message in messages) {
      try {
        await handleIncomingMessage(
          message,
          isOnlineMessage: false,
        );
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  void _checkCallLogMessage(Message message) {
    final callLog = message.callLog;
    final callEvent = CallEventV2()
      ..from = callLog.from
      ..to = callLog.to
      ..id = callLog.id
      ..time = message.time;
    switch (callLog.whichType()) {
      case CallLog_Type.busy:
        callEvent.busy = callLog.busy;
        _callService.addCallEvent(CallEvents.callEvent(callEvent));
        break;
      case CallLog_Type.decline:
        callEvent.decline = callLog.decline;
        _callService.addCallEvent(CallEvents.callEvent(callEvent));
        break;
      case CallLog_Type.end:
        callEvent.end = callLog.end;
        _callService.addCallEvent(CallEvents.callEvent(callEvent));
        break;
      case CallLog_Type.notSet:
        break;
    }
  }
}
