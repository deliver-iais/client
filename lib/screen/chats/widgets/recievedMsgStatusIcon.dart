import 'package:flutter/material.dart';

class RecievedMsgIcon extends StatelessWidget {
  final status;

  const RecievedMsgIcon(this.status);
  @override
  Widget build(BuildContext context) {
    return this.status == false
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
