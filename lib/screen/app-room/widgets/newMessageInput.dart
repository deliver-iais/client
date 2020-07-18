import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMessageInput extends StatefulWidget {
  final currentRoom;

  const NewMessageInput({Key key, this.currentRoom}) : super(key: key);
  @override
  _NewMessageInputState createState() => _NewMessageInputState();
}

class _NewMessageInputState extends State<NewMessageInput> {
  TextEditingController controller;
  String loggedinUserId;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
    _getLoggedinUserId();
  }

  void _getLoggedinUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedinUserId = prefs.get("loggedinUserId");
  }

  @override
  Widget build(BuildContext context) {
    Room currentRoom = widget.currentRoom;
    var messageDao = GetIt.I.get<MessageDao>();
    var roomDao = GetIt.I.get<RoomDao>();
    return Container(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          color: ThemeColors.text,
        ),
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Message',
          hintStyle: TextStyle(
            color: ThemeColors.text,
          ),
          prefixIcon: IconButton(
            icon: Icon(
              Icons.mood,
              color: ThemeColors.text,
            ),
            onPressed: null,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: controller.text != ''
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).accentColor,
            ),
            onPressed: () {
              final newMessage = Message(
                  roomId: currentRoom.roomId,
                  id: currentRoom.lastMessage + 1,
                  time: DateTime.now(),
                  from: loggedinUserId,
                  to: currentRoom.sender == loggedinUserId
                      ? currentRoom.reciever
                      : currentRoom.sender,
                  edited: false,
                  encrypted: false,
                  type: MessageType.text,
                  content: controller.text,
                  seen: false);
              print(controller.text);
              messageDao.insertMessage(newMessage);
              currentRoom = currentRoom.copyWith(
                  lastMessage: currentRoom.lastMessage + 1);
              roomDao.updateRoom(currentRoom);
              controller.clear();
            },
          ),
        ),
      ),
    );
  }
}
