import 'dart:async';
import 'dart:convert';

import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/db/database.dart' as Database;
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:moor/moor.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectionStatus { Connected, Disconnected, Connecting }

const MIN_BACKOFF_TIME = 4;
const MAX_BACKOFF_TIME = 32;
const BACKOFF_TIME_INCREASE_RATIO = 2;

class CoreServices {
  StreamController<ClientPacket> _clientPacket;

  ResponseStream<ServerPacket> _responseStream;
  @visibleForTesting
  int backoffTime = MIN_BACKOFF_TIME;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  @visibleForTesting
  bool responseChecked = false;

  var _grpcCoreService = GetIt.I.get<CoreServiceClient>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _messageDao = GetIt.I.get<MessageDao>();
  var _seenDao = GetIt.I.get<SeenDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  var _routingServices = GetIt.I.get<RoutingService>();

  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _notificationServices = GetIt.I.get<NotificationServices>();
  var _userInfoDAo = GetIt.I.get<UserInfoDao>();

  Timer _connectionTimer;

//TODO test
  initStreamConnection() async {
    if (_connectionTimer != null && _connectionTimer.isActive) {
      return;
    }
    startStream();
    if (_connectionTimer != null && _connectionTimer.isActive) {
      return;
    }
    startCheckerTimer();
    _connectionStatus.distinct().listen((event) {
      connectionStatus.add(event);
    });
  }

  @visibleForTesting
  startCheckerTimer() async {
    if (_clientPacket.isClosed || _clientPacket.isPaused) {
      await startStream();
    }
    sendPingMessage();
    responseChecked = false;
    _connectionTimer = Timer(new Duration(seconds: backoffTime), () async {
      if (!responseChecked) {
        if (backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO) {
          backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
        } else {
          backoffTime = MIN_BACKOFF_TIME;
        }
        _clientPacket.close();
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
      _clientPacket = StreamController<ClientPacket>();
      _responseStream = _grpcCoreService.establishStream(
          _clientPacket.stream.asBroadcastStream(
        onCancel: (c) async {
          await _clientPacket.close();
          _connectionStatus.add(ConnectionStatus.Disconnected);
        },
      ), options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()},
          ));
      sendPingMessage();
      _responseStream.listen((serverPacket) async {
        print(serverPacket.toString());
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
            _saveSeenMessage(serverPacket.seen);
            break;
          case ServerPacket_Type.activity:
            _saveActivityMessage(serverPacket.activity);
            break;
          case ServerPacket_Type.pollStatusChanged:
            break;
          case ServerPacket_Type.liveLocationStatusChanged:
            break;
          case ServerPacket_Type.pong:
            break;
          case ServerPacket_Type.notSet:
            // TODO: Handle this case.
            break;
        }
      });
    } catch (e) {
      print("correservice error");
    }
  }

  sendMessage(MessageByClient message) {
    if (_clientPacket != null && !_clientPacket.isClosed) {
      _clientPacket.add(ClientPacket()
        ..message = message
        ..id = message.packetId);
    } else {
      startStream();
    }
  }

  sendPingMessage() {
    if (_clientPacket != null && !_clientPacket.isClosed) {
      _clientPacket.add(ClientPacket()
        ..ping = Ping()
        ..id = DateTime.now().microsecondsSinceEpoch.toString());
    } else {
      startStream();
    }
  }

  sendSeenMessage(SeenByClient seen) {
    if (!_clientPacket.isClosed) {
      _clientPacket.add(ClientPacket()
        ..seen = seen
        ..id = seen.id.toString());
    } else {
      startStream();
    }
  }

  sendActivityMessage(ActivityByClient activity, String id) {
    if (!_clientPacket.isClosed)
      _clientPacket.add(ClientPacket()
        ..activity = activity
        ..id = id);
    else {
      startStream();
    }
  }

  _saveSeenMessage(Seen seen) {
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
    _seenDao.insertSeen(Database.SeensCompanion.insert(
        messageId: seen.id.toInt(),
        user: seen.from.asString(),
        roomId: roomId.asString()));
    updateLastActivityTime(_userInfoDAo, seen.from, DateTime.now());
  }

  _saveActivityMessage(Activity activity) {
    _roomRepo.updateActivity(activity);
    updateLastActivityTime(_userInfoDAo, activity.from, DateTime.now());
  }

  _saveAckMessage(MessageDeliveryAck messageDeliveryAck) async {
    if (messageDeliveryAck.id.toInt() == 0) {
      return;
    }
    var roomId = messageDeliveryAck.to.asString();
    var packetId = messageDeliveryAck.packetId;
    var id = messageDeliveryAck.id.toInt();
    var time = messageDeliveryAck.time.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    _messageDao.updateMessageId(roomId, packetId, id, time);
    _roomDao.insertRoomCompanion(Database.RoomsCompanion.insert(
        roomId: roomId, lastMessageId: Value(id)));
    _pendingMessageDao.deletePendingMessage(packetId);
    if (_routingServices.isInRoom(messageDeliveryAck.to.asString())) {
      _notificationServices.playSoundNotification();
    }
  }

  _saveIncomingMessage(Message message) async {
    Uid roomUid = getRoomId(_accountRepo, message);
    Database.Room room = await _roomDao.getByRoomIdFuture(roomUid.asString());
    if (room != null && room.isBlock) {
      return;
    }
    saveMessage(_accountRepo, _messageDao, _roomDao, message, roomUid);

    if ((await _accountRepo.notification).contains("true") &&
        (room != null && !room.mute)) {
      showNotification(roomUid, message);
    }
    if (message.from.category == Categories.USER)
      updateLastActivityTime(_userInfoDAo, message.from,
          DateTime.fromMillisecondsSinceEpoch(message.time.toInt()));
  }

  Future showNotification(Uid roomUid, Message message) async {
    String roomName = await _roomRepo.getRoomDisplayName(roomUid);
    if (_routingServices.isInRoom(roomUid.asString())) {
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
    if (isMention) {
      roomDao.insertRoomCompanion(
        Database.RoomsCompanion.insert(
            roomId: roomUid.asString(),
            lastMessageId: Value(message.id.toInt()),
            mentioned: Value(isMention),
            lastMessageDbId: Value(msg.dbId)),
      );
    } else {
      roomDao.insertRoomCompanion(Database.RoomsCompanion.insert(
          roomId: roomUid.asString(),
          lastMessageId: Value(message.id.toInt()),
          lastMessageDbId: Value(msg.dbId)));
    }

    return roomUid;
  }
}

