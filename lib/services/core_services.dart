import 'dart:async';
import 'dart:convert';

import 'package:deliver_flutter/box/dao/last_activity_dao.dart';
import 'package:deliver_flutter/box/dao/room_dao.dart';
import 'package:deliver_flutter/box/message.dart' as DB;
import 'package:deliver_flutter/box/dao/message_dao.dart';
import 'package:deliver_flutter/box/dao/muc_dao.dart';
import 'package:deliver_flutter/box/dao/seen_dao.dart';
import 'package:deliver_flutter/box/last_activity.dart';
import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart'
    as ProtocolSeen;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:flutter/cupertino.dart';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fixnum/fixnum.dart';

enum ConnectionStatus { Connected, Disconnected, Connecting }

const MIN_BACKOFF_TIME = 2;
const MAX_BACKOFF_TIME = 8;
const BACKOFF_TIME_INCREASE_RATIO = 2;

// TODO Change to StreamRepo, it is not a service, it is repo now!!!
class CoreServices {
  final _logger = Logger();
  final _grpcCoreService = GetIt.I.get<CoreServiceClient>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _lastActivityDao = GetIt.I.get<LastActivityDao>();
  final _mucDao = GetIt.I.get<MucDao>();

  Timer _connectionTimer;
  var _lastPongTime = 0;

  @visibleForTesting
  bool responseChecked = false;

  StreamController<ClientPacket> _clientPacketStream;

