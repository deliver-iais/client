import 'package:flutter/material.dart';

class OpenFileStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0),
      icon: Icon(
        Icons.insert_drive_file,
        size: 33,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: null,
    );
  }
}
