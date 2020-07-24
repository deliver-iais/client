import 'package:deliver_flutter/db/database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'messageBox.dart';

class ShowingMessagesFeild extends StatefulWidget {
  final String roomId;

  const ShowingMessagesFeild({Key key, this.roomId}) : super(key: key);

  @override
  _ShowingMessagesFeildState createState() => _ShowingMessagesFeildState();
}

class _ShowingMessagesFeildState extends State<ShowingMessagesFeild> {
  String loggedinUserId;

  @override
  void initState() {
    super.initState();
    _getLoggedinUserId();
  }

  void _getLoggedinUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedinUserId = prefs.get("loggedinUserId");
  }

  @override
  Widget build(BuildContext context) {
    var messageDao = GetIt.I.get<MessageDao>();
    double maxWidth = MediaQuery.of(context).size.width * 0.8;
    return Expanded(
      child: StreamBuilder<List<Message>>(
        stream: messageDao.getByRoomId(int.parse(widget.roomId)),
        builder: (context, snapshot) {
          final messages = snapshot.data ?? List();
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return MessageBox(
                loggedinUserId: loggedinUserId,
                message: messages[index],
                maxWidth: maxWidth,
              );
            },
          );
        },
      ),
    );
  }
}
