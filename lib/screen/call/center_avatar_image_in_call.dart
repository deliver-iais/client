import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/theme.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

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
  final _callRepo = GetIt.I.get<CallRepo>();

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
          child: Stack(
            alignment: Alignment.center,
            children: [
              StreamBuilder<Object>(
                stream: MergeStream([
                  _callRepo.incomingSpeakingAmplitude,
                  _callRepo.incomingAudioMuted,
                  _callRepo.isConnectedSubject,
                ]),
                builder: (context, snapshot) {
                  final amplitude =
                      _callRepo.incomingSpeakingAmplitude.value * 64.0;
                  final scale = (_callRepo.incomingAudioMuted.value ||
                          !_callRepo.isConnected)
                      ? 0.0
                      : 1.5 + ((amplitude / 128.0));
                  return AnimatedScale(
                    duration: AnimationSettings.fast,
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ACTIVE_COLOR.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(70),
                      ),
                      width: 100,
                      height: 100,
                    ),
                  );
                },
              ),
              CircleAvatarWidget(
                widget.roomUid,
                widget.radius,
                noAvatarWidget: noAvatarWidget(),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: StreamBuilder<bool>(
                  stream: MergeStream([
                    _callRepo.incomingAudioMuted,
                    _callRepo.isConnectedSubject,
                  ]),
                  builder: (context, snapshot) {
                    if (_callRepo.incomingAudioMuted.value &&
                        _callRepo.isConnectedSubject.value) {
                      return const CircleAvatar(
                        radius: 15,
                        child: Icon(
                          CupertinoIcons.mic_off,
                          size: 20,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
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
