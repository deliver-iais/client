import 'package:deliver/box/muc.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
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
    });
  });
}
