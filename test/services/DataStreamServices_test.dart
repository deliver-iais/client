import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../constants/constants.dart';
import '../helper/test_helper.dart';

void main() {
  group('DataStreamServices -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    group('handleIncomingMessage -', () {
      test(
          'When called should check isRoomBlocked or not and if is blocked should return null',
          () async {
        final roomRepo = getAndRegisterRoomRepo(isRoomBlocked: true);
        final message = Message(
          from: testUid,
          to: testUid,
        );
        final value = await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: true,
        );
        verify(roomRepo.isRoomBlocked(testUid.asString()));
        expect(value, null);
      });
      test(
          'When called if message type is MucSpecificPersistentEvent_Issue.DELETED should updateRoom and return null',
          () async {
        final roomDao = getAndRegisterRoomDao();
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            mucSpecificPersistentEvent: MucSpecificPersistentEvent(
              issue: MucSpecificPersistentEvent_Issue.DELETED,
            ),
          ),
        );
        final value = await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: true,
        );
        verify(roomDao.updateRoom(uid: testUid.asString(), deleted: true));
        expect(value, null);
      });
      test(
          'When called if message type is MucSpecificPersistentEvent_Issue.PIN_MESSAGE if is not OnlineMessage should get muc from mucDao and messageId to pinMessages list and update mucDao with new list',
          () async {
        final mucDao = getAndRegisterMucDao();
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            mucSpecificPersistentEvent: MucSpecificPersistentEvent(
              issue: MucSpecificPersistentEvent_Issue.PIN_MESSAGE,
              messageId: Int64(1),
            ),
          ),
        );
        await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: false,
        );
        verify(mucDao.get(testUid.asString()));
        verify(
          mucDao.update(
            Muc(
              uid: testUid.asString(),
              showPinMessage: true,
              pinMessagesIdList: [1],
            ),
          ),
        );
      });

      test(
          'When called if message type is MucSpecificPersistentEvent_Issue.KICK_USER and assignee to current user should updateRoom and return null',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterAuthRepo(isCurrentUser: true);
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            mucSpecificPersistentEvent: MucSpecificPersistentEvent(
              issue: MucSpecificPersistentEvent_Issue.KICK_USER,
              assignee: testUid,
            ),
          ),
        );
        final value = await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: true,
        );
        verify(roomDao.updateRoom(uid: testUid.asString(), deleted: true));
        expect(value, null);
      });
      test(
          'When called if message type is MucSpecificPersistentEvent_Issue.JOINED_USER or MucSpecificPersistentEvent_Issue.ADD_USER and assignee to current user should updateRoom',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterAuthRepo(isCurrentUser: true);
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            mucSpecificPersistentEvent: MucSpecificPersistentEvent(
              issue: MucSpecificPersistentEvent_Issue.JOINED_USER,
              assignee: testUid,
            ),
          ),
        );
        await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: true,
        );
        verify(roomDao.updateRoom(uid: testUid.asString(), deleted: false));
      });
      test(
          'When called if message type is MucSpecificPersistentEvent_Issue.LEAVE_USER and assignee to current user should updateRoom and return null',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterAuthRepo(isCurrentUser: true);
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            mucSpecificPersistentEvent: MucSpecificPersistentEvent(
              issue: MucSpecificPersistentEvent_Issue.LEAVE_USER,
              assignee: testUid,
            ),
          ),
        );
        final value = await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: true,
        );
        verify(roomDao.updateRoom(uid: testUid.asString(), deleted: true));
        expect(value, null);
      });
      test(
          'When called if message type is MucSpecificPersistentEvent_Issue.LEAVE_USER and is not assignee to current user should delete member',
          () async {
        final mucDao = getAndRegisterMucDao();
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            mucSpecificPersistentEvent: MucSpecificPersistentEvent(
              issue: MucSpecificPersistentEvent_Issue.LEAVE_USER,
              issuer: testUid,
              assignee: testUid,
            ),
          ),
        );
        await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: true,
        );
        verify(
          mucDao.deleteMember(
            Member(
              memberUid: testUid.asString(),
              mucUid: testUid.asString(),
            ),
          ),
        );
      });
      test(
          'When called if message type is MucSpecificPersistentEvent_Issue.AVATAR_CHANGED should fetchAvatar',
          () async {
        final avatarRepo = getAndRegisterAvatarRepo();
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            mucSpecificPersistentEvent: MucSpecificPersistentEvent(
              issue: MucSpecificPersistentEvent_Issue.AVATAR_CHANGED,
            ),
          ),
        );
        await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: true,
        );
        verify(
          avatarRepo.fetchAvatar(testUid, forceToUpdate: true),
        );
      });
      test(
          'When called if message type is  MessageManipulationPersistentEvent_Action.EDITED should getMessage from messageDao',
          () async {
        final messageDao = getAndRegisterMessageDao();
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            messageManipulationPersistentEvent:
                MessageManipulationPersistentEvent(
              action: MessageManipulationPersistentEvent_Action.EDITED,
              messageId: Int64(),
            ),
          ),
        );
        await DataStreamServices().handleIncomingMessage(
          message,
          isOnlineMessage: true,
        );
        verify(
          messageDao.getMessage(testUid.asString(), 0),
        );
      });
    });
    group('shouldNotifyForThisMessage -', () {
      test('When called if message shouldBeQuiet should return false',
          () async {
        final message = Message(
          from: testUid,
          to: testUid,
          shouldBeQuiet: true,
        );
        final value = await DataStreamServices().shouldNotifyForThisMessage(
          message,
        );
        expect(value, false);
      });
      test(
          'When called if isAllNotificationDisabled or isRoomMuted should return false',
          () async {
        final uxService =
            getAndRegisterUxService(isAllNotificationDisabled: true);
        final message = Message(
          from: testUid,
          to: testUid,
        );
        final value = await DataStreamServices().shouldNotifyForThisMessage(
          message,
        );
        verify(uxService.isAllNotificationDisabled);
        expect(value, false);
      });
      test(
          'When called if isAllNotificationDisabled or isRoomMuted should return false',
          () async {
        final roomRepo = getAndRegisterRoomRepo(isRoomMuted: true);
        final message = Message(
          from: testUid,
          to: testUid,
        );
        final value = await DataStreamServices().shouldNotifyForThisMessage(
          message,
        );
        verify(roomRepo.isRoomMuted(testUid.asString()));
        expect(value, false);
      });
      test('When called if isCurrentUser should return false', () async {
        final authRepo = getAndRegisterAuthRepo(isCurrentUser: true);
        final message = Message(
          from: testUid,
          to: testUid,
        );
        final value = await DataStreamServices().shouldNotifyForThisMessage(
          message,
        );
        verify(authRepo.isCurrentUser(testUid.asString()));
        expect(value, false);
      });
      test('When called if message type is callEvent should return false',
          () async {
        final message = Message(
          from: testUid,
          to: testUid,
          callEvent: CallEvent(),
        );
        final value = await DataStreamServices().shouldNotifyForThisMessage(
          message,
        );
        expect(value, false);
      });
      test(
          'When called if message type is mucSpecificPersistentEvent should return !authRepo.isCurrentUser for issuer',
          () async {
        final authRepo = getAndRegisterAuthRepo(isCurrentUser: true);
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            mucSpecificPersistentEvent: MucSpecificPersistentEvent(
              issue: MucSpecificPersistentEvent_Issue.DELETED,
              issuer: testUid,
            ),
          ),
        );
        final value = await DataStreamServices().shouldNotifyForThisMessage(
          message,
        );
        verify(authRepo.isCurrentUser(testUid.asString()));
        expect(value, false);
      });
    });
  });
}
