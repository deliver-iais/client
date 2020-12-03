import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/services/core_services.dart';

import 'mock_classes_definition.dart';

void messageRepoTestSetup() {
  GetIt.instance.reset();
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<MessageDao>(MockMessageDao());
  getIt.registerSingleton<RoomDao>(MockRoomDao());
  getIt.registerSingleton<PendingMessageDao>(MockPendingMessageDao());
  getIt.registerSingleton<AccountRepo>(MockAccountRepo());
  getIt.registerSingleton<FileRepo>(MockFileRepo());
  getIt.registerSingleton<MucRepo>(MockMucRepo());
  getIt.registerSingleton<CoreServices>(MockCoreServices());
  getIt.registerSingleton<QueryServiceClient>(MockQueryServiceClient());
}

void coreServicesTestSetup() {
  GetIt.instance.reset();
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<CoreServiceClient>(MockCoreServiceClient());
  getIt.registerSingleton<AccountRepo>(MockAccountRepo());
  getIt.registerSingleton<MessageDao>(MockMessageDao());
  getIt.registerSingleton<SeenDao>(MockSeenDao());
  getIt.registerSingleton<LastSeenDao>(MockLastSeenDao());
  getIt.registerSingleton<RoomDao>(MockRoomDao());
  getIt.registerSingleton<PendingMessageDao>(MockPendingMessageDao());
  getIt.registerSingleton<MucRepo>(MockMucRepo());
  getIt.registerSingleton<NotificationServices>(MockNotificationServices());
}
