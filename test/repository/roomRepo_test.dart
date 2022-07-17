// ignore_for_file: file_names, unawaited_futures

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/muc.dart';
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
    group('getSlangName -', () {
      test('When called if currentUserUid same to uid should return you',
          () async {
        getAndRegisterAuthRepo(isCurrentUser: true);
        final i18N = getAndRegisterI18N();
        RoomRepo().getSlangName(testUid);
        verify(i18N.get("you"));
        expect(await RoomRepo().getSlangName(testUid), "you");
      });
      test('When called if category is user and node be empty should return ""',
          () async {
        getAndRegisterAuthRepo();
        expect(await RoomRepo().getSlangName(emptyUid), "");
      });
      test('When called if isSameEntity  be false should  return getName',
          () async {
        getAndRegisterAuthRepo();
        getAndRegisterBotRepo(
          botInfo: BotInfo(uid: botUid.asString(), isOwner: true, name: "test"),
        );
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
        final name = await RoomRepo().getName(testUid);
        verify(accountRepo.getName());
        expect(name, "test");
      });
      test('When called if name is in cache should return name', () async {
        //set to cache
        roomNameCache.set(testUid.asString(), "test");
        final name = await RoomRepo().getName(testUid);
        expect(name, "test");
      });
      test(
          'When called if name is in Is in UidIdName Table should return name and set it in roomNameCache',
          () async {
        roomNameCache.clear();
        final uidIdNameDao = getAndRegisterUidIdNameDao(getByUidHasData: true);
        final name = await RoomRepo().getName(testUid);
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
        final name = await RoomRepo().getName(testUid);
        verify(contactRepo.getContact(testUid));
        expect(name, "test test");
        expect(roomNameCache[testUid.asString()], "test test");
        verify(uidIdNameDao.update(testUid.asString(), name: "test test"));
      });
      test(
          'When called if category is user should getContact from contactRepo and if contact be empty should getContactFromServer and save it in cache',
          () async {
        roomNameCache.clear();
        final contactRepo =
            getAndRegisterContactRepo(getContactFromServerData: "test");
        final name = await RoomRepo().getName(testUid);
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
          fetchMucInfo: Muc(uid: testUid.asString(), name: "test"),
        );
        final name = await RoomRepo().getName(groupUid);
        verify(mucRepo.fetchMucInfo(groupUid));
        verify(uidIdNameDao.update(groupUid.asString(), name: "test"));
        expect(name, "test");
        expect(roomNameCache[groupUid.asString()], "test");
      });
      test(
          'When called if category is Bot should getBotInfo and if botInfo not be empty should return botInfo.name',
          () async {
        roomNameCache.clear();
        final botRepo = getAndRegisterBotRepo(
          botInfo: BotInfo(uid: botUid.asString(), isOwner: true, name: "test"),
        );
        final name = await RoomRepo().getName(botUid);
        verify(botRepo.getBotInfo(botUid));
        expect(name, "test");
      });
      test(
          'When called if category is Bot should getBotInfo and if botInfo  be empty should return uid.node',
          () async {
        roomNameCache.clear();
        final botRepo = getAndRegisterBotRepo(
          botInfo: BotInfo(uid: botUid.asString(), isOwner: true, name: ""),
        );
        final name = await RoomRepo().getName(botUid);
        verify(botRepo.getBotInfo(botUid));
        expect(name, botUid.node);
      });
      test(
          'When called should getIdByUid and if username not be empty should update uidIdNameDao and save it in cache',
          () async {
        roomNameCache.clear();
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        getAndRegisterServicesDiscoveryRepo().queryServiceClient =
            getMockQueryServicesClient(getIdByUidData: "test");
        final name = await RoomRepo().getName(groupUid);
        verify(uidIdNameDao.update(groupUid.asString(), id: "test"));
        expect(name, "test");
        expect(roomNameCache[groupUid.asString()], "test");
      });
    });
    group('getId -', () {
      test('When called if category is bot should return uid.node', () async {
        expect(await RoomRepo().watchId(botUid).first, botUid.node);
      });
      test('When called should userInfo and if not be null should return it',
          () async {
        final uidIdNameDao = getAndRegisterUidIdNameDao(getByUidHasData: true);
        expect(await RoomRepo().watchId(testUid).first, "test");
        verify(uidIdNameDao.getByUid(testUid.asString()));
      });
      test(
          'When called should userInfo and if  be null should return getIdByUid',
          () async {
        getAndRegisterServicesDiscoveryRepo().queryServiceClient =
            getMockQueryServicesClient(getIdByUidData: "test");
        expect(await RoomRepo().watchId(testUid).first, "test");
      });
    });
    group('deleteRoom -', () {
      test('When called if should delete media table', () async {
        final mediaDao = getAndRegisterMediaDao();
        final mediaMetaDataDao = getAndRegisterMediaMetaDataDao();
        await RoomRepo().deleteRoom(testUid);
        verify(mediaMetaDataDao.clear(testUid.asString()));
        verify(mediaDao.clear(testUid.asString()));
      });
      test('When called if should removePrivateRoom', () async {
        final queryServiceClient = getAndRegisterServicesDiscoveryRepo()
            .queryServiceClient = getMockQueryServicesClient();
        await RoomRepo().deleteRoom(testUid);
        verify(
          queryServiceClient
              .removePrivateRoom(RemovePrivateRoomReq()..roomUid = testUid),
        );
      });
      test(
          'When called should getRoom and update firstMessageId with room!.lastMessageId',
          () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final roomDao = getAndRegisterRoomDao(rooms: [testRoom]);
          final deleted = await RoomRepo().deleteRoom(testUid);
          verify(roomDao.getRoom(testUid.asString()));
          verify(
            roomDao.updateRoom(
              uid: testUid.asString(),
              deleted: true,
              firstMessageId: 0,
            ),
          );
          expect(deleted, true);
        });
      });
      test('When called if removePrivateRoom get error should return false',
          () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          getAndRegisterServicesDiscoveryRepo().queryServiceClient =
              getMockQueryServicesClient(removePrivateRoomGetError: true);
          final roomDao = getAndRegisterRoomDao(rooms: [testRoom]);
          final deleted = await RoomRepo().deleteRoom(testUid);
          verifyNever(roomDao.getRoom(testUid.asString()));
          verifyNever(
            roomDao.updateRoom(
              uid: testUid.asString(),
              deleted: true,
              lastUpdateTime: clock.now().millisecondsSinceEpoch,
            ),
          );
          expect(deleted, false);
        });
      });
    });
    group('getIdByUid -', () {
      test('When called should getIdByUid', () async {
        final queryServiceClient = getAndRegisterServicesDiscoveryRepo()
            .queryServiceClient = getMockQueryServicesClient();
        await RoomRepo().getIdByUid(testUid);
        verify(queryServiceClient.getIdByUid(GetIdByUidReq()..uid = testUid));
      });
      test(
          'When called should getIdByUid and update uidIdNameDao with new value',
          () async {
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        getAndRegisterServicesDiscoveryRepo().queryServiceClient =
            getMockQueryServicesClient(getIdByUidData: "test");
        final id = await RoomRepo().getIdByUid(testUid);
        verify(uidIdNameDao.update(testUid.asString(), id: "test"));
        expect(id, "test");
      });
      test('When called should getIdByUid and if get error should return null',
          () async {
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        getAndRegisterServicesDiscoveryRepo().queryServiceClient =
            getMockQueryServicesClient(getIdByUidGetError: true);
        final id = await RoomRepo().getIdByUid(testUid);
        verifyNever(uidIdNameDao.update(testUid.asString(), id: "test"));
        expect(id, null);
      });
    });
    group('updateActivity -', () {
      test(
          'When called if activityObject[roomUid.node] be null should set it with new Activity',
          () async {
        final roomRepo = getAndRegisterRealRoomRepo();
        final subject = BehaviorSubject<Activity>()..add(testActivity);
        roomRepo.updateActivity(testActivity);
        expect(roomRepo.activityObject[testUid.node]?.value, subject.value);
      });
      test(
          'When called if activityObject[roomUid.node] not be null should set it with new Activity and after 10 seconds should set it with noActivity',
          () async {
        final roomRepo = getAndRegisterRealRoomRepo();
        final subject = BehaviorSubject<Activity>()..add(testActivity);
        roomRepo.activityObject[testUid.node] = subject;
        roomRepo.updateActivity(testActivity);
        expect(roomRepo.activityObject[testUid.node]?.value, subject.value);
        await Future.delayed(const Duration(seconds: 10));
        final noActivity = Activity()
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
        final subject = BehaviorSubject<Activity>();
        roomRepo.initActivity(testUid.asString());
        expect(
          roomRepo.activityObject[testUid.asString()]?.valueOrNull,
          subject.valueOrNull,
        );
      });
    });
    group('updateRoomName -', () {
      test('When called should set name to roomNameCache', () async {
        getAndRegisterRealRoomRepo().updateRoomName(testUid, "test");
        expect(roomNameCache[testUid.asString()], "test");
      });
    });
    group('isRoomHaveACustomNotification -', () {
      test('When called should get room have CustomNotification', () async {
        final customNotificationDao = getAndRegisterCustomNotificationDao();
        expect(
          await RoomRepo().isRoomHaveACustomNotification(testUid.asString()),
          false,
        );
        verify(customNotificationDao.isHaveCustomNotif(testUid.asString()));
      });
    });
    group('setRoomCustomNotification -', () {
      test('When called should set path to customNotificationDao ', () async {
        final customNotificationDao = getAndRegisterCustomNotificationDao();
        RoomRepo().setRoomCustomNotification(testUid.asString(), "/test");
        verify(
          customNotificationDao.setCustomNotif(testUid.asString(), "/test"),
        );
      });
    });
    group('getRoomCustomNotification -', () {
      test('When called should get path from customNotificationDao ', () async {
        final customNotificationDao = getAndRegisterCustomNotificationDao();
        expect(
          await RoomRepo().getRoomCustomNotification(testUid.asString()),
          "/test",
        );
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
        RoomRepo().unMute(testUid.asString());
        verify(muteDao.unMute(testUid.asString()));
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
        final value =
            await RoomRepo().watchIsRoomBlocked(testUid.asString()).first;
        expect(value, false);
        verify(blockDao.watchIsBlocked(testUid.asString()));
      });
    });
    group('watchAllRooms -', () {
      test('When called should return list of rooms stream', () async {
        final roomDao = getAndRegisterRoomDao();
        final value = await RoomRepo().watchAllRooms().first;
        expect(value, [testRoom]);
        verify(roomDao.watchAllRooms());
      });
    });
    group('watchRoom -', () {
      test('When called should return room stream', () async {
        final roomDao = getAndRegisterRoomDao();
        final value = await RoomRepo().watchRoom(testUid.asString()).first;
        expect(value, testRoom);
        verify(roomDao.watchRoom(testUid.asString()));
      });
    });
    group('getRoom -', () {
      test('When called should return room', () async {
        final roomDao = getAndRegisterRoomDao();
        expect(await RoomRepo().getRoom(testUid.asString()), testRoom);
        verify(roomDao.getRoom(testUid.asString()));
      });
    });
    group('resetMention -', () {
      test('When called should update room', () async {
        final roomDao = getAndRegisterRoomDao();
        await RoomRepo().resetMention(testUid.asString());
        verify(roomDao.updateRoom(uid: testUid.asString(), mentioned: false));
      });
    });
    group('createRoomIfNotExist -', () {
      test('When called should update room', () async {
        final roomDao = getAndRegisterRoomDao();
        await RoomRepo().createRoomIfNotExist(testUid.asString());
        verify(roomDao.updateRoom(uid: testUid.asString()));
      });
    });
    group('watchMySeen -', () {
      test('When called should return seen stream', () async {
        final seenDao = getAndRegisterSeenDao();
        final value = await RoomRepo().watchMySeen(testUid.asString()).first;
        expect(value, testSeen);
        verify(seenDao.watchMySeen(testUid.asString()));
      });
    });
    group('getMySeen -', () {
      test('When called should return my seen', () async {
        final seenDao = getAndRegisterSeenDao();
        final value = await RoomRepo().getMySeen(testUid.asString());
        expect(value, testSeen);
        verify(seenDao.getMySeen(testUid.asString()));
      });
    });
    group('getOthersSeen -', () {
      test('When called should return other seen', () async {
        final seenDao = getAndRegisterSeenDao();
        final value = await RoomRepo().getOthersSeen(testUid.asString());
        expect(value, testSeen);
        verify(seenDao.getOthersSeen(testUid.asString()));
      });
    });
    group('saveMySeen -', () {
      test('When called should save my seen', () async {
        final seenDao = getAndRegisterSeenDao();
        RoomRepo().updateMySeen(
          uid: testSeen.uid,
          hiddenMessageCount: testSeen.hiddenMessageCount,
          messageId: testSeen.messageId,
        );
        verify(
          seenDao.updateMySeen(
            uid: testSeen.uid,
            hiddenMessageCount: testSeen.hiddenMessageCount,
            messageId: testSeen.messageId,
          ),
        );
      });
    });
    group('block -', () {
      test('When called if block is true should block room', () async {
        final blockDao = getAndRegisterBlockDao();
        final queryServiceClient = getAndRegisterServicesDiscoveryRepo()
            .queryServiceClient = getMockQueryServicesClient();
        await RoomRepo().block(testUid.asString(), block: true);
        verify(queryServiceClient.block(BlockReq()..uid = testUid));
        verify(blockDao.block(testUid.asString()));
      });
      test('When called if block is false should unblock room', () async {
        final blockDao = getAndRegisterBlockDao();
        final queryServiceClient = getAndRegisterServicesDiscoveryRepo()
            .queryServiceClient = getMockQueryServicesClient();
        await RoomRepo().block(testUid.asString(), block: false);
        verify(queryServiceClient.unblock(UnblockReq()..uid = testUid));
        verify(blockDao.unblock(testUid.asString()));
      });
    });
    group('fetchBlockedRoom -', () {
      test('When called should getBlockedList', () async {
        final queryServiceClient = getAndRegisterServicesDiscoveryRepo()
            .queryServiceClient = getMockQueryServicesClient();
        await RoomRepo().fetchBlockedRoom();
        verify(queryServiceClient.getBlockedList(GetBlockedListReq()));
      });
      test('When called should getBlockedList and block them', () async {
        final blockDao = getAndRegisterBlockDao();
        await RoomRepo().fetchBlockedRoom();
        verify(blockDao.block(testUid.asString()));
      });
    });
    group('getAllRooms -', () {
      test('When called should getAllRooms', () async {
        final roomDao = getAndRegisterRoomDao(rooms: [testRoom]);
        await RoomRepo().getAllRooms();
        verify(roomDao.getAllRooms());
      });
      test('When called should getAllRooms and return their uid', () async {
        getAndRegisterRoomDao(rooms: [testRoom]);
        await RoomRepo().getAllRooms();
        expect(await RoomRepo().getAllRooms(), [testUid]);
      });
    });
    group('searchInRoomAndContacts -', () {
      test('When called if text be empty should return []', () async {
        expect(await RoomRepo().searchInRoomAndContacts(""), []);
      });
      test('When called should search text in uidIdNameDao and return uid list',
          () async {
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        expect(await RoomRepo().searchInRoomAndContacts("test"), [testUid]);
        verify(uidIdNameDao.search("test"));
      });
    });
    group('getUidById -', () {
      test('When called if uidIdNameDao contain uid should return uid',
          () async {
        final uidIdNameDao =
            getAndRegisterUidIdNameDao(getUidByIdHasData: true);
        expect(await RoomRepo().getUidById("test"), testUid.asString());
        verify(uidIdNameDao.getUidById("test"));
      });
      test(
          'When called if uidIdNameDao doesnt contain uid should fetchUidById and update uidIdNameDao',
          () async {
        final uidIdNameDao = getAndRegisterUidIdNameDao();
        expect(await RoomRepo().getUidById("test"), testUid.asString());
        verify(uidIdNameDao.update(testUid.asString(), id: "test"));
      });
    });
    group('fetchUidById -', () {
      test(
          'When called if uidIdNameDao doesnt contain uid should fetchUidById and update uidIdNameDao',
          () async {
        final queryServiceClient = getAndRegisterServicesDiscoveryRepo()
            .queryServiceClient = getMockQueryServicesClient();
        expect(await RoomRepo().fetchUidById("test"), testUid);
        verify(queryServiceClient.getUidById(GetUidByIdReq()..id = "test"));
      });
    });
    group('reportRoom -', () {
      test('When called should report the room', () async {
        final queryServiceClient = getAndRegisterServicesDiscoveryRepo()
            .queryServiceClient = getMockQueryServicesClient();
        RoomRepo().reportRoom(testUid);
        verify(queryServiceClient.report(ReportReq()..uid = testUid));
      });
    });

    group('getAllGroups -', () {
      test('When called should get all group', () async {
        final roomDao = getAndRegisterRoomDao();
        expect(await RoomRepo().getAllGroups(), [testRoom]);
        verify(roomDao.getAllGroups());
      });
    });
    group('updateRoomDraft -', () {
      test('When called should update RoomDraft', () async {
        final roomDao = getAndRegisterRoomDao();
        RoomRepo().updateRoomDraft(testUid.asString(), "test");
        verify(roomDao.updateRoom(uid: testUid.asString(), draft: "test"));
      });
    });
    group('isDeletedRoom -', () {
      test('When called should return room.deleted', () async {
        final roomDao =
            getAndRegisterRoomDao(rooms: [testRoom.copyWith(deleted: true)]);
        expect(await RoomRepo().isDeletedRoom(testUid.asString()), true);
        verify(roomDao.getRoom(testUid.asString()));
      });
    });
  });
}
