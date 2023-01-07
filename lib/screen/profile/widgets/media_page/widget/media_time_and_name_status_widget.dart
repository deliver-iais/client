import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MediaTimeAndNameStatusWidget extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  final String createdBy;
  final int createdOn;
  final String roomUid;

  const MediaTimeAndNameStatusWidget({
    Key? key,
    required this.createdBy,
    required this.createdOn,
    required this.roomUid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FutureBuilder<String>(
          future: _roomRepo.getName(
              (roomUid.asUid().isChannel() ? roomUid : createdBy).asUid()),
          builder: (c, name) {
            if (name.hasData && name.data != null) {
              return Text(
                name.data!,
                overflow: TextOverflow.fade,
                style: theme.textTheme.bodyText2!.copyWith(color: Colors.white),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          DateTime.fromMillisecondsSinceEpoch(
            createdOn,
          ).toString().substring(0, 19),
          style: theme.textTheme.bodyText2!
              .copyWith(height: 1, color: Colors.white),
        )
      ],
    );
  }
}
