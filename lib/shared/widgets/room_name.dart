import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../constants.dart';

class RoomName extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  final Uid uid;
  final String? name;
  final TextStyle? style;

  const RoomName({Key? key, required this.uid, this.name, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<String>(
        future: getName(),
        builder: (context, snapshot) {
          var name = (snapshot.data ?? "");
          const maxNameLength = 28;
          if (name.length > maxNameLength) {
            name = name.substring(0, maxNameLength - 3) + "...";
          }
          return Row(
            children: [
              Text(
                name,
                style:
                    (style ?? theme.textTheme.subtitle2)!.copyWith(height: 1),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
              FutureBuilder<bool>(
                  future: _roomRepo.isVerified(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: (style ?? theme.textTheme.subtitle2)!
                                    .fontSize ??
                                15,
                            color: DELIVER_COLOR,
                          ));
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
            ],
          );
        });
  }

  Future<String> getName() async {
    if (name != null) {
      return name!;
    }

    return _roomRepo.getName(uid);
  }
}
