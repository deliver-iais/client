import 'dart:async';
import 'dart:convert';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart' as M;

import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectionStatus { Connected, Disconnected }

const MIN_BACKOFF_TIME = 4;
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
  StreamSubscription<ServerPacket> _listenner;

  int _backoffTime = MIN_BACKOFF_TIME;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);

  BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);

  bool _responseChecked = false;

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _messageDao = GetIt.I.get<MessageDao>();
  var _seenDao = GetIt.I.get<SeenDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  var _notificationService = GetIt.I.get<NotificationServices>();

  initStreamConnection() async {
    _startStream();

    _startCheckerTimer();

    _connectionStatus
        .distinct()
        .listen((event) => connectionStatus.add(event));
  }

  _startCheckerTimer() {
    sendPingMessage();
    _responseChecked = false;

    Timer(new Duration(seconds: _backoffTime), () {
      print("timer");
      if (!_responseChecked) {
        print("not respond");
        if (_backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO)
          _backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
        _connectionStatus.add(ConnectionStatus.Disconnected);
        _startStream();
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
      _responseStream = _grpcCoreService.establishStream(_clientPacket.stream.asBroadcastStream(),
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));

      _listenner = _responseStream.listen((serverPacket) {
        print(serverPacket.toString());
        gotResponse();
        switch (serverPacket.whichType()) {
          case ServerPacket_Type.message:
            _saveIncomingMessage(serverPacket.message);
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
          case ServerPacket_Type.notSet:
            break;
          case ServerPacket_Type.pong:
            break;
        }
      });
    } catch (e) {
      print("correservice error");
    }
  }

  _saveIncomingMessage(Message message) {
    _messageDao.insertMessage(M.Message(
        id: message.id.toInt(),
        roomId: message.from.node.contains(_accountRepo.currentUserUid.node)
            ? message.to.string
            : message.from.string,
        packetId: message.packetId,
        time: DateTime.fromMillisecondsSinceEpoch(message.time.toInt()),
        to: message.to.string,
        from: message.from.string,
        replyToId: message.replyToId.toInt(),
        forwardedFrom: message.forwardFrom.string,
        json: message.whichType() == Message_Type.text
            ? message.text.text
            : jsonEncode({
                "uuid": message.file.uuid,
                "name": message.file.name,
                "caption": message.file.caption,
                "type": findType(message.file.name)
              }),
        edited: message.edited,
        encrypted: message.encrypted,
        type: getMessageType(message.whichType())));
    _pendingMessageDao
        .deletePendingMessage(M.PendingMessage(messageId: message.packetId));
    _roomDao.insertRoom(
      M.Room(roomId: message.from.string, lastMessage: message.packetId),
    );
    if (!message.from.node.contains(_accountRepo.currentUserUid.node)) {
      _notificationService.showTextNotification(
          message.id.toInt(), message.from.string, "ffff", message.text.text);
    }
  }

  sendMessage(MessageByClient message) {
    _clientPacket.add(ClientPacket()
      ..message = message
      ..id = message.packetId);
    _notificationService.showTextNotification(1, "tttt","ttt", message.text.text);
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
      case Categories.PRIVATE_CHANNEL:
      case Categories.PUBLIC_CHANNEL:
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
}
