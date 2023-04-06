import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
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

  late final _globalKey = GlobalObjectKey(widget.roomUid.asString());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          key: _globalKey,
          elevation: 5,
          color: theme.colorScheme.outline.withOpacity(0.6),
          shadowColor: theme.colorScheme.outline.withOpacity(0.6),
          borderRadius: BorderRadius.circular(widget.radius),
          child: CircleAvatarWidget(
            widget.roomUid,
            widget.radius,
            noAvatarWidget: noAvatarWidget(),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        FutureBuilder<String>(
          future: _roomRepo.getName(widget.roomUid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                textAlign: TextAlign.center,
                snapshot.data!,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.white),
              );
            } else {
              return const Text("");
            }
          },
        ),
      ],
    );
  }

  Widget noAvatarWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: 140,
        height: 140,
        padding: const EdgeInsetsDirectional.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(
                settings.corePalette.tertiary.get(
                  settings.themeIsDark.value ? 60 : 75,
                ),
              ),
              Color(
                settings.corePalette.primary.get(
                  settings.themeIsDark.value ? 60 : 75,
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
}
