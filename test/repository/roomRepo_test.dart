import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helper/test_helper.dart';
import 'messageRepo_test.dart';

void main() {
  group('RoomRepoTest -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    group('insertRoom -', () {
      test('When called should update Room', () async {
        final roomDao = getAndRegisterRoomDao();
        RoomRepo().insertRoom(testUid.asString());
        verify(roomDao.updateRoom(Room(uid: testUid.asString())));
      });
    });
  });
}
