import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:flutter/material.dart';

class MediaTimeAndNameStatusWidget extends StatelessWidget {

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
        RoomName(
          uid: (roomUid.asUid().isChannel() ? roomUid : createdBy).asUid(),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          DateTime.fromMillisecondsSinceEpoch(
            createdOn,
          ).toString().substring(0, 19),
          style: theme.textTheme.bodyMedium!
              .copyWith(height: 1, color: Colors.white),
        )
      ],
    );
  }
}
