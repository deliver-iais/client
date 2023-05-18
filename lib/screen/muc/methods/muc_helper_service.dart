import 'package:deliver/box/member.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';

enum MucCategories { CHANNEL, GROUP, BROADCAST, NONE }

class MucHelperService {
  final I18N _i18n = GetIt.I.get<I18N>();
  final MucRepo _mucRepo = GetIt.I.get<MucRepo>();

  String createNewMucTitle(MucCategories mucCategories) {
    switch (mucCategories) {
      case MucCategories.CHANNEL:
        return _i18n.get("new_channel");
      case MucCategories.GROUP:
        return _i18n.get("new_group");
      case MucCategories.BROADCAST:
        return _i18n.get("new_broadcast");
      case MucCategories.NONE:
        return "";
    }
  }

  void changeMucMemberRole(Member member) {
    switch (member.mucUid.asUid().asMucCategories()) {
      case MucCategories.CHANNEL:
        _mucRepo.changeChannelMemberRole(member);
      case MucCategories.GROUP:
        _mucRepo.changeGroupMemberRole(member);
      case MucCategories.BROADCAST:
      case MucCategories.NONE:
        break;
    }
  }

  Future<bool> kickMucMember(Member member) {
    switch (member.mucUid.asUid().asMucCategories()) {
      case MucCategories.CHANNEL:
        return _mucRepo.kickChannelMember(member);
      case MucCategories.GROUP:
        return _mucRepo.kickGroupMember(member);
      case MucCategories.BROADCAST:
        return _mucRepo.kickBroadcastMember(member);
      case MucCategories.NONE:
        return Future.value(false);
    }
  }

  Future<void> banMucMember(Member member) {
    switch (member.mucUid.asUid().asMucCategories()) {
      case MucCategories.CHANNEL:
        return _mucRepo.banChannelMember(member);
      case MucCategories.GROUP:
        return _mucRepo.banGroupMember(member);
      case MucCategories.BROADCAST:
      case MucCategories.NONE:
        return Future.value();
    }
  }

  String enterNewMucNameTitle(MucCategories mucCategories) {
    switch (mucCategories) {
      case MucCategories.CHANNEL:
        return _i18n.get("enter_channel_name");
      case MucCategories.GROUP:
        return _i18n.get("enter_group_name");
      case MucCategories.BROADCAST:
        return _i18n.get("enter_broadcast_name");
      case MucCategories.NONE:
        return "";
    }
  }

  String enterNewMucDescriptionTitle(MucCategories mucCategories) {
    switch (mucCategories) {
      case MucCategories.CHANNEL:
        return _i18n.get("enter_channel_desc");
      case MucCategories.GROUP:
        return _i18n.get("enter_group_desc");
      case MucCategories.BROADCAST:
        return _i18n.get("enter_broadcast_desc");
      case MucCategories.NONE:
        return "";
    }
  }

