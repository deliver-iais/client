import 'package:deliver_flutter/screen/chats/chatsData.dart';
import 'package:deliver_flutter/screen/chats/models/conversation.dart';
import 'package:deliver_flutter/screen/chats/widgets/chatItem.dart';
import 'package:flutter/material.dart';

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: ChatsData.chatsList.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return ChatItem(conversation: ChatsData.chatsList[index]);
          },
        ),
      ),
    );
  }
}
