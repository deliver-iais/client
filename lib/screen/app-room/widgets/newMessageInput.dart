import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/inputMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//TODO empty text click on arrow
class NewMessageInput extends StatefulWidget {
  final String currentRoomId;

  const NewMessageInput({Key key, this.currentRoomId}) : super(key: key);

  @override
  _NewMessageInputState createState() => _NewMessageInputState();
}

class _NewMessageInputState extends State<NewMessageInput> {
  TextEditingController controller;

  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();

  @override
  Widget build(BuildContext context) {
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder<Room>(
        stream: roomDao.getByRoomId(widget.currentRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Room currentRoom = snapshot.data;
            return InputMessage(
              currentRoom: currentRoom,
            );
          } else {
            return Text("No Such a Room");
          }
        });
  }
}
