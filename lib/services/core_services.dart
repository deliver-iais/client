import 'dart:async';
import 'dart:convert';

import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart' as M;

import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';

import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'package:rxdart/rxdart.dart';

enum ConnectionStatus { Connected, Disconnected }

const MIN_BACKOFF_TIME = 1;
const MAX_BACKOFF_TIME = 32;
const BACKOFF_TIME_INCREASE_RATIO = 2;

class CoreServices {
  static ClientChannel _clientChannel = ClientChannel(
      ServicesDiscoveryRepo().coreService.host,
      port: ServicesDiscoveryRepo().coreService.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var _grpcCoreService = CoreServiceClient(_clientChannel);
  var _clientPacket = StreamController<ClientPacket>();
  ResponseStream<ServerPacket> _responseStream;

  int _backoffTime = MIN_BACKOFF_TIME;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);

  BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);

  bool _responseChecked = false;

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _messageDao = GetIt.I.get<MessageDao>();
  var _seenDao = GetIt.I.get<SeenDao>();
  var _lastSeenDao = GetIt.I.get<LastSeenDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  var _notificationServices = GetIt.I.get<NotificationServices>();

  initStreamConnection() async {
    await _startStream();
    await _startCheckerTimer();
    _connectionStatus.distinct().listen((event) => connectionStatus.add(event));
  }

  _startCheckerTimer() {
    sendPingMessage();
    _responseChecked = false;

    Timer(new Duration(seconds: _backoffTime), () {
      print("timer");
      if (!_responseChecked) {
        if (_backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO)
          _connectionStatus.add(ConnectionStatus.Disconnected);
        _startStream();
      } else {
        _backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
      }
      _startCheckerTimer();
    });
  }

  void gotResponse() {
    _connectionStatus.add(ConnectionStatus.Connected);
    _backoffTime = MIN_BACKOFF_TIME;
    _responseChecked = true;
  }

  _startStream() async {
    try {
      _clientPacket = StreamController<ClientPacket>();
      _responseStream = _grpcCoreService.establishStream(
          _clientPacket.stream.asBroadcastStream(),
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));

      _responseStream.listen((serverPacket) {
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
    print("message is send ");
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

  deleteMessage() {}

  MessageType getMessageType(Message_Type messageType) {
    switch (messageType) {
      case Message_Type.text:
        return MessageType.TEXT;
        break;
      case Message_Type.file:
        return MessageType.FILE;
        break;
      case Message_Type.sticker:
        return MessageType.STICKER;
        break;
      case Message_Type.location:
        return MessageType.LOCATION;
        break;
      case Message_Type.liveLocation:
        return MessageType.LIVE_LOCATION;
        break;
      case Message_Type.poll:
        return MessageType.POLL;
        break;
      case Message_Type.form:
        return MessageType.FORM;
        break;
      case Message_Type.persistEvent:
        return MessageType.PERSISTENT_EVENT;
        break;
      case Message_Type.notSet:
        return MessageType.NOT_SET;
        break;
    }
  }

  _saveSeenMessage(Seen seen) {
    Uid roomId;
    switch (seen.to.category) {
      case Categories.USER:
        seen.to == _accountRepo.currentUserUid
            ? roomId = seen.to
            : roomId = seen.from;
        break;
      case Categories.GROUP:
      case Categories.CHANNEL:
      case Categories.BOT:
        roomId = seen.to;
        break;
    }
    _seenDao.insertSeen(M.Seen(
        messageId: seen.id.toInt(),
        user: seen.from.string,
        roomId: roomId.string));
  }

  _saveActivityMessage(Activity activity) {
    //todo
  }

  void savePongMessage(Pong pong) {}

  String findType(String path) {
    String postfix = path.split('.').last;
    if (postfix == 'png' || postfix == 'jpg' || postfix == 'jpeg')
      return 'image';
    else if (postfix == 'mp4')
      return 'video';
    else if (postfix == 'mp3')
      return 'audio';
    else
      return 'file';
  }

  _saveAckMessage(MessageDeliveryAck messageDeliveryAck) async {
    print(messageDeliveryAck.toString());
    var roomId = messageDeliveryAck.to.getString();
    var packetId = messageDeliveryAck.packetId;
    var id = messageDeliveryAck.id.toInt();
    var time = messageDeliveryAck.time.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    _messageDao.updateMessageId(roomId, packetId, id, time);
    _roomDao.insertRoom(M.Room(roomId: roomId, lastMessageId: id));
    _lastSeenDao.updateLastSeen(roomId, id);
    _pendingMessageDao.deletePendingMessage(packetId);
  }

  _saveIncomingMessage(Message message) async {
    print(message.toString());
    var msg = await saveMessageInMessagesDB(message);
    bool isCurrentUser =
        message.from.node.contains(_accountRepo.currentUserUid.node);
    var roomUid = isCurrentUser
        ? message.to
        : (message.to.category == Categories.USER ? message.from : message.to);

    _roomDao.insertRoom(
      M.Room(
          roomId: roomUid.getString(),
          lastMessageId: message.id.toInt(),
          lastMessageDbId: msg.dbId),
    );
    var roomName = await RoomRepo().getRoomDisplayName(message.from);
    _notificationServices.showNotification(msg, roomName);

    // TODO remove later on if Add User to group message feature is implemented
    if (message.to.category != Categories.USER) {
      _mucRepo.saveMucInfo(message.to);
    }
  }

  saveMessageInMessagesDB(Message message) async {
    print(message.toString());
    M.Message msg = M.Message(
        id: message.id.toInt(),
        roomId: message.whichType() == Message_Type.persistEvent?message.from.string: message.from.node.contains(_accountRepo.currentUserUid.node)
            ? message.to.string
            : message.to.category == Categories.USER
                ? message.from.string
                : message.to.string,
        packetId: message.packetId,
        time: DateTime.fromMillisecondsSinceEpoch(message.time.toInt()),
        to: message.to.string,
        from: message.from.string,
        replyToId: message.replyToId.toInt(),
        forwardedFrom: message.forwardFrom.string,
        json: messageToJson(message),
        edited: message.edited,
        encrypted: message.encrypted,
        type: getMessageType(message.whichType()));

    int dbId = await _messageDao.insertMessage(msg);

    return msg.copyWith(dbId: dbId);
  }

  String messageToJson(Message message) {
    var type = findFetchMessageType(message);
    var json = Object();
    if (type == MessageType.TEXT)
      json = {"text": message.text.text};
    else if (type == MessageType.FILE)
      json = {
        "uuid": message.file.uuid,
        "size": message.file.size.toInt(),
        "type": message.file.type,
        "name": message.file.name,
        "caption": message.file.caption,
        "width": message.file.width.toInt(),
        "height": message.file.height.toInt(),
        "duration": message.file.duration.toDouble()
      };
    else if (type == MessageType.FORM)
      json = {"uuid": message.form.uuid, "title": message.form.title};
    else if (type == MessageType.STICKER)
      json = {
        "uuid": message.sticker.uuid,
        "id": message.sticker.id,
        "width": message.sticker.width.toInt(),
        "height": message.sticker.height.toInt()
      };
    else if (type == MessageType.PERSISTENT_EVENT)
      switch (message.persistEvent.whichType()) {
        case PersistentEvent_Type.mucSpecificPersistentEvent:
          json = {
            "type": "MUC_EVENT",
            "issueType": getIssueType(
                message.persistEvent.mucSpecificPersistentEvent.issue),
            "issuer":
                message.persistEvent.mucSpecificPersistentEvent.issuer.string,
            "assignee":
                message.persistEvent.mucSpecificPersistentEvent.assignee.string
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
      json = {
        "uuid": message.poll.uuid,
        "title": message.poll.title,
        "number_of_options": message.poll.numberOfOptions
      };
    else if (type == MessageType.LOCATION)
      json = {
        "latitude": message.location.latitude.toInt(),
        "longitude": message.location.longitude.toInt()
      };
    else if (type == MessageType.LIVE_LOCATION)
      json = {"uuid": message.liveLocation.uuid};
    return jsonEncode(json);
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
        break;
      case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
        return "AVATAR_CHANGED";
        break;
      case MucSpecificPersistentEvent_Issue.MUC_CREATED:
        return "MUC_CREATED";
        break;
      case MucSpecificPersistentEvent_Issue.LEAVE_USER:
        return "LEAVE_USER";
        break;
      case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
        return "NAME_CHANGED";
        break;
      case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
        return "PIN_MESSAGE";
        break;
      case MucSpecificPersistentEvent_Issue.KICK_USER:
        return "KICK_USER";
        break;
    }
  }
}
