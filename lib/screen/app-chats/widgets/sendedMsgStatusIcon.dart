import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class SendedMsgIcon extends StatelessWidget {
  final int status;

  const SendedMsgIcon(this.status);
  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 0:
        return Padding(
          padding: const EdgeInsets.only(
            right: 5.0,
          ),
          child: Icon(
            Icons.done,
            color: ExtraTheme.of(context).details,
            size: 15,
          ),
        );
      case 1:
        return Padding(
          padding: const EdgeInsets.only(
            right: 2.0,
          ),
          child: Icon(
            Icons.done_all,
            color: ExtraTheme.of(context).details,
            size: 15,
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.only(
            right: 5.0,
          ),
          child: Icon(
            Icons.access_alarm,
            color: ExtraTheme.of(context).details,
            size:15
          ),
        );
      default:
        return Container();
    }
  }
}
