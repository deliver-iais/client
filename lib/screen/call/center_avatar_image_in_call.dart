import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CenterAvatarInCall extends StatefulWidget {
  final Uid roomUid;
  final double radius;

  const CenterAvatarInCall({
    super.key,
    required this.roomUid,
    this.radius = 70,
  });

  @override
  CenterAvatarInCallState createState() => CenterAvatarInCallState();
}

class CenterAvatarInCallState extends State<CenterAvatarInCall> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _uxService = GetIt.I.get<UxService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FutureBuilder<String>(
          future: _roomRepo.getName(widget.roomUid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                textAlign: TextAlign.center,
                snapshot.data!,
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: Colors.white),
              );
            } else {
              return const Text("");
            }
          },
        ),
        const SizedBox(
          height: 15,
        ),
        Material(
          elevation: 5,
          color: theme.colorScheme.outline.withOpacity(0.6),
          shadowColor: theme.colorScheme.outline.withOpacity(0.6),
          borderRadius: BorderRadius.circular(widget.radius),
          child: StreamBuilder<String>(
            stream: _avatarRepo.getLastAvatarFilePathStream(widget.roomUid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return CircleAvatarWidget(widget.roomUid, widget.radius);
              } else {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(
                            _uxService.getCorePalette().tertiary.get(
                                  _uxService.themeIsDark ? 60 : 80,
                                ),
                          ),
                          Color(
                            _uxService.getCorePalette().primary.get(
                                  _uxService.themeIsDark ? 60 : 80,
                                ),
                          ),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white60,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
