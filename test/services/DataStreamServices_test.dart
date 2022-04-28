import 'package:deliver/box/member.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/models/message_event.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
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
      group('_onMessageEdited -', () {
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
        test(
            'When called if message type is  MessageManipulationPersistentEvent_Action.EDITED should getMessage from messageDao',
            () async {
          final messageDao = getAndRegisterMessageDao();
          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(
            messageDao.getMessage(testUid.asString(), 0),
          );
        });
        test(
            'When called if message type is  MessageManipulationPersistentEvent_Action.EDITED should getMessage from messageDao and if message is not null should fetchMessages',
            () async {
          final queryServiceClient = getAndRegisterQueryServiceClient(
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH,
            fetchMessagesHasOptions: false,
            fetchMessagesLimit: 1,
          );
          getAndRegisterMessageDao(message: testMessage);

          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(
            queryServiceClient.fetchMessages(
              FetchMessagesReq()
                ..roomUid = testUid
                ..limit = 1
                ..pointer = Int64()
                ..type = FetchMessagesReq_Type.FORWARD_FETCH,
            ),
          );
        });
        test(
            'When called if message type is  MessageManipulationPersistentEvent_Action.EDITED should getMessage from messageDao and if message is not null should fetchMessages',
            () async {
          final queryServiceClient = getAndRegisterQueryServiceClient(
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH,
            fetchMessagesHasOptions: false,
            fetchMessagesLimit: 1,
          );
          getAndRegisterMessageDao(message: testMessage);

          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(
            queryServiceClient.fetchMessages(
              FetchMessagesReq()
                ..roomUid = testUid
                ..limit = 1
                ..pointer = Int64()
                ..type = FetchMessagesReq_Type.FORWARD_FETCH,
            ),
          );
        });
        test(
            'When called if message type is  MessageManipulationPersistentEvent_Action.EDITED should getMessage from messageDao and if message is not null should getRoom',
            () async {
          final roomDao = getAndRegisterRoomDao();
          getAndRegisterQueryServiceClient(
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH,
            fetchMessagesHasOptions: false,
            fetchMessagesLimit: 1,
          );
          getAndRegisterMessageDao(message: testMessage);

          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(
            roomDao.getRoom(
              testUid.asString(),
            ),
          );
        });
        test(
            'When called if message type is  MessageManipulationPersistentEvent_Action.EDITED should add MessageEvent messageEventSubject',
            () async {
          final roomDao = getAndRegisterRoomDao(
            rooms: [
              Room(
                uid: testUid.asString(),
                lastMessage: testMessage.copyWith(id: 1),
              )
            ],
          );
          getAndRegisterQueryServiceClient(
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH,
            fetchMessagesHasOptions: false,
            fetchMessagesLimit: 1,
          );
          getAndRegisterMessageDao(message: testMessage);

          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(
            roomDao.updateRoom(
              uid: testUid.asString(),
              lastUpdateTime: 0,
            ),
          );
        });
        test(
            'When called if message type is  MessageManipulationPersistentEvent_Action.EDITED should update room',
            () async {
          getAndRegisterQueryServiceClient(
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH,
            fetchMessagesHasOptions: false,
            fetchMessagesLimit: 1,
          );
          getAndRegisterMessageDao(message: testMessage);

          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          expect(
            messageEventSubject.value,
            MessageEvent(
              testUid.asString(),
              0,
              0,
              MessageManipulationPersistentEvent_Action.EDITED,
            ),
          );
        });
      });
      group('_onMessageDeleted -', () {
        final message = Message(
          from: testUid,
          to: testUid,
          persistEvent: PersistentEvent(
            messageManipulationPersistentEvent:
                MessageManipulationPersistentEvent(
              action: MessageManipulationPersistentEvent_Action.DELETED,
              messageId: Int64(2),
            ),
          ),
        );
        test(
            'When called if message type is  MessageManipulationPersistentEvent_Action.DELETED should getMySeen',
            () async {
          final seenDao = getAndRegisterSeenDao();
          getAndRegisterMessageDao(getMessageId: 2);
          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(seenDao.getMySeen(testUid.asString()));
        });
        test(
            'When called if message type is MessageManipulationPersistentEvent_Action.DELETED should getMySeen and if 0 < mySeen.messageId && mySeen.messageId <= id increaseHiddenMessageCount',
            () async {
          getAndRegisterMessageDao(getMessageId: 2);
          final seenDao = getAndRegisterSeenDao(
            messageId: 1,
          );
          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(seenDao.getMySeen(testUid.asString()));
          verify(
            seenDao.updateMySeen(
              uid: testUid.asString(),
              hiddenMessageCount: 1,
            ),
          );
        });
        test(
            'When called if message type is MessageManipulationPersistentEvent_Action.DELETED should get message from message Dao',
            () async {
          final messageDao = getAndRegisterMessageDao(getMessageId: 2);
          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(messageDao.getMessage(testUid.asString(), 2));
        });
        test(
            'When called if message type is MessageManipulationPersistentEvent_Action.DELETED should get message and if message type file should delete media',
            () async {
          getAndRegisterMessageDao(
            getMessageId: 2,
            message: testMessage.copyWith(type: MessageType.FILE, id: 0),
          );
          final mediaDao = getAndRegisterMediaDao();
          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(mediaDao.deleteMedia(testUid.asString(), 0));
        });
        test(
            'When called if message type is MessageManipulationPersistentEvent_Action.DELETED should save a new message and get the room ',
            () async {
          final roomDao = getAndRegisterRoomDao();
          final messageDao = getAndRegisterMessageDao(
            getMessageId: 2,
            message: testMessage,
          );
          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(messageDao.saveMessage(testMessage.copyDeleted()));
          verify(roomDao.getRoom(testUid.asString()));
        });
        test(
            'When called should get the room and if room!.lastMessage != null && room.lastMessage!.id != id should update the room with new lastUpdateTime',
            () async {
          final roomDao = getAndRegisterRoomDao(
            rooms: [
              testRoom.copyWith(
                lastMessage: testMessage.copyWith(id: 1),
              ),
            ],
          );
          getAndRegisterMessageDao(
            getMessageId: 2,
            message: testMessage,
          );
          await DataStreamServices().handleIncomingMessage(
            message,
            isOnlineMessage: true,
          );
          verify(
            roomDao.updateRoom(uid: testUid.asString(), lastUpdateTime: 0),
          );
        });
      });
    });
    group('saveMessageInMessagesDB -', () {
      test('When called should saveMessage into messageDao', () async {
        final messageDao = getAndRegisterMessageDao();
        final message = Message(
          from: testUid,
          to: testUid,
          text: Text(text: "test"),
        );
        await DataStreamServices().saveMessageInMessagesDB(
          message,
        );
        verify(
          messageDao.saveMessage(
            testMessage.copyWith(
              id: 0,
              json: "{\"1\":\"test\"}",
              type: MessageType.TEXT,
              isHidden: false,
              packetId: "",
              forwardedFrom: "0:",
            ),
          ),
        );
      });
    });
    group('fetchLastNotHiddenMessage -', () {
      test('When called should getMessage from messageDao', () async {
        final messageDao = getAndRegisterMessageDao();
        final value = await DataStreamServices().fetchLastNotHiddenMessage(
          testUid,
          1,
          0,
        );
        verify(
          messageDao.getMessage(
            testUid.asString(),
            1,
          ),
        );
        expect(value, null);
      });
      test(
          'When called should getMessage from messageDao and if msg not be null and msg.id! <= firstMessageId || (msg.isHidden && msg.id == 1) should update the room with deleted=true',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterMessageDao(
          getMessageId: 1,
          message: testMessage.copyWith(
            id: 1,
            isHidden: true,
          ),
        );
        final value = await DataStreamServices().fetchLastNotHiddenMessage(
          testUid,
          1,
          0,
        );
        verify(
          roomDao.updateRoom(
            uid: testUid.asString(),
            deleted: true,
          ),
        );
        expect(value, null);
      });
      test(
          'When called should getMessage from messageDao and if msg not be hidden should return msg and update with new value',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterMessageDao(
          getMessageId: 1,
          message: testMessage.copyWith(
            id: 1,
          ),
        );
        final value = await DataStreamServices().fetchLastNotHiddenMessage(
          testUid,
          1,
          0,
        );
        verify(
          roomDao.updateRoom(
            uid: testUid.asString(),
            firstMessageId: 0,
            lastUpdateTime: 0,
            lastMessageId: 1,
            lastMessage: testMessage.copyWith(
              id: 1,
            ),
          ),
        );
        expect(
          value,
          testMessage.copyWith(
            id: 1,
          ),
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
