import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../constants/constants.dart';
import '../helper/test_helper.dart';

void main() {
  group('RoomRepoTest -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    group('insertRoom -', () {
      test('When called should update Room', () async {
        final roomDao = getAndRegisterRoomDao();
        RoomRepo().insertRoom(testUid.asString());
        verify(roomDao.updateRoom(testRoom));
      });
    });
    group('updateRoom -', () {
      test('When called should update Room', () async {
        final roomDao = getAndRegisterRoomDao();
        RoomRepo().updateRoom(testRoom);
        verify(roomDao.updateRoom(testRoom));
      });
    });
    group('getSlangName -', () {
      test('When called if currentUserUid same to uid should return you',
          () async {
        final i18N = getAndRegisterI18N();
        RoomRepo().getSlangName(testUid);
        verify(i18N.get("you"));
        expect(await RoomRepo().getSlangName(testUid), "you");
      });
    });
  });
}
