import 'dart:async';

import 'package:deliver/box/role.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class MuteAndUnMuteRoomWidget extends StatefulWidget {
  final Uid roomUid;
  final Widget inputMessage;

  const MuteAndUnMuteRoomWidget({
    super.key,
    required this.roomUid,
    required this.inputMessage,
  });

  @override
  State<MuteAndUnMuteRoomWidget> createState() =>
      _MuteAndUnMuteRoomWidgetState();
}

class _MuteAndUnMuteRoomWidgetState extends State<MuteAndUnMuteRoomWidget> {
  final isMucAdminOrOwner = BehaviorSubject.seeded(false);
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final FocusNode _focusNode = FocusNode();
  late final StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamSubscription =
        _mucRepo.watchMuc(widget.roomUid).distinct().listen((muc) {
      if (muc != null) {
        isMucAdminOrOwner.add(
          muc.currentUserRole == MucRole.OWNER ||
              muc.currentUserRole == MucRole.ADMIN,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: isMucAdminOrOwner,
      builder: (c, s) {
        if (s.hasData && s.data!) {
          return widget.inputMessage;
        } else {
          return Focus(focusNode: _focusNode, child: buildStreamBuilder());
        }
      },
    );
  }

  Widget buildStreamBuilder() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: StreamBuilder<bool>(
        stream: _roomRepo.watchIsRoomMuted(widget.roomUid),
        builder: (context, isMuted) {
          if (isMuted.data != null) {
            return FutureBuilder<Room?>(
              future: _roomRepo.getRoom(widget.roomUid),
              builder: (c, room) {
                if (room.data != null) {
                  if (!room.data!.deleted) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        isMuted.data!
                            ? _i18n.get("un_mute")
                            : _i18n.get(
                                "mute",
                              ),
                      ),
                      onPressed: () {
                        if (isMuted.data!) {
                          _roomRepo.unMute(widget.roomUid);
                        } else {
                          _roomRepo.mute(widget.roomUid);
                        }
                      },
                    );
                  } else {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        _i18n.get("join"),
                      ),
                      onPressed: () async {
                        await _mucRepo.joinChannel(
                          widget.roomUid,
                          "",
                        );
                        // TODO(bitbeter): This line of code is for rebuilding the future builder, but should be refactored!
                        _roomRepo
                          ..mute(widget.roomUid)
                          ..unMute(widget.roomUid);
                      },
                    );
                  }
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
