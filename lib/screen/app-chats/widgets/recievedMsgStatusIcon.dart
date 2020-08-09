import 'package:flutter/material.dart';

class ReceivedMsgIcon extends StatelessWidget {
  final bool status;

  const ReceivedMsgIcon(this.status);
  @override
  Widget build(BuildContext context) {
    return (status == false)
        ? Padding(
            padding: const EdgeInsets.only(
              right: 7.0,
              top: 2,
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: new BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          )
        : Container();
  }
}
