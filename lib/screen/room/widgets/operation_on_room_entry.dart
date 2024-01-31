import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
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
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:rxdart/rxdart.dart';

class OperationOnRoomEntry extends PopupMenuEntry<OperationOnRoom> {
  final bool isPinned;
  final Uid roomUid;
  final void Function(String)? onPinRoom;

  const OperationOnRoomEntry({
    super.key,
    required this.roomUid,
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
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();

  void onDeleteRoom(OperationOnRoom operationOnRoom) =>
      _roomRepo.getName(widget.roomUid).then((roomName) {
        showDialog(
          context: context,
          builder: (context) {
            return OnDeletePopupDialog(
              roomUid: widget.roomUid,
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
              onTap: () => widget.onPinRoom?.call(widget.roomUid.asString()),
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
                uid: widget.roomUid,
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
          future: _roomRepo.isRoomMuted(widget.roomUid.asString()),
          builder: (context, snapshot) {
            final isMuted = snapshot.data ?? true;
            return PopupMenuItem(
              onTap: () {
                isMuted
                    ? _roomRepo.unMute(widget.roomUid)
                    : _roomRepo.mute(widget.roomUid);
              },
              child: Row(
                children: [
                  Icon(
                    isMuted
                        ? CupertinoIcons.volume_up
                        : CupertinoIcons.volume_off,
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
        if (widget.roomUid.isChannel() || widget.roomUid.isGroup())
          FutureBuilder(
            future: _mucRepo.getCurrentUserRoleIsAdminOrOwner(widget.roomUid),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  (snapshot.data!.isOwner || snapshot.data!.isAdmin)) {
                return PopupMenuItem(
                  onTap: () => _showAddBotToMucDialog(),
                  child: Row(
                    children: [
                      const Icon(Icons.person_add),
                      const SizedBox(width: 8),
                      Text(
                        widget.roomUid.isChannel()
                            ? _i18n.get("add_bot_to_channel")
                            : _i18n.get("add_bot_to_group"),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        FutureBuilder<bool>(
          future: _mucRepo.currentUserIsMucOwner(widget.roomUid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (!snapshot.data!) {
                return PopupMenuItem(
                  onTap: () => onDeleteRoom(OperationOnRoom.DELETE_ROOM),
                  child: Row(
                    children: [
                      Icon(
                        widget.roomUid.isMuc()
                            ? CupertinoIcons.arrow_turn_up_left
                            : CupertinoIcons.delete,
                      ),
                      const SizedBox(width: p12),
                      Text(
                        !widget.roomUid.isMuc()
                            ? _i18n.get("delete_chat")
                            : _mucHelper.leftMucTitle(
                                widget.roomUid,
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
                          widget.roomUid,
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
        PopupMenuItem(
          onTap: () {
            _roomRepo.reportRoom(widget.roomUid);
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
        if (!widget.roomUid.isMuc())
          StreamBuilder<bool?>(
            stream: _roomRepo.watchIsRoomBlocked(widget.roomUid.asString()),
            builder: (c, s) {
              return PopupMenuItem(
                onTap: () => _roomRepo.block(
                  widget.roomUid.asString(),
                  block: !(s.data ?? false),
                ),
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

  void _showAddBotToMucDialog() {
    final names = <Uid, String>{};
    final bots = BehaviorSubject<List<Uid>>.seeded([]);

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
            title: Text(
              widget.roomUid.isChannel()
                  ? _i18n.get("add_bot_to_channel")
                  : _i18n.get("add_bot_to_group"),
            ),
            content: SizedBox(
              width: 350,
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                children: [
                  AutoDirectionTextField(
                    onChanged: (str) {
                      final searchRes = <Uid>[];
                      for (final uid in names.keys) {
                        if (names[uid]!.contains(str) || names[uid] == str) {
                          searchRes.add(uid);
                        }
                      }
                      bots.add(searchRes);
                    },
                    decoration: InputDecoration(
                      hintText: _i18n.get("search"),
                      prefixIcon: const Icon(Icons.search),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                  FutureBuilder<List<Room>>(
                    future: _roomRepo.getAllBots(),
                    builder: (c, mucSnapshot) {
                      if (mucSnapshot.hasData &&
                          mucSnapshot.data != null &&
                          mucSnapshot.data!.isNotEmpty) {
                        bots.add(mucSnapshot.data!.map((e) => e.uid).toList());

                        return StreamBuilder<List<Uid>>(
                          stream: bots,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return noGroupFoundWidget();
                              } else {
                                final filtereList = snapshot.data!;
                                return Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemBuilder: (c, i) {
                                      return GestureDetector(
                                        child: FutureBuilder<String>(
                                          future: _roomRepo.getName(
                                            filtereList[i],
                                          ),
                                          builder: (c, name) {
                                            if (name.hasData &&
                                                name.data != null) {
                                              names[filtereList[i]] =
                                                  name.data!;
                                              return SizedBox(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    CircleAvatarWidget(
                                                      filtereList[i],
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
                                          filtereList[i],
                                          names[filtereList[i]],
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
    Uid uid,
    String? botName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Icon(Icons.person_add),
          content: FutureBuilder<String>(
            future: _roomRepo.getName(widget.roomUid),
            builder: (c, name) {
              if (name.hasData && name.data != null && name.data!.isNotEmpty) {
                return Text(
                  "${_i18n.get("add")} $botName ${_i18n.get("to")} ${name.data}",
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

                final usersAddCode =
                    await _mucRepo.addMucMember(widget.roomUid, [uid]);
                if (usersAddCode == StatusCode.ok) {
                  basicNavigatorState.pop();
                  c1NavigatorState.pop();
                  _routingService.openRoom(
                    widget.roomUid,
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
