import 'package:deliver/box/broadcast_member.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

abstract class MucDao {
  Future<Muc?> get(Uid uid);

  Stream<Muc?> watch(Uid uid);

  Future<void> delete(Uid uid);

  Future<List<Muc>> getNitSyncedLocalMuc();

  Future<void> updateMuc({
    required Uid uid,
    String? info,
    List<int>? pinMessagesIdList,
    int? lastCanceledPinMessageId,
    int? population,
    String? id,
    String? token,
    String? name,
    bool? synced,
    MucType? mucType,
    MucRole? currentUserRole,
  });

  Future<List<BroadcastMember?>> getAllBroadcastSmsMembers(Uid mucUid);

  Future<List<Member>> getAllMembers(Uid mucUid);

  Future<List<Member>> getMembersFirstPage(Uid mucUid, int pageSize);

  Future<int> getBroadCastAllMemberCount(Uid mucUid);

  Stream<List<Member>> watchAllMembers(Uid mucUid);

  Future<void> saveMember(Member member);

  Future<void> saveSmsBroadcastContact(
    BroadcastMember broadcastMember,
    Uid uid,
  );

  Future<void> deleteMember(Member member);

  Future<void> deleteAllMembers(Uid mucUid);

  Future<Uid?> getLocalMucOwner(Uid uid);
}
