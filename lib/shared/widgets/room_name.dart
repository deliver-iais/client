import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/widgets/dot_animation/loading_dot_animation/loading_dot_animation.dart';
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
  final String? status;
  final int maxLines;
  final TextOverflow overflow;
  final bool forceToReturnSavedMessage;

  const RoomName({
    super.key,
    required this.uid,
    this.name,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.status,
    this.forceToReturnSavedMessage = false,
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
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: TextLoader(
                text: Text(
                  name.replaceAll('', '\u200B'),
                  style: (style ?? theme.textTheme.titleSmall)!
                      .copyWith(height: 1.5),
                  maxLines: maxLines,
                  softWrap: false,
                  overflow: overflow,
                ),
              ),
            ),
            if (status != null) ...[
              Text(
                " $status",
                style: style,
              ),
              LoadingDotAnimation(
                dotsColor: Theme.of(context).colorScheme.primary,
              )
            ],
            FutureBuilder<bool>(
              initialData: _roomRepo.fastForwardIsVerified(uid),
              future: _roomRepo.isVerified(uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(start: p4,bottom: 3),
                    child: Icon(
                      CupertinoIcons.checkmark_seal_fill,
                      size: ((style ?? theme.textTheme.titleSmall)?.fontSize ??
                          14),
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

    return _roomRepo.getName(
      uid,
      forceToReturnSavedMessage: forceToReturnSavedMessage,
    );
  }

  String? fastForwardGetName() {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }

    return _roomRepo.fastForwardName(uid);
  }
}
