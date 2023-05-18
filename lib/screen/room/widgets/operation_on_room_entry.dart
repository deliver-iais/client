import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/screen/profile/widgets/on_delete_popup_dialog.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:rxdart/rxdart.dart';

class OperationOnRoomEntry extends PopupMenuEntry<OperationOnRoom> {
  final bool isPinned;
  final String roomId;
  final void Function(String)? onPinRoom;

  const OperationOnRoomEntry({
    super.key,
    required this.roomId,
    this.onPinRoom,
    this.isPinned = false,
  });

  @override
  OperationOnRoomEntryState createState() => OperationOnRoomEntryState();

  @override
  double get height => 100;

  @override
  bool represents(OperationOnRoom? value) {
    return false;
  }
}

class OperationOnRoomEntryState extends State<OperationOnRoomEntry> {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _roomDao = GetIt.I.get<RoomDao>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _mucHelper = GetIt.I.get<MucHelperService>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();

  void onDeleteRoom(OperationOnRoom operationOnRoom) =>
      _roomRepo.getName(widget.roomId.asUid()).then((roomName) {
        showDialog(
          context: context,
          builder: (context) {
            return OnDeletePopupDialog(
              roomUid: widget.roomId.asUid(),
              selected: operationOnRoom,
              roomName: roomName,
            );
          },
        );
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.onPinRoom != null)
          if (!widget.isPinned)
            PopupMenuItem(
              onTap: () => widget.onPinRoom?.call(widget.roomId),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.pin),
                  const SizedBox(width: p12),
                  Text(_i18n.get("pin_room")),
                ],
              ),
            )
          else
            PopupMenuItem(
              onTap: () => _roomDao.updateRoom(
                uid: widget.roomId.asUid(),
                pinned: false,
                pinId: 0,
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.pin_slash),
                  const SizedBox(width: p12),
                  Text(_i18n.get("unpin_room")),
                ],
              ),
            ),
        FutureBuilder<bool>(
          future: _roomRepo.isRoomMuted(widget.roomId),
          builder: (context, snapshot) {
            final isMuted = snapshot.data ?? true;
            return PopupMenuItem(
              onTap: () {
                isMuted
                    ? _roomRepo.unMute(widget.roomId.asUid())
                    : _roomRepo.mute(widget.roomId.asUid());
              },
              child: Row(
                children: [
                  Icon(
                    isMuted ? CupertinoIcons.bell : CupertinoIcons.bell_slash,
                  ),
                  const SizedBox(width: p12),
                  Text(
                    _i18n.get(
                      isMuted
                          ? "enable_notifications"
                          : "disable_notifications",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        FutureBuilder<bool>(
          future: _mucRepo.isMucOwner(
            _authRepo.currentUserUid.asString(),
            widget.roomId,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (!snapshot.data!) {
                return PopupMenuItem(
                  onTap: () => onDeleteRoom(OperationOnRoom.DELETE_ROOM),
                  child: Row(
                    children: [
                      Icon(
                        widget.roomId.asUid().isMuc()
                            ? CupertinoIcons.arrow_turn_up_left
                            : CupertinoIcons.delete,
                      ),
                      const SizedBox(width: p12),
                      Text(
                        !widget.roomId.asUid().isMuc()
                            ? _i18n.get("delete_chat")
                            : _mucHelper.leftMucTitle(
                                widget.roomId.asUid(),
                              ),
                      ),
                    ],
                  ),
                );
              } else {
                return PopupMenuItem(
                  onTap: () => onDeleteRoom(OperationOnRoom.DELETE_MUC_ROOM),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.delete),
                      const SizedBox(width: p12),
                      Text(
                        _mucHelper.deleteMucTitle(
                          widget.roomId.asUid(),
                        ),
                      ),
                    ],
                  ),
                );
              }
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        if (widget.roomId.isBot())
          PopupMenuItem(
            onTap: () => _showAddBotToGroupDialog(),
            child: Row(
              children: [
                const Icon(Icons.person_add),
                const SizedBox(width: 8),
                Text(
                  _i18n.get("add_to_group"),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          onTap: () {
            _roomRepo.reportRoom(widget.roomId.asUid());
            ToastDisplay.showToast(
              toastText: _i18n.get("report_result"),
              toastContext: context,
            );
          },
          child: Row(
            children: [
              const Icon(Icons.report),
              const SizedBox(width: 8),
              Text(
                _i18n.get("report"),
              ),
            ],
          ),
        ),
        if (!widget.roomId.isMuc())
          StreamBuilder<bool?>(
            stream: _roomRepo.watchIsRoomBlocked(widget.roomId),
            builder: (c, s) {
              return PopupMenuItem(
                onTap: () =>
                    _roomRepo.block(widget.roomId, block: !(s.data ?? false)),
                child: Row(
                  children: [
                    const Icon(Icons.block),
                    const SizedBox(width: 8),
                    Text(
                      s.data == null || !s.data!
                          ? _i18n.get("blockRoom")
                          : _i18n.get("unblock_room"),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddBotToGroupDialog() {
    final nameOfGroup = <String, String>{};
    final groups = BehaviorSubject<List<String>>.seeded([]);

    showDialog(
      context: context,
      builder: (c1) {
        return Focus(
          autofocus: true,
          child: AlertDialog(
            actions: [
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => Navigator.of(c1).pop(),
                child: Text(_i18n.get("cancel")),
              )
            ],
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            title: Text(_i18n.get("add_bot_to_group")),
            content: SizedBox(
              width: 350,
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                children: [
                  AutoDirectionTextField(
                    onChanged: (str) {
                      final searchRes = <String>[];
                      for (final uid in nameOfGroup.keys) {
                        if (nameOfGroup[uid]!.contains(str) ||
                            nameOfGroup[uid] == str) {
                          searchRes.add(uid);
                        }
                      }
                      groups.add(searchRes);
                    },
                    decoration: InputDecoration(
                      hintText: _i18n.get("search"),
                      prefixIcon: const Icon(Icons.search),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                  FutureBuilder<List<Room>>(
                    future: _roomRepo.getAllGroups(),
                    builder: (c, mucs) {
                      if (mucs.hasData &&
                          mucs.data != null &&
                          mucs.data!.isNotEmpty) {
                        final s = <String>[];
                        for (final room in mucs.data!) {
                          s.add(room.uid.asString());
                        }
                        groups.add(s);

                        return StreamBuilder<List<String>>(
                          stream: groups,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return noGroupFoundWidget();
                              } else {
                                final filteredGroupList = snapshot.data!;
                                return Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemBuilder: (c, i) {
                                      return GestureDetector(
                                        child: FutureBuilder<String>(
                                          future: _roomRepo.getName(
                                            filteredGroupList[i].asUid(),
                                          ),
                                          builder: (c, name) {
                                            if (name.hasData &&
                                                name.data != null) {
                                              nameOfGroup[
                                                      filteredGroupList[i]] =
                                                  name.data!;
                                              return SizedBox(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    CircleAvatarWidget(
                                                      filteredGroupList[i]
                                                          .asUid(),
                                                      20,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        name.data!,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          },
                                        ),
                                        onTap: () => _addBotToGroupButtonOnTab(
                                          context,
                                          c1,
                                          filteredGroupList[i],
                                          nameOfGroup[filteredGroupList[i]],
                                        ),
                                      );
                                    },
                                    itemCount: snapshot.data!.length,
                                  ),
                                );
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget noGroupFoundWidget() {
    return Expanded(child: Center(child: Text(_i18n.get("no_results"))));
  }

  void _addBotToGroupButtonOnTab(
    BuildContext context,
    BuildContext c1,
    String uid,
    String? mucName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Icon(Icons.person_add),
          content: FutureBuilder<String>(
            future: _roomRepo.getName(widget.roomId.asUid()),
            builder: (c, name) {
              if (name.hasData && name.data != null && name.data!.isNotEmpty) {
                return Text(
                  "${_i18n.get("add")} ${name.data} ${_i18n.get("to")} $mucName",
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_i18n.get("cancel")),
            ),
            TextButton(
              onPressed: () async {
                final basicNavigatorState = Navigator.of(context);
                final c1NavigatorState = Navigator.of(c1);

                final usersAddCode = await _mucRepo
                    .addMucMember(uid.asUid(), [widget.roomId.asUid()]);
                if (usersAddCode == StatusCode.ok) {
                  basicNavigatorState.pop();
                  c1NavigatorState.pop();
                  _routingService.openRoom(
                    uid,
                  );
                } else {
                  var message = _i18n.get("error_occurred");
                  if (usersAddCode == StatusCode.unavailable) {
                    message = _i18n.get("notwork_is_unavailable");
                  } else if (usersAddCode == StatusCode.permissionDenied ||
                      usersAddCode == StatusCode.internal) {
                    message = _i18n.get("permission_denied");
                  }
                  c1NavigatorState.pop();
                  if (context.mounted) {
                    ToastDisplay.showToast(
                      toastContext: context,
                      toastText: message,
                    );
                  }
                }
              },
              child: Text(_i18n.get("add")),
            ),
          ],
        );
      },
    );
  }
}