void updateLastActivityTime(
    UserInfoDao userInfoDao, Uid userUid, DateTime lastActivityTime) {
  userInfoDao.upsertUserInfo(Database.UserInfo(
      uid: userUid.asString(),
      lastActivity: lastActivityTime,
      lastTimeActivityUpdated: DateTime.now()));
}

Future<bool> checkMention(String text, AccountRepo accountRepo) async {
  Account account = await accountRepo.getAccount();
  return text.contains(account.userName);
}

saveMessageInMessagesDB(
    AccountRepo accountRepo, MessageDao messageDao, Message message) async {
  // ignore: missing_required_param
  Database.Message msg = Database.Message(
      id: message.id.toInt(),
      roomId: message.whichType() == Message_Type.persistEvent
          ? message.from.asString()
          : message.from.node.contains(accountRepo.currentUserUid.node)
              ? message.to.asString()
              : message.to.category == Categories.USER
                  ? message.from.asString()
                  : message.to.asString(),
      packetId: message.packetId,
      time: DateTime.fromMillisecondsSinceEpoch(message.time.toInt()),
      to: message.to.asString(),
      from: message.from.asString(),
      replyToId: message.replyToId.toInt(),
      forwardedFrom: message.forwardFrom.asString(),
      json: messageToJson(message),
      edited: message.edited,
      encrypted: message.encrypted,
      type: getMessageType(message.whichType()));

  int dbId = await messageDao.insertMessage(msg);

  return msg.copyWith(dbId: dbId);
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
    case MessageType.NOT_SET:
      // TODO: Handle this case.
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
    default:
      return MessageType.NOT_SET;
  }
}

