import 'dart:io';

import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';

//TODO empty text click on arrow
class NewMessageInput extends StatefulWidget {
  final int currentRoomId;

  const NewMessageInput({Key key, this.currentRoomId}) : super(key: key);
  @override
  _NewMessageInputState createState() => _NewMessageInputState();
}

class _NewMessageInputState extends State<NewMessageInput> {
  TextEditingController controller;

  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();
  String messageText = "";
  IconData icon = (Icons.panorama_fish_eye);

  List<File> galleryiImages = List<File>();

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  Widget showButtonSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ShareBox();
        });
  }

  @override
  Widget build(BuildContext context) {
    var messageDao = GetIt.I.get<MessageDao>();
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder<Room>(
        stream: roomDao.getById(widget.currentRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Room currentRoom = snapshot.data;
            return IconTheme(
              data: IconThemeData(color: Theme.of(context).accentColor),
              child: Container(
                  color: ExtraTheme.of(context).secondColor,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.mood,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      Flexible(
                        child: TextField(
                          minLines: 1,
                          maxLines: 15,
                          textInputAction: TextInputAction.send,
                          controller: controller,
                          onSubmitted: null,
                          onChanged: (str) {
                            setState(() {
                              messageText = str;
                            });
                          },
                          decoration:
                              InputDecoration.collapsed(hintText: " message"),
                        ),
                      ),
                      if (messageText?.isEmpty)
                        IconButton(
                            icon: Icon(
                              Icons.attach_file,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              showButtonSheet();
                            }),
                      IconButton(
                        icon: messageText?.isEmpty
                            ? Icon(Icons.keyboard_voice)
                            : Icon(Icons.send),
                        color: Colors.white,
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            final newMessage = Message(
                                roomId: currentRoom.roomId,
                                id: currentRoom.lastMessage + 1,
                                time: DateTime.now(),
                                from: "users:john",
                                to: "users:jain",
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
                            messageText = "";
                          }
                        },
                      ),
                    ],
                  )),
            );
          } else {
            return Text("No Such a Room");
          }
        });
  }
}