  ResponseStream<ServerPacket> _responseStream;
  @visibleForTesting
  int backoffTime = MIN_BACKOFF_TIME;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  //TODO test
  initStreamConnection() async {
    if (_connectionTimer != null && _connectionTimer.isActive) {
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
    if (_connectionTimer != null) _connectionTimer.cancel();
  }

  @visibleForTesting
  startCheckerTimer() async {
    if (_connectionTimer != null && _connectionTimer.isActive) {
      return;
    }
    if (_clientPacketStream.isClosed || _clientPacketStream.isPaused) {
      await startStream();
    }
    sendPing();
    responseChecked = false;
    _connectionTimer = Timer(new Duration(seconds: backoffTime), () {
      if (!responseChecked) {
        if (backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO) {
          backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
        } else {
          backoffTime = MIN_BACKOFF_TIME;
        }
        _clientPacketStream.close();
        _connectionStatus.add(ConnectionStatus.Disconnected);
      }
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
      _responseStream =
          _grpcCoreService.establishStream(_clientPacketStream.stream,
              options: CallOptions(
                metadata: {'access_token': await _accountRepo.getAccessToken()},
              ));
      _responseStream.listen((serverPacket) async {
        _logger.d(serverPacket.toString());
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
        }
      });
    } catch (e) {
      startStream();
      _logger.e(e);
    }
  }

  sendMessage(MessageByClient message) async {
    if (_clientPacketStream != null &&
        !_clientPacketStream.isClosed &&
        _connectionStatus.value == ConnectionStatus.Connected) {
      _clientPacketStream.add(ClientPacket()
        ..message = message
        ..id = message.packetId);
      new Timer(Duration(seconds: MIN_BACKOFF_TIME ~/ 2),
          () => checkPendingStatus(message.packetId));
    } else {
      startStream();
    }
  }

  Future<void> checkPendingStatus(String packetId) async {
    var pm = await _messageDao.getPendingMessage(packetId);
    if (pm != null) {
      await _messageDao.savePendingMessage(pm.copyWith(failed: true));
      if (_connectionStatus.value == ConnectionStatus.Connected)
        connectionStatus.add(ConnectionStatus.Connected);
    }
  }

  sendPing() {
    if (_clientPacketStream != null && !_clientPacketStream.isClosed) {
      var ping = Ping()..lastPongTime = Int64(_lastPongTime);
      _clientPacketStream.add(ClientPacket()
        ..ping = ping
        ..id = DateTime.now().microsecondsSinceEpoch.toString());
    } else {
      startStream();
    }
  }

  sendSeen(ProtocolSeen.SeenByClient seen) {
    if (!_clientPacketStream.isClosed) {
      _clientPacketStream.add(ClientPacket()
        ..seen = seen
        ..id = seen.id.toString());
    } else {
      startStream();
    }
  }

  sendActivity(ActivityByClient activity, String id) {
    if (!_clientPacketStream.isClosed &&
        !_accountRepo.isCurrentUser(activity.to.asString()))
      _clientPacketStream.add(ClientPacket()
        ..activity = activity
        ..id = id);
    else {
      startStream();
    }
  }

  _saveSeen(ProtocolSeen.Seen seen) {
    Uid roomId;
    switch (seen.to.category) {
      case Categories.USER:
        seen.to.asString() == _accountRepo.currentUserUid.asString()
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
    if (_accountRepo.isCurrentUser(seen.from.asString())) {
      _seenDao.saveMySeen(
        Seen(uid: roomId.asString(), messageId: seen.id.toInt()),
      );
    } else {
      _seenDao.saveOthersSeen(
        Seen(uid: roomId.asString(), messageId: seen.id.toInt()),
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
    var time = messageDeliveryAck.time.toInt() ??
        DateTime.now().millisecondsSinceEpoch;

    var pm = await _messageDao.getPendingMessage(packetId);

    var msg = pm.msg.copyWith(id: id, time: time);

    _messageDao.deletePendingMessage(packetId);
    _messageDao.saveMessage(msg);
    _roomDao.updateRoom(Room(uid: msg.roomUid, lastMessage: msg));

    if (_routingServices.isInRoom(messageDeliveryAck.to.asString())) {
      _notificationServices.playSoundNotification();
    }
  }

  _saveIncomingMessage(Message message) async {
    Uid roomUid = getRoomId(_accountRepo, message);
    if (await _roomRepo.isRoomBlocked(roomUid.asString())) {
      return;
    }
    saveMessage(_accountRepo, _messageDao, _roomDao, message, roomUid);
    if (message.whichType() == Message_Type.persistEvent) {
      switch (message.persistEvent.whichType()) {
        case PersistentEvent_Type.mucSpecificPersistentEvent:
          switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
            case MucSpecificPersistentEvent_Issue.DELETED:
              _roomDao.updateRoom(
                  Room(uid: message.from.asString(), deleted: true));
              return;
              break;
            case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
              {
                var muc = await _mucDao.get(roomUid.asString());
                var pinMessages = muc.pinMessagesIdList;
                pinMessages.add(message
                    .persistEvent.mucSpecificPersistentEvent.messageId
                    .toInt());
                _mucDao.update(muc.copyWith(pinMessagesIdList: pinMessages));
                break;
              }

            case MucSpecificPersistentEvent_Issue.KICK_USER:
              if (message.persistEvent.mucSpecificPersistentEvent.assignee
                  .isSameEntity(_accountRepo.currentUserUid.asString())) {
                _roomDao.updateRoom(
                    Room(uid: message.from.asString(), deleted: true));
                return;
              }
              break;
            case MucSpecificPersistentEvent_Issue.JOINED_USER:
            case MucSpecificPersistentEvent_Issue.ADD_USER:
              if (message.persistEvent.mucSpecificPersistentEvent.assignee
                  .isSameEntity(_accountRepo.currentUserUid.asString())) {
                _roomDao.updateRoom(
                    Room(uid: message.from.asString(), deleted: false));
              }
              break;

            case MucSpecificPersistentEvent_Issue.LEAVE_USER:
              {
                _mucDao.deleteMember(Member(
                  memberUid: message
                      .persistEvent.mucSpecificPersistentEvent.issuer
                      .asString(),
                  mucUid: roomUid.asString(),
                ));
              }
          }
          break;
        case PersistentEvent_Type.messageManipulationPersistentEvent:
          // TODO: Handle this case.
          break;
        case PersistentEvent_Type.adminSpecificPersistentEvent:
          // TODO: Handle this case.
          break;
        case PersistentEvent_Type.notSet:
          // TODO: Handle this case.
          break;
      }
    }

    if (!_accountRepo.isCurrentUser(message.from.asString()) &&
        ((await _accountRepo.notification) == null ||
            (await _accountRepo.notification).contains("true") &&
                ( ! await _roomRepo.isRoomMuted(roomUid.asString())))) {
      showNotification(roomUid, message);
    }
    if (message.from.category == Categories.USER)
      updateLastActivityTime(
          _lastActivityDao, message.from, message.time.toInt());
  }

  Future showNotification(Uid roomUid, Message message) async {
    String roomName = await _roomRepo.getName(roomUid);
    if (_routingServices.isInRoom(roomUid.asString()) && !isDesktop()) {
      _notificationServices.playSoundNotification();
    } else {
      _notificationServices.showNotification(
          message, roomUid.asString(), roomName);
    }
  }

  static Future<Uid> saveMessage(AccountRepo accountRepo, MessageDao messageDao,
      RoomDao roomDao, Message message, Uid roomUid) async {
    var msg = await saveMessageInMessagesDB(accountRepo, messageDao, message);

    bool isMention = false;
    if (roomUid.category == Categories.GROUP) {
      if (message.text.text.contains("@")) {
        isMention = await checkMention(message.text.text, accountRepo);
      }
    }
    roomDao.updateRoom(
      Room(uid: roomUid.asString(), lastMessage: msg, mentioned: isMention),
    );

    return roomUid;
  }
}

void updateLastActivityTime(
    LastActivityDao lastActivityDao, Uid userUid, int time) {
  lastActivityDao.save(LastActivity(
      uid: userUid.asString(),
      time: time,
      lastUpdate: DateTime.now().millisecondsSinceEpoch));
}

Future<bool> checkMention(String text, AccountRepo accountRepo) async {
  Account account = await accountRepo.getAccount();
  return text.contains(account.userName);
}

Future<DB.Message> saveMessageInMessagesDB(
    AccountRepo accountRepo, MessageDao messageDao, Message message) async {
  var msg = extractMessage(accountRepo, message);
  await messageDao.saveMessage(msg);
  return msg;
}

DB.Message extractMessage(AccountRepo accountRepo, Message message) {
  var json = "";

  try {
    json = messageToJson(message);
  } catch (ignore) {}

  return DB.Message(
      id: message.id.toInt(),
      roomUid: message.whichType() == Message_Type.persistEvent
          ? message.from.asString()
          : message.from.node.contains(accountRepo.currentUserUid.node)
              ? message.to.asString()
              : message.to.category == Categories.USER
                  ? message.from.asString()
                  : message.to.asString(),
      packetId: message.packetId,
      time: message.time.toInt(),
      to: message.to.asString(),
      from: message.from.asString(),
      replyToId: message.replyToId.toInt(),
      forwardedFrom: message.forwardFrom.asString(),
      json: json,
      edited: message.edited,
      encrypted: message.encrypted,
      type: getMessageType(message.whichType()));
}

Uid getRoomId(AccountRepo accountRepo, Message message) {
  bool isCurrentUser =
      message.from.node.contains(accountRepo.currentUserUid.node);
  var roomUid = isCurrentUser
      ? message.to
      : (message.to.category == Categories.USER ? message.from : message.to);
  return roomUid;
}

String messageToJson(Message message) {
  var type = getMessageType(message.whichType());
  var jsonString = Object();
  switch (type) {
    case MessageType.TEXT:
      return message.text.writeToJson();
      break;
    case MessageType.FILE:
      return message.file.writeToJson();
      break;
    case MessageType.STICKER:
      return message.sticker.writeToJson();
      break;
    case MessageType.LOCATION:
      return message.location.writeToJson();
      break;
    case MessageType.LIVE_LOCATION:
      return message.liveLocation.writeToJson();
      break;
    case MessageType.POLL:
      return message.poll.writeToJson();
      break;
    case MessageType.FORM:
      return message.form.writeToJson();
      break;
    case MessageType.PERSISTENT_EVENT:
      return message.persistEvent.writeToJson();
      break;
    case MessageType.BUTTONS:
      return message.buttons.writeToJson();
      break;
    case MessageType.SHARE_UID:
      return message.shareUid.writeToJson();
      break;
    case MessageType.FORM_RESULT:
      return message.formResult.writeToJson();
      break;
    case MessageType.SHARE_PRIVATE_DATA_REQUEST:
      return message.sharePrivateDataRequest.writeToJson();
      break;
    case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
      return message.sharePrivateDataAcceptance.writeToJson();

    case MessageType.NOT_SET:
      return "";
      break;
  }
  return jsonEncode(jsonString);
}

MessageType getMessageType(Message_Type messageType) {
  switch (messageType) {
    case Message_Type.text:
      return MessageType.TEXT;
    case Message_Type.file:
      return MessageType.FILE;
    case Message_Type.sticker:
      return MessageType.STICKER;
    case Message_Type.location:
      return MessageType.LOCATION;
    case Message_Type.liveLocation:
      return MessageType.LIVE_LOCATION;
    case Message_Type.poll:
      return MessageType.POLL;
    case Message_Type.form:
      return MessageType.FORM;
    case Message_Type.persistEvent:
      return MessageType.PERSISTENT_EVENT;
    case Message_Type.formResult:
      return MessageType.FORM_RESULT;
    case Message_Type.buttons:
      return MessageType.BUTTONS;
    case Message_Type.shareUid:
      return MessageType.SHARE_UID;
    case Message_Type.sharePrivateDataRequest:
      return MessageType.SHARE_PRIVATE_DATA_REQUEST;
    case Message_Type.sharePrivateDataAcceptance:
      return MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE;
    default:
      return MessageType.NOT_SET;
  }
}
