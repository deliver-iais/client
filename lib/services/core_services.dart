// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:deliver/box/muc.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/message.dart' as message_pb;
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fixnum/fixnum.dart';

enum ConnectionStatus { Connected, Disconnected, Connecting }

const MIN_BACKOFF_TIME = 10;
const MAX_BACKOFF_TIME = 8;
const BACKOFF_TIME_INCREASE_RATIO = 2;

// TODO Change to StreamRepo, it is not a service, it is repo now!!!
class CoreServices {
  final _logger = GetIt.I.get<Logger>();
  final _grpcCoreService = GetIt.I.get<CoreServiceClient>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _uxService = GetIt.I.get<UxService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _lastActivityDao = GetIt.I.get<LastActivityDao>();
  final _mucDao = GetIt.I.get<MucDao>();
  final _queryServicesClient = GetIt.I.get<QueryServiceClient>();

  Timer? _connectionTimer;
  var _lastPongTime = 0;

  @visibleForTesting
  bool responseChecked = false;

  late StreamController<ClientPacket> _clientPacketStream;

  late ResponseStream<ServerPacket> _responseStream;
  @visibleForTesting
  int backoffTime = MIN_BACKOFF_TIME;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  final BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  //TODO test
  initStreamConnection() async {
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      return;
    }
    startStream();
    startCheckerTimer();
    _connectionStatus.distinct().listen((event) {
      connectionStatus.add(event);
    });
  }

  void closeConnection() {
    _connectionStatus.add(ConnectionStatus.Disconnected);
    _clientPacketStream.close();
    if (_connectionTimer != null) _connectionTimer!.cancel();
  }

  @visibleForTesting
  startCheckerTimer() async {
    sendPing();
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      return;
    }
    // if (_clientPacketStream.isClosed || _clientPacketStream.isPaused) {
    //   await startStream();
    // }
    responseChecked = false;
    _connectionTimer = Timer(Duration(seconds: backoffTime), () {
      if (!responseChecked) {
        if (backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO) {
          backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
        } else {
          backoffTime = MIN_BACKOFF_TIME;
        }
        // _clientPacketStream.close();

        _connectionStatus.add(ConnectionStatus.Disconnected);
      }

      // await _responseStream.cancel();
      //  startStream();
      startCheckerTimer();
    });
  }

  void gotResponse() {
    _connectionStatus.add(ConnectionStatus.Connected);
    backoffTime = MIN_BACKOFF_TIME;
    responseChecked = true;
  }

  @visibleForTesting
  startStream() async {
    try {
      _clientPacketStream = StreamController<ClientPacket>();
      _responseStream = kIsWeb
          ? _grpcCoreService
              .establishServerSideStream(EstablishServerSideStreamReq())
          : _grpcCoreService.establishStream(_clientPacketStream.stream);
      _responseStream.listen((serverPacket) async {
        _logger.d(serverPacket);

        gotResponse();
        switch (serverPacket.whichType()) {
          case ServerPacket_Type.message:
            _saveIncomingMessage(serverPacket.message);
            break;
          case ServerPacket_Type.messageDeliveryAck:
            _saveAckMessage(serverPacket.messageDeliveryAck);
            break;
          case ServerPacket_Type.error:
            break;
          case ServerPacket_Type.seen:
            _saveSeen(serverPacket.seen);
            break;
          case ServerPacket_Type.activity:
            _saveActivity(serverPacket.activity);
            break;
          case ServerPacket_Type.liveLocationStatusChanged:
            break;
          case ServerPacket_Type.pong:
            _lastPongTime = serverPacket.pong.serverTime.toInt();
            break;
          case ServerPacket_Type.notSet:
            // TODO: Handle this case.
            break;
          case ServerPacket_Type.roomPresenceTypeChanged:
            _saveRoomPresenceTypeChange(serverPacket.roomPresenceTypeChanged);
            break;
          case ServerPacket_Type.callOffer:
            // TODO: Handle this case.
            break;
          case ServerPacket_Type.callAnswer:
            // TODO: Handle this case.
            break;
        }
      });
    } catch (e) {
      startStream();
      _logger.e(e);
    }
  }

  sendMessage(MessageByClient message) async {
    try {
      ClientPacket clientPacket = ClientPacket()
        ..message = message
        ..id = DateTime.now().microsecondsSinceEpoch.toString();
      if (kIsWeb) {
        _grpcCoreService.sendClientPacket(clientPacket);
      } else {
        if (!_clientPacketStream.isClosed &&
            _connectionStatus.value == ConnectionStatus.Connected) {
          _clientPacketStream.add(clientPacket);
        } else {
          startStream();
        }
      }
      Timer(const Duration(seconds: MIN_BACKOFF_TIME * 2 ~/ 2),
          () => checkPendingStatus(message.packetId));
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> checkPendingStatus(String packetId) async {
    var pm = await _messageDao.getPendingMessage(packetId);
    if (pm != null) {
      await _messageDao.savePendingMessage(pm.copyWith(
        failed: true,
      ));
      if (_connectionStatus.value == ConnectionStatus.Connected) {
        connectionStatus.add(ConnectionStatus.Connected);
      }
    }
  }

  sendPing() {
    if (kIsWeb) {
      try {
        var ping = Ping()..lastPongTime = Int64(_lastPongTime);
        _grpcCoreService.sendClientPacket(ClientPacket()
          ..ping = ping
          ..id = DateTime.now().microsecondsSinceEpoch.toString());
        _grpcCoreService.sendClientPacket(ClientPacket()
          ..ping = ping
          ..id = DateTime.now().microsecondsSinceEpoch.toString());
      } catch (e) {
        _logger.e(e);
      }
    } else {
      if (!_clientPacketStream.isClosed) {
        var ping = Ping()..lastPongTime = Int64(_lastPongTime);
        _clientPacketStream.add(ClientPacket()
          ..ping = ping
          ..id = DateTime.now().microsecondsSinceEpoch.toString());
      } else {
        startStream();
      }
    }
  }

  sendSeen(seen_pb.SeenByClient seen) {
    ClientPacket clientPacket = ClientPacket()
      ..seen = seen
      ..id = seen.id.toString();
    if (kIsWeb) {
      _grpcCoreService.sendClientPacket(clientPacket);
    } else {
      if (!_clientPacketStream.isClosed) {
        _clientPacketStream.add(clientPacket);
      } else {
        startStream();
      }
    }
  }

  sendActivity(ActivityByClient activity, String id) {
    if (_authRepo.isCurrentUser(activity.to.toString())) {
      ClientPacket clientPacket = ClientPacket()
        ..activity = activity
        ..id = id;
      if (kIsWeb) {
        _grpcCoreService.sendClientPacket(clientPacket);
      } else if (!_clientPacketStream.isClosed &&
          !_authRepo.isCurrentUser(activity.to.asString())) {
        _clientPacketStream.add(clientPacket);
      } else {
        startStream();
      }
    }
  }

  _saveSeen(seen_pb.Seen seen) {
    Uid? roomId;
    switch (seen.to.category) {
      case Categories.USER:
        seen.to.asString() == _authRepo.currentUserUid.asString()
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
    } else {
      _seenDao.saveOthersSeen(
        Seen(uid: roomId!.asString(), messageId: seen.id.toInt()),
      );
      updateLastActivityTime(
          _lastActivityDao, seen.from, DateTime.now().millisecondsSinceEpoch);
    }
  }

  _saveActivity(Activity activity) {
    _roomRepo.updateActivity(activity);
    updateLastActivityTime(
        _lastActivityDao, activity.from, DateTime.now().millisecondsSinceEpoch);
  }

  _saveAckMessage(MessageDeliveryAck messageDeliveryAck) async {
    if (messageDeliveryAck.id.toInt() == 0) {
      return;
    }
    var packetId = messageDeliveryAck.packetId;
    var id = messageDeliveryAck.id.toInt();
    var time = messageDeliveryAck.time.toInt();

    var pm = await _messageDao.getPendingMessage(packetId);
    if (pm != null) {
      var msg = pm.msg.copyWith(id: id, time: time);
      _messageDao.deletePendingMessage(packetId);
      _messageDao.saveMessage(msg);
      _roomDao.updateRoom(
          Room(uid: msg.roomUid, lastMessage: msg, lastMessageId: msg.id));

      if (_routingServices.isInRoom(messageDeliveryAck.to.asString())) {
        _notificationServices.playSoundOut();
      }
    }
  }

  _saveIncomingMessage(Message message) async {
    Uid roomUid = getRoomUid(_authRepo, message);
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
                Muc? muc = await _mucDao.get(roomUid.asString());
                var pinMessages = muc!.pinMessagesIdList;
                pinMessages!.add(message
                    .persistEvent.mucSpecificPersistentEvent.messageId
                    .toInt());
                _mucDao.update(muc.copyWith(
                    uid: muc.uid,
                    pinMessagesIdList: pinMessages,
                    showPinMessage: true));
                break;
              }

            case MucSpecificPersistentEvent_Issue.KICK_USER:
              if (message.persistEvent.mucSpecificPersistentEvent.assignee
                  .isSameEntity(_authRepo.currentUserUid.asString())) {
                _roomDao.updateRoom(
                    Room(uid: message.from.asString(), deleted: true));
                return;
              }
              break;
            case MucSpecificPersistentEvent_Issue.JOINED_USER:
            case MucSpecificPersistentEvent_Issue.ADD_USER:
              if (message.persistEvent.mucSpecificPersistentEvent.assignee
                  .isSameEntity(_authRepo.currentUserUid.asString())) {
                _roomDao.updateRoom(
                    Room(uid: message.from.asString(), deleted: false));
              }
              break;

            case MucSpecificPersistentEvent_Issue.LEAVE_USER:
              if (message.persistEvent.mucSpecificPersistentEvent.assignee
                  .isSameEntity(_authRepo.currentUserUid.asString())) {
                _roomDao.updateRoom(
                    Room(uid: message.from.asString(), deleted: true));
                return;
              }
              _mucDao.deleteMember(Member(
                memberUid: message
                    .persistEvent.mucSpecificPersistentEvent.issuer
                    .asString(),
                mucUid: roomUid.asString(),
              ));
              break;
            case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
              _avatarRepo.fetchAvatar(message.from, true);
              break;
            case MucSpecificPersistentEvent_Issue.MUC_CREATED:
              // TODO: Handle this case.
              break;
            case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
              // TODO: Handle this case.
              break;
          }
          break;
        case PersistentEvent_Type.messageManipulationPersistentEvent:
          switch (
              message.persistEvent.messageManipulationPersistentEvent.action) {
            case MessageManipulationPersistentEvent_Action.EDITED:
              await getEditedMsg(
                  roomUid,
                  message
                      .persistEvent.messageManipulationPersistentEvent.messageId
                      .toInt());
              return;
            case MessageManipulationPersistentEvent_Action.DELETED:
              var mes = await _messageDao.getMessage(
                  roomUid.asString(),
                  message
                      .persistEvent.messageManipulationPersistentEvent.messageId
                      .toInt());
              _messageDao.saveMessage(mes!..json = "{}");
              _roomDao.updateRoom(
                  Room(uid: roomUid.asString(), lastUpdatedMessageId: mes.id));
              break;
          }
          break;
        case PersistentEvent_Type.adminSpecificPersistentEvent:
          // TODO: Handle this case.
          break;
        case PersistentEvent_Type.notSet:
          // TODO: Handle this case.
          break;
      }
    }
    saveMessage(message, roomUid);

    if (showNotifyForThisMessage(message, _authRepo) &&
        !_uxService.isAllNotificationDisabled &&
        (!await _roomRepo.isRoomMuted(roomUid.asString()))) {
      showNotification(roomUid, message);
    }
    if (message.from.category == Categories.USER) {
      updateLastActivityTime(
          _lastActivityDao, message.from, message.time.toInt());
    }
  }

  getEditedMsg(Uid roomUid, int id) async {
    var res = await _queryServicesClient.fetchMessages(FetchMessagesReq()
      ..roomUid = roomUid
      ..limit = 1
      ..pointer = Int64(id)
      ..type = FetchMessagesReq_Type.FORWARD_FETCH);
    var msg = await saveMessageInMessagesDB(
        _authRepo, _messageDao, res.messages.first);
    var room = await _roomDao.getRoom(roomUid.asString());
    if (room!.lastMessageId != id) {
      _roomDao.updateRoom(
          room.copyWith(lastUpdatedMessageId: res.messages.first.id.toInt()));
    } else {
      _roomDao.updateRoom(room.copyWith(
        lastMessage: msg,
        lastUpdatedMessageId: res.messages.first.id.toInt(),
      ));
    }
  }

  Future showNotification(Uid roomUid, Message message) async {
    if (_routingServices.isInRoom(roomUid.asString()) && !isDesktop()) {
      _notificationServices.playSoundIn();
    } else {
      _notificationServices.showNotification(message);
    }
  }

  void updateLastActivityTime(
      LastActivityDao lastActivityDao, Uid userUid, int time) {
    lastActivityDao.save(LastActivity(
        uid: userUid.asString(),
        time: time,
        lastUpdate: DateTime.now().millisecondsSinceEpoch));
  }

  Future<Uid> saveMessage(Message message, Uid roomUid) async {
    var msg = await saveMessageInMessagesDB(_authRepo, _messageDao, message);

    bool isMention = false;
    if (roomUid.category == Categories.GROUP) {
      // TODO, bug: username1 = hasan , username2 = hasan2 => isMention will be triggered if @hasan2 be into the text.
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
          lastUpdateTime: msg.time),
    );

    return roomUid;
  }

  void _saveRoomPresenceTypeChange(
      RoomPresenceTypeChanged roomPresenceTypeChanged) {
    PresenceType type = roomPresenceTypeChanged.presenceType;
    _roomDao.updateRoom(Room(
        uid: roomPresenceTypeChanged.uid.asString(),
        deleted: type == PresenceType.BANNED ||
            type == PresenceType.DELETED ||
            type == PresenceType.KICKED ||
            type == PresenceType.LEFT ||
            type != PresenceType.ACTIVE));
  }
}

bool showNotifyForThisMessage(Message message, AuthRepo authRepo) {
  bool showNotify = true;
  showNotify = !authRepo.isCurrentUser(message.from.asString());
  if (message.whichType() == Message_Type.persistEvent) {
    // ignore: missing_enum_constant_in_switch
    switch (message.persistEvent.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        showNotify = !authRepo.isCurrentUser(
            message.persistEvent.mucSpecificPersistentEvent.issuer.asString());
        return showNotify;
      case PersistentEvent_Type.messageManipulationPersistentEvent:
        showNotify = false;
        return showNotify;
    }
  }
  return showNotify;
}

// TODO, refactor this!!!, we don't need this be functional
Future<message_pb.Message?> saveMessageInMessagesDB(
    AuthRepo authRepo, MessageDao messageDao, Message message) async {
  try {
    final msg = extractMessage(authRepo, message);
    await messageDao.saveMessage(msg);
    return msg;
  } catch (e) {
    return null;
  }
}
