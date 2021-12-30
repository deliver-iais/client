import 'package:deliver/box/room.dart';
import 'package:deliver/main.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MessageRepoMock extends Mock implements MessageRepo {}


class RoomMock extends Mock implements Room {}

void registerServices() {
  setupDI();
  GetIt.I.registerSingleton<MessageRepoMock>(MessageRepoMock());
}
