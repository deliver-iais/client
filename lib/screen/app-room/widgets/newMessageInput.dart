import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMessageInput extends StatefulWidget {
  final int currentRoomId;

  const NewMessageInput({Key key, this.currentRoomId}) : super(key: key);
  @override
  _NewMessageInputState createState() => _NewMessageInputState();
}

class _NewMessageInputState extends State<NewMessageInput> {
  TextEditingController controller;
  String loggedInUserId;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
    _getloggedInUserId();
  }

  void _getloggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedInUserId = prefs.get("loggedInUserId");
  }

  @override
  Widget build(BuildContext context) {
    var messageDao = GetIt.I.get<MessageDao>();
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder<Room>(
        stream: roomDao.getById(widget.currentRoomId),
        builder: (context, snapshot) {
          Room currentRoom = snapshot.data;
          return Container(
            color: ExtraTheme.of(context).secondColor,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(
                  color: ExtraTheme.of(context).details,
                ),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.mood,
                    color: ExtraTheme.of(context).details,
                  ),
                  onPressed: null,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: controller.text != ''
                        ? Theme.of(context).primaryColor
                        : ExtraTheme.of(context).details,
                  ),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final newMessage = Message(
                          roomId: currentRoom.roomId,
                          id: currentRoom.lastMessage + 1,
                          time: DateTime.now(),
                          from: loggedInUserId,
                          to: currentRoom.sender == loggedInUserId
                              ? currentRoom.reciever
                              : currentRoom.sender,
                          edited: false,
                          encrypted: false,
                          type: MessageType.text,
                          content: controller.text,
                          seen: false);
                      messageDao.insertMessage(newMessage);
                      currentRoom = currentRoom.copyWith(
                          lastMessage: currentRoom.lastMessage + 1);
                      roomDao.updateRoom(currentRoom);
                      controller.clear();
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
