import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/widgets/dot_animation/dot_animation.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RoomName extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  final Uid uid;
  final String? name;
  final TextStyle? style;
  final bool shouldShowDotAnimation;

  const RoomName({
    super.key,
    required this.uid,
    this.name,
    this.style,
    this.shouldShowDotAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<String>(
      initialData: fastForwardGetName(),
      future: getName(),
      builder: (context, snapshot) {
        final name = (snapshot.data ?? "");
        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: TextLoader(
                Text(
                  name,
                  style:
                      (style ?? theme.textTheme.subtitle2)!.copyWith(height: 1),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                width: 120,
              ),
            ),
            if (shouldShowDotAnimation)
              DotAnimation(dotsColor: Theme.of(context).primaryColor),
            FutureBuilder<bool>(
              initialData: _roomRepo.fastForwardIsVerified(uid),
              future: _roomRepo.isVerified(uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      CupertinoIcons.checkmark_seal,
                      size:
                          ((style ?? theme.textTheme.subtitle2)?.fontSize ?? 14) + 2,
                      color: ACTIVE_COLOR,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            )
          ],
        );
      },
    );
  }

  Future<String> getName() {
    if (name != null && name!.isNotEmpty) {
      return Future.value(name);
    }

    return _roomRepo.getName(uid);
  }

  String? fastForwardGetName() {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }

    return _roomRepo.fastForwardName(uid);
  }
}
