import 'dart:async';

import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:flutter/cupertino.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/mockito.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:rxdart/rxdart.dart';

class MockMessageDao extends Mock implements MessageDao {}

class MockRoomDao extends Mock implements RoomDao {}

class MockPendingMessageDao extends Mock implements PendingMessageDao {}

class MockAccountRepo extends Mock implements AccountRepo {}

class MockFileRepo extends Mock implements FileRepo {}

class MockMucRepo extends Mock implements MucRepo {}

class MockCoreServices extends Mock implements CoreServices {
  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);
}

class MockResponseFuture<T> extends Mock implements ResponseFuture<T> {
  final T value;

  MockResponseFuture(this.value);

  Future<S> then<S>(FutureOr<S> onValue(T value), {Function onError}) =>
      Future.value(value).then(onValue, onError: onError);
}

// class MockResponseStream<T> extends Mock implements ResponseStream<T> {
//   var controller = StreamController<T>();
//
//   MockResponseStream();
//
//   void add(T value) => controller.add(value);
//   @override
//   StreamSubscription<T> listen(void Function(T value) onData,
//           {Function onError, void Function() onDone, bool cancelOnError}) =>
//       controller.stream.listen((event) => event);
//
//   //     Future.value(value).then(onValue, onError: onError);
// }

class MockQueryServiceClient extends Mock implements QueryServiceClient {}

class MockNotificationServices extends Mock implements NotificationServices {}

class MockCoreServiceClient extends Mock implements CoreServiceClient {}

class MockLastSeenDao extends Mock implements LastSeenDao {}

class MockSeenDao extends Mock implements SeenDao {}
