import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
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
      test('When called if category is user and node be empty should return ""',
          () async {
        expect(await RoomRepo().getSlangName(emptyUid), "");
      });
      //todo add another test when getName test pass
    });
    group('isVerified -', () {
      test(
          'When called if category is not be System or bot and node not be father_bot should return false',
          () async {
        expect(await RoomRepo().isVerified(testUid), false);
      });
      test(
          'When called if category is System or bot and node be father_bot should return true',
          () async {
        expect(await RoomRepo().isVerified(botUid), true);
      });
    });
    group('fastForwardName -', () {
      test('When called if name is not in roomNameCache should return null',
          () async {
        expect(RoomRepo().fastForwardName(testUid), null);
      });
      test('When called if name is in roomNameCache should return name',
          () async {
        //set to cache
        roomNameCache.set(testUid.asString(), "test");
        expect(RoomRepo().fastForwardName(testUid), "test");
      });
    });
    group('getName -', () {
      test('When called if uid is emptyUid should return ""', () async {
        expect(await RoomRepo().getName(emptyUid), "");
      });
      test('When called if category is SYSTEM should return APPLICATION_NAME',
          () async {
        expect(await RoomRepo().getName(systemUid), APPLICATION_NAME);
      });
      test(
          'When called if uid is isCurrentUser should return accountRepo.getName',
          () async {
        final accountRepo = getAndRegisterAccountRepo();
        getAndRegisterAuthRepo(isCurrentUser: true);
        var name = await RoomRepo().getName(testUid);
        verify(accountRepo.getName());
        expect(name, "test");
      });
      test('When called if name is in cache should return name', () async {
        //set to cache
        roomNameCache.set(testUid.asString(), "test");
        var name = await RoomRepo().getName(testUid);
        expect(name, "test");
      });
    });
  });
}
