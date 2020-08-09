import 'package:flutter/material.dart';

class SeenStatus extends StatelessWidget {
  final int status;

  const SeenStatus(this.status);
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
            color: Theme.of(context).primaryColor,
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
            color: Theme.of(context).primaryColor,
            size: 15,
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.only(
            right: 5.0,
          ),
          child: Icon(Icons.access_alarm,
              color: Theme.of(context).primaryColor, size: 15),
        );
      default:
        return Container();
    }
  }
}
