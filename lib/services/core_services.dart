import 'dart:async';
import 'dart:convert';

import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
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
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:moor/moor.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectionStatus { Connected, Disconnected }

const MIN_BACKOFF_TIME = 4;
const MAX_BACKOFF_TIME = 32;
const BACKOFF_TIME_INCREASE_RATIO = 2;

class CoreServices {
  StreamController<ClientPacket> _clientPacket =
      StreamController<ClientPacket>();
  ResponseStream<ServerPacket> _responseStream;
  @visibleForTesting
  int backoffTime = MIN_BACKOFF_TIME;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);

  BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);

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

//TODO test
  initStreamConnection() async {
    await startStream();
    await startCheckerTimer();
    _connectionStatus.distinct().listen((event) {
      connectionStatus.add(event);
    });
  }

  @visibleForTesting
  startCheckerTimer() {
    sendPingMessage();
    responseChecked = false;
    Timer(new Duration(seconds: backoffTime), () {
      if (!responseChecked) {
        if (backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO) {
          backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
        } else {
          backoffTime = MIN_BACKOFF_TIME;
        }
        _connectionStatus.add(ConnectionStatus.Disconnected);
        startStream();
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
          _clientPacket.stream.asBroadcastStream(onListen: (c) async {
            gotResponse();
          }, onCancel: (c) {
            _clientPacket.close();
            startStream();
          }),
          options: CallOptions(
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
          case ServerPacket_Type.message:
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
    _clientPacket.add(ClientPacket()
      ..message = message
      ..id = message.packetId);
  }

  sendPingMessage() {
    _clientPacket.add(ClientPacket()
      ..ping = Ping()
      ..id = DateTime.now().microsecondsSinceEpoch.toString());
  }

  sendSeenMessage(SeenByClient seen) {
    _clientPacket.add(ClientPacket()
      ..seen = seen
      ..id = seen.id.toString());
  }

  sendActivityMessage(ActivityByClient activity) {
    _clientPacket.add(ClientPacket()
      ..activity = activity
      ..id = DateTime.now().microsecondsSinceEpoch.toString());
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
  }

  _saveActivityMessage(Activity activity) {
    //todo
  }

  void savePongMessage(Pong pong) {}

  _saveAckMessage(MessageDeliveryAck messageDeliveryAck) async {
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
    Uid roomUid =
        await saveMessage(_accountRepo, _messageDao, _roomDao, message);
    await showNotification(roomUid, message);
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
      RoomDao roomDao, Message message) async {
    var msg = await saveMessageInMessagesDB(accountRepo, messageDao, message);

    Uid roomUid = getRoomId(accountRepo, message);
    bool isMention = false;
    if (roomUid.category == Categories.GROUP) {
      if (message.text.text.contains("@")) {
        isMention = await checkMention(message.text.text, accountRepo);
      }
    }
    roomDao.insertRoomCompanion(
      Database.RoomsCompanion.insert(
          roomId: roomUid.asString(),
          lastMessageId: Value(message.id.toInt()),
          mentioned: Value(isMention),
          lastMessageDbId: Value(msg.dbId)),
    );
    return roomUid;
  }
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
  var type = findFetchMessageType(message);
  var json = Object();
  if (type == MessageType.TEXT)
    return message.text.writeToJson();
  else if (type == MessageType.FILE)
    return message.file.writeToJson();
  else if (type == MessageType.FORM)
    return message.form.writeToJson();
  else if (type == MessageType.STICKER)
    return message.sticker.writeToJson();
  else if (type == MessageType.PERSISTENT_EVENT)
    switch (message.persistEvent.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        json = {
          "type": "MUC_EVENT",
          "issueType": getIssueType(
              message.persistEvent.mucSpecificPersistentEvent.issue),
          "issuer":
              message.persistEvent.mucSpecificPersistentEvent.issuer.asString(),
          "assignee": message.persistEvent.mucSpecificPersistentEvent.assignee
              .asString()
        };
        break;
      case PersistentEvent_Type.messageManipulationPersistentEvent:
        //todo
        break;
      case PersistentEvent_Type.adminSpecificPersistentEvent:
        switch (message.persistEvent.adminSpecificPersistentEvent.event) {
          case AdminSpecificPersistentEvent_Event.NEW_CONTACT_ADDED:
            json = {"type": "ADMIN_EVENT"};
            break;
        }

        break;
      case PersistentEvent_Type.notSet:
        // TODO: Handle this case.
        break;
    }
  else if (type == MessageType.POLL)
    return message.poll.writeToJson();
  else if (type == MessageType.LOCATION)
    return message.location.writeToJson();
  else if (type == MessageType.LIVE_LOCATION)
    return message.liveLocation.writeToJson();
  return jsonEncode(json);
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
    default:
      return MessageType.NOT_SET;
  }
}

MessageType findFetchMessageType(Message message) {
  if (message.hasText())
    return MessageType.TEXT;
  else if (message.hasFile())
    return MessageType.FILE;
  else if (message.hasForm())
    return MessageType.FORM;
  else if (message.hasSticker())
    return MessageType.STICKER;
  else if (message.hasPersistEvent())
    return MessageType.PERSISTENT_EVENT;
  else if (message.hasPoll())
    return MessageType.POLL;
  else if (message.hasLiveLocation())
    return MessageType.LIVE_LOCATION;
  else if (message.hasLocation())
    return MessageType.LOCATION;
  else
    return MessageType.NOT_SET;
}

String getIssueType(MucSpecificPersistentEvent_Issue issue) {
  switch (issue) {
    case MucSpecificPersistentEvent_Issue.ADD_USER:
      return "ADD_USER";
    case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
      return "AVATAR_CHANGED";
    case MucSpecificPersistentEvent_Issue.MUC_CREATED:
      return "MUC_CREATED";
    case MucSpecificPersistentEvent_Issue.LEAVE_USER:
      return "LEAVE_USER";
    case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
      return "NAME_CHANGED";
    case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
      return "PIN_MESSAGE";
    case MucSpecificPersistentEvent_Issue.KICK_USER:
      return "KICK_USER";
    default:
      return "UNKNOWN";
  }
}
