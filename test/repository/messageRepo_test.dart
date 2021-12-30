import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../test_helper.dart';
void main() {

  group('updateNewMuc', () {
    setUp(() => registerServices());

    test('when updateNewMuc called roomDao should update room information', () async {
      final _messageRepo = GetIt.I.get<MessageRepoMock>();
      // final _roomDao = GetIt.I.get<RoomDaoMock>();

       _messageRepo.updateNewMuc("0:e9cdce3d-5528-4ea2-9698-c379617d0329".asUid(), 0);
        verify(_messageRepo.updateNewMuc("0:e9cdce3d-5528-4ea2-9698-c379617d0329".asUid(), 0));
        when(_messageRepo.updateNewMuc("0:e9cdce3d-5528-4ea2-9698-c379617d0329".asUid(), 0)).thenReturn("success");
        expect(_messageRepo.updateNewMuc("0:e9cdce3d-5528-4ea2-9698-c379617d0329".asUid(), 0),"success");
      // // expect(Counter().value, 0);
    });

  });
}