  String deleteMucTitle(Uid mucUid) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return _i18n.get("delete_channel");
      case MucCategories.GROUP:
        return _i18n.get("delete_group");
      case MucCategories.BROADCAST:
        return _i18n.get("delete_broadcast");
      case MucCategories.NONE:
        return "";
    }
  }

  String leftMucTitle(Uid mucUid) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return _i18n.get("left_channel");
      case MucCategories.GROUP:
        return _i18n.get("left_group");
      case MucCategories.BROADCAST:
      case MucCategories.NONE:
        return "";
    }
  }

  String leftMucDescription(Uid mucUid, String roomName) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return "${_i18n.get("sure_left_channel1")} \"$roomName\" ${_i18n.get("sure_left_channel2")}";
      case MucCategories.GROUP:
        return "${_i18n.get("sure_left_group1")} \"$roomName\" ${_i18n.get("sure_left_group2")}";
      case MucCategories.BROADCAST:
      case MucCategories.NONE:
        return "";
    }
  }

  String deleteMucDescription(Uid mucUid, String roomName) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return "${_i18n.get("sure_left_group1")} \"$roomName\" ${_i18n.get("sure_left_group2")}";
      case MucCategories.GROUP:
        return "${_i18n.get("sure_delete_group1")} \"$roomName\" ${_i18n.get("sure_delete_group2")}";
      case MucCategories.BROADCAST:
        return "${_i18n.get("sure_left_broadcast1")} \"$roomName\" ${_i18n.get("sure_left_broadcast2")}";
      case MucCategories.NONE:
        return "";
    }
  }

  String newMucListOfMembersTitle(MucCategories mucCategories) {
    switch (mucCategories) {
      case MucCategories.CHANNEL:
        return _i18n.get("channel_members");
      case MucCategories.GROUP:
        return _i18n.get("group_members");
      case MucCategories.BROADCAST:
        return _i18n.get("we_recipients");
      case MucCategories.NONE:
        return "";
    }
  }

  String changeMucName(
    Uid mucUid, {
    bool isFirstPerson = false,
  }) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return _i18n.get("changed_channel_name");
      case MucCategories.GROUP:
        return _i18n.verb(
          "changed_group_name",
          isFirstPerson: isFirstPerson,
        );
      case MucCategories.BROADCAST:
        return _i18n.get("changed_broad_cast_name");
      case MucCategories.NONE:
        return "";
    }
  }

  String mucAppBarMemberTitle(Uid mucUid) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return _i18n.get("members_channel");
      case MucCategories.GROUP:
        return _i18n.get("members_group");
      case MucCategories.BROADCAST:
        return _i18n.get("members_broadcast");
      case MucCategories.NONE:
        return "";
    }
  }

  Future<Uid?> createNewMuc(
    List<Uid> memberUidList,
    MucCategories mucCategories,
    String name,
    String info, {
    String? channelId,
    Future<bool> Function(String)? checkChannelId,
    ChannelType? channelType,
  }) async {
    switch (mucCategories) {
      case MucCategories.GROUP:
        return _mucRepo.createNewGroup(
          memberUidList,
          name,
          info,
        );
      case MucCategories.BROADCAST:
        return _mucRepo.createNewBroadcast(
          memberUidList,
          name,
          info,
        );
      case MucCategories.CHANNEL:
        if (await checkChannelId?.call(channelId!) ?? false) {
          return _mucRepo.createNewChannel(
            channelId!,
            memberUidList,
            name,
            channelType!,
            info,
          );
        }
      case MucCategories.NONE:
        return null;
    }
    return null;
  }

  Future<void> modifyMuc(
    Uid mucUid,
    String name,
    String info, {
    String? channelId,
    Future<bool> Function(String)? checkChannelId,
    ChannelType? channelType,
  }) async {
    switch (mucUid.category) {
      case Categories.GROUP:
        return _mucRepo.modifyGroup(
          mucUid,
          name,
          info,
        );
      case Categories.BROADCAST:
        return _mucRepo.modifyBroadcast(
          mucUid,
          name,
          info,
        );
      case Categories.CHANNEL:
        if (await checkChannelId?.call(channelId!) ?? false) {
          return _mucRepo.modifyChannel(
            mucUid,
            name,
            channelId!,
            info,
            channelType!,
          );
        }
        break;
      case Categories.BOT:
      case Categories.STORE:
      case Categories.SYSTEM:
      case Categories.USER:
        return;
    }
  }

  Future<bool> leaveMuc(Uid mucUid) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return _mucRepo.leaveGroup(mucUid);
      case MucCategories.GROUP:
        return _mucRepo.leaveChannel(mucUid);
      case MucCategories.BROADCAST:
      case MucCategories.NONE:
        return Future.value(false);
    }
  }

  Future<bool> removeMuc(
    Uid mucUid,
  ) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return _mucRepo.removeChannel(mucUid);
      case MucCategories.GROUP:
        return _mucRepo.removeGroup(mucUid);
      case MucCategories.BROADCAST:
        return _mucRepo.removeBroadcast(mucUid);
      case MucCategories.NONE:
        return Future.value(false);
    }
  }

  int calculateMucPopulation(
    Uid mucUid,
    int population,
  ) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        return population;
      case MucCategories.GROUP:
        return population;
      case MucCategories.BROADCAST:
        return population - 1;
      case MucCategories.NONE:
        return 0;
    }
  }
}
