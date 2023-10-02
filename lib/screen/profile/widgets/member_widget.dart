import 'package:deliver/box/member.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class MucMemberWidget extends StatefulWidget {
  final Uid mucUid;
  final MucRole currentUserRole;

  const MucMemberWidget({
    super.key,
    required this.mucUid,
    required this.currentUserRole,
  });

  @override
  MucMemberWidgetState createState() => MucMemberWidgetState();
}

class MucMemberWidgetState extends State<MucMemberWidget> {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _mucHelper = GetIt.I.get<MucHelperService>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  static const String CHANGE_ROLE = "changeRole";
  static const String DELETE = "delete";
  static const String BAN = "ban";
  final TextEditingController _searchBoxController = TextEditingController();
  final _inSearchMode = BehaviorSubject.seeded(false);
  List<Member> _members = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Member>>(
      stream: _mucRepo.watchAllMembers(widget.mucUid),
      builder: (c, membersSnapshot) {
        if (membersSnapshot.hasData && membersSnapshot.data != null) {
          _members = membersSnapshot.data!;
          return Column(
            children: [
              SearchBox(
                controller: _searchBoxController,
                onChange: (c) {
                  _inSearchMode.add(true);
                },
                onCancel: () {
                  _inSearchMode.add(false);
                },
                onSearchEnd: () {
                  _inSearchMode.add(false);
                },
                onTap: () {
                  // _searchBoxAnimationController.forward();
                  // _searchMode.add(true);
                },
              ),
              StreamBuilder(
                initialData: false,
                stream: _inSearchMode.stream
                    .debounceTime(const Duration(milliseconds: 500)),
                builder: (c, inSearchMode) {
                  if (inSearchMode.hasData && (inSearchMode.data ?? false)) {
                    return FutureBuilder<List<Member>>(
                      future: _filterMembers(_searchBoxController.text),
                      builder: (c, filteredMembersSnapshot) {
                        if (filteredMembersSnapshot.hasData &&
                            filteredMembersSnapshot.data != null) {
                          return _buildMembersListView(
                            filteredMembersSnapshot.data!,
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    );
                  } else {
                    return _buildMembersListView(_members);
                  }
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMembersListView(List<Member> members) {
    return Expanded(
      child: ListView.separated(
        itemCount: members.length,
        itemBuilder: (c, i) {
          return _buildMemberWidget(
            members[i],
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }

  Future<List<Member>> _filterMembers(String term) async {
    final res = <Member>[];
    for (final member in _members) {
      final name = await _roomRepo.getName(member.memberUid);
      if (name.contains(term)) {
        res.add(member);
      }
    }
    return res;
  }

  Widget _buildMemberWidget(Member member) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _routingServices.openProfile(member.memberUid.asString());
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatarWidget(
              member.memberUid,
              18,
              key: Key(member.memberUid.asString()),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _roomRepo.getName(member.memberUid),
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextLoader(
                              text: Text(
                                snapshot.data ?? "".replaceAll('', '\u200B'),
                                style: (Theme.of(context).textTheme.titleSmall)!
                                    .copyWith(height: 1.3),
                                softWrap: false,
                              ),
                            ),
                            const SizedBox(height: 4),
                            showMemberRole(member),
                          ],
                        );
                      },
                    ),
                  ),
                  if (!_authRepo.isCurrentUser(member.memberUid) &&
                      (widget.currentUserRole == MucRole.ADMIN ||
                          widget.currentUserRole == MucRole.OWNER) &&
                      member.role != MucRole.OWNER)
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      itemBuilder: (_) => <PopupMenuItem<String>>[
                        if (!widget.mucUid.isBroadcast() &&
                            widget.currentUserRole == MucRole.OWNER)
                          PopupMenuItem<String>(
                            value: CHANGE_ROLE,
                            child: member.role == MucRole.MEMBER
                                ? Text(
                                    _i18n.get(
                                      "change_role_to_admin",
                                    ),
                                  )
                                : Text(
                                    _i18n.get(
                                      "change_role_to_member",
                                    ),
                                  ),
                          ),
                        PopupMenuItem<String>(
                          value: DELETE,
                          child: Text(_i18n.get("kick")),
                        ),
                        if (!widget.mucUid.isBroadcast())
                          PopupMenuItem<String>(
                            value: BAN,
                            child: Text(_i18n.get("ban")),
                          ),
                      ],
                      onSelected: (key) {
                        onSelected(key, member);
                      },
                    ),
                  if (_authRepo.isCurrentUser(
                            member.memberUid,
                          ) &&
                          (widget.currentUserRole == MucRole.ADMIN ||
                              widget.currentUserRole == MucRole.OWNER) ||
                      (widget.currentUserRole == MucRole.ADMIN &&
                          member.role == MucRole.OWNER))
                    const SizedBox(width: 40)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showMemberRole(Member member) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    switch (member.role) {
      case MucRole.OWNER:
        return Row(
          children: [
            Icon(Icons.star, size: 12, color: primaryColor),
            const SizedBox(width: 4),
            Text(
              _i18n.get("owner"),
              style: TextStyle(
                fontSize: 12,
                color: primaryColor,
              ),
            ),
          ],
        );
      case MucRole.ADMIN:
        return Text(
          _i18n.get("admin"),
          style: TextStyle(
            fontSize: 12,
            color: primaryColor,
          ),
        );
      case MucRole.MEMBER:
        return Text(
          widget.mucUid.category == Categories.CHANNEL
              ? _i18n.get("member")
              : "",
          style: const TextStyle(fontSize: 11),
        );
      case MucRole.NONE:
        return const Text("", style: TextStyle(fontSize: 11));
    }
  }

  void onSelected(String key, Member member) {
    switch (key) {
      case CHANGE_ROLE:
        Member m;
        if (member.role == MucRole.MEMBER) {
          m = Member(
            memberUid: member.memberUid,
            mucUid: member.mucUid,
            role: MucRole.ADMIN,
          );
        } else {
          m = Member(
            memberUid: member.memberUid,
            mucUid: member.mucUid,
            role: MucRole.MEMBER,
          );
        }

        _mucHelper.changeMucMemberRole(m);
        break;
      case DELETE:
        _mucHelper.kickMucMember(member);
        break;
      case BAN:
        _mucHelper.banMucMember(member);
        break;
    }
  }
}
