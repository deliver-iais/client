import 'dart:convert';

import 'package:deliver_flutter/db/dao/GroupDao.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MucRepo {
  GroupDao _groupDao = GetIt.I.get<GroupDao>();
  MemberDao _memberDao = GetIt.I.get<MemberDao>();
  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
  RoomDao _roomDao = GetIt.I.get<RoomDao>();

  makeNewGroup(Uid groupUid, List<String> memberUids, String name) async {
    await _groupDao.insertGroup(Group(
        uid: groupUid.string, name: name, members: memberUids.length + 1));
    Room room = Room(roomId: groupUid.string, lastMessage: null);
    await _roomDao.insertRoom(room);

    await _memberDao.insertMember(Member(
        memberUid: _accountRepo.currentUserUid.string,
        mucUid: groupUid.string,
        role: Role.OWNER));

    for (var i = 0; i < memberUids.length; i++) {
      await _memberDao.insertMember(Member(
          memberUid: memberUids[i],
          mucUid: groupUid.string,
          role: Role.MEMBER));
    }
    MessageDao messageDao = GetIt.I.get<MessageDao>();
    int lastMessage = await messageDao.insertMessage(Message(
        roomId: groupUid.string,
        packetId: 14,
        time: DateTime.now(),
        from: _accountRepo.currentUserUid.string,
        to: groupUid.string,
        type: MessageType.PERSISTENT_EVENT,
        json: jsonEncode({"text": "You created the group"})));
    //TODO send to members
    //persistentEvenMessage structure

    await _roomDao.updateRoom(room.copyWith(lastMessage: lastMessage));
  }
}
//TODO
//number of online member
//send for members persistentEvent message
//emoji has bug
