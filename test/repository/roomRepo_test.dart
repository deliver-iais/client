import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
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
      test('When called if isSameEntity  be false should  return getName',
          () async {
        getAndRegisterBotRepo(
            botInfo:
                BotInfo(uid: botUid.asString(), isOwner: true, name: "test"));
        expect(await RoomRepo().getSlangName(botUid), "test");
      });
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
      test(
          'When called if name is in Is in UidIdName Table should return name and set it in roomNameCache',
          () async {
        roomNameCache.clear();
        final uidIdNameDao = getAndRegisterUidIdNameDao(getByUidHasData: true);
        var name = await RoomRepo().getName(testUid);
        verify(uidIdNameDao.getByUid(testUid.asString()));
        expect(name, "test");
        expect(roomNameCache[testUid.asString()], "test");
      });
      test(
          'When called if category is user should getContact from contactRepo and if contact not be empty should save name to cache and update uidIdNameDao',
          () async {
        roomNameCache.clear();
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        final contactRepo = getAndRegisterContactRepo(getContactHasData: true);
        var name = await RoomRepo().getName(testUid);
        verify(contactRepo.getContact(testUid));
        expect(name, "testtest");
        expect(roomNameCache[testUid.asString()], "testtest");
        verify(uidIdNameDao.update(testUid.asString(), name: "testtest"));
      });
      test(
          'When called if category is user should getContact from contactRepo and if contact be empty should getContactFromServer and save it in cache',
          () async {
        roomNameCache.clear();
        final contactRepo =
            getAndRegisterContactRepo(getContactFromServerData: "test");
        var name = await RoomRepo().getName(testUid);
        verify(contactRepo.getContactFromServer(testUid));
        expect(name, "test");
        expect(roomNameCache[testUid.asString()], "test");
      });
      test(
          'When called if category is group or channel should fetchMucInfo and if muc not be empty should update uidIdNameDao and save it in cache',
          () async {
        roomNameCache.clear();
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        final mucRepo = getAndRegisterMucRepo(
            fetchMucInfo: Muc(uid: testUid.asString(), name: "test"));
        var name = await RoomRepo().getName(groupUid);
        verify(mucRepo.fetchMucInfo(groupUid));
        verify(uidIdNameDao.update(groupUid.asString(), name: "test"));
        expect(name, "test");
        expect(roomNameCache[groupUid.asString()], "test");
      });
      test(
          'When called if category is Bot should getBotInfo and if botInfo not be empty should update uidIdNameDao and save it in cache',
          () async {
        roomNameCache.clear();
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        final botRepo = getAndRegisterBotRepo(
            botInfo:
                BotInfo(uid: botUid.asString(), isOwner: true, name: "test"));
        var name = await RoomRepo().getName(botUid);
        verify(botRepo.getBotInfo(botUid));
        verify(uidIdNameDao.update(botUid.asString(),
            name: "test", id: botUid.node));
        expect(name, "test");
        expect(roomNameCache[botUid.asString()], "test");
      });
      test(
          'When called should getIdByUid and if username not be empty should update uidIdNameDao and save it in cache',
          () async {
        roomNameCache.clear();
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        getAndRegisterQueryServiceClient(getIdByUidData: "test");
        var name = await RoomRepo().getName(groupUid);
        verify(uidIdNameDao.update(groupUid.asString(), id: "test"));
        expect(name, "test");
        expect(roomNameCache[groupUid.asString()], "test");
      });
    });
    group('getId -', () {
      test('When called if category is bot should return uid.node', () async {
        expect(await RoomRepo().getId(botUid), botUid.node);
      });
      test('When called should userInfo and if not be null should return it',
          () async {
        final uidIdNameDao = getAndRegisterUidIdNameDao(getByUidHasData: true);
        expect(await RoomRepo().getId(testUid), "test");
        verify(uidIdNameDao.getByUid(testUid.asString()));
      });
      test(
          'When called should userInfo and if  be null should return getIdByUid',
          () async {
        getAndRegisterQueryServiceClient(getIdByUidData: "test");
        expect(await RoomRepo().getId(testUid), "test");
      });
    });
    group('deleteRoom -', () {
      test('When called if should removePrivateRoom', () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        await RoomRepo().deleteRoom(testUid);
        verify(queryServiceClient
            .removePrivateRoom(RemovePrivateRoomReq()..roomUid = testUid));
      });
      test(
          'When called should getRoom and update firstMessageId with room!.lastMessageId',
          () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final roomDao = getAndRegisterRoomDao(rooms: [testRoom]);
          var deleted = await RoomRepo().deleteRoom(testUid);
          verify(roomDao.getRoom(testUid.asString()));
          verify(roomDao.updateRoom(Room(
              uid: testUid.asString(),
              deleted: true,
              firstMessageId: 0,
              lastUpdateTime: clock.now().millisecondsSinceEpoch)));
          expect(deleted, true);
        });
      });
      test('When called if removePrivateRoom get error should return false',
          () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          getAndRegisterQueryServiceClient(removePrivateRoomGetError: true);
          final roomDao = getAndRegisterRoomDao(rooms: [testRoom]);
          var deleted = await RoomRepo().deleteRoom(testUid);
          verifyNever(roomDao.getRoom(testUid.asString()));
          verifyNever(roomDao.updateRoom(Room(
              uid: testUid.asString(),
              deleted: true,
              firstMessageId: 0,
              lastUpdateTime: clock.now().millisecondsSinceEpoch)));
          expect(deleted, false);
        });
      });
    });
    group('getIdByUid -', () {
      test('When called should getIdByUid', () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        await RoomRepo().getIdByUid(testUid);
        verify(queryServiceClient.getIdByUid(GetIdByUidReq()..uid = testUid));
      });
      test(
          'When called should getIdByUid and update uidIdNameDao with new value',
          () async {
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        getAndRegisterQueryServiceClient(getIdByUidData: "test");
        var id = await RoomRepo().getIdByUid(testUid);
        verify(uidIdNameDao.update(testUid.asString(), id: "test"));
        expect(id, "test");
      });
      test('When called should getIdByUid and if get error should return null',
          () async {
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        getAndRegisterQueryServiceClient(getIdByUidGetError: true);
        var id = await RoomRepo().getIdByUid(testUid);
        verifyNever(uidIdNameDao.update(testUid.asString(), id: "test"));
        expect(id, null);
      });
    });
    group('updateActivity -', () {
      test(
          'When called if activityObject[roomUid.node] be null should set it with new Activity',
          () async {
        final roomRepo = getAndRegisterRealRoomRepo();
        BehaviorSubject<Activity> subject = BehaviorSubject();
        subject.add(testActivity);
        roomRepo.updateActivity(testActivity);
        expect(roomRepo.activityObject[testUid.node]?.value, subject.value);
      });
      test(
          'When called if activityObject[roomUid.node] not be null should set it with new Activity and after 10 seconds should set it with noActivity',
          () async {
        final roomRepo = getAndRegisterRealRoomRepo();
        BehaviorSubject<Activity> subject = BehaviorSubject();
        subject.add(testActivity);
        roomRepo.activityObject[testUid.node] = subject;
        roomRepo.updateActivity(testActivity);
        expect(roomRepo.activityObject[testUid.node]?.value, subject.value);
        await Future.delayed(const Duration(seconds: 10));
        Activity noActivity = Activity()
          ..from = testActivity.from
          ..typeOfActivity = ActivityType.NO_ACTIVITY
          ..to = testActivity.to;
        expect(roomRepo.activityObject[testUid.node]?.value, noActivity);
      });
    });
    group('initActivity -', () {
      test(
          'When called if activityObject[roomUid.node] be null should initialize it ',
          () async {
        final roomRepo = getAndRegisterRealRoomRepo();
        BehaviorSubject<Activity> subject = BehaviorSubject();
        roomRepo.initActivity(testUid.asString());
        expect(roomRepo.activityObject[testUid.asString()]?.valueOrNull,
            subject.valueOrNull);
      });
    });
    group('updateRoomName -', () {
      test('When called should set name to roomNameCache', () async {
        final roomRepo = getAndRegisterRealRoomRepo();
        roomRepo.updateRoomName(testUid, "test");
        expect(roomNameCache[testUid.asString()], "test");
      });
    });
    group('isRoomHaveACustomNotification -', () {
      test('When called should get room have CustomNotification', () async {
        final customNotificationDao = getAndRegisterCustomNotificatonDao();
        expect(
            await RoomRepo().isRoomHaveACustomNotification(testUid.asString()),
            false);
        verify(customNotificationDao.isHaveCustomNotif(testUid.asString()));
      });
    });
    group('setRoomCustomNotification -', () {
      test('When called should set path to customNotificationDao ', () async {
        final customNotificationDao = getAndRegisterCustomNotificatonDao();
        RoomRepo().setRoomCustomNotification(testUid.asString(), "/test");
        verify(
            customNotificationDao.setCustomNotif(testUid.asString(), "/test"));
      });
    });
    group('getRoomCustomNotification -', () {
      test('When called should get path from customNotificationDao ', () async {
        final customNotificationDao = getAndRegisterCustomNotificatonDao();
        expect(await RoomRepo().getRoomCustomNotification(testUid.asString()),
            "/test");
        verify(customNotificationDao.getCustomNotif(testUid.asString()));
      });
    });
    group('mute -', () {
      test('When called should mute room', () async {
        final muteDao = getAndRegisterMuteDao();
        RoomRepo().mute(testUid.asString());
        verify(muteDao.mute(testUid.asString()));
      });
    });
    group('unMute -', () {
      test('When called should unMute room', () async {
        final muteDao = getAndRegisterMuteDao();
        RoomRepo().unmute(testUid.asString());
        verify(muteDao.unmute(testUid.asString()));
      });
    });
    group('isRoomBlocked -', () {
      test('When called should check is RoomBlocked', () async {
        final blockDao = getAndRegisterBlockDao();
        expect(await RoomRepo().isRoomBlocked(testUid.asString()), false);
        verify(blockDao.isBlocked(testUid.asString()));
      });
    });
    group('watchIsRoomBlocked -', () {
      test('When called should return IsRoomBlocked stream', () async {
        final blockDao = getAndRegisterBlockDao();
        var value =
            await RoomRepo().watchIsRoomBlocked(testUid.asString()).first;
        expect(value, false);
        verify(blockDao.watchIsBlocked(testUid.asString()));
      });
    });
  });
}
