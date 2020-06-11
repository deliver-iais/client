import 'package:deliver_flutter/screen/chats/models/conversation.dart';
import 'package:deliver_flutter/screen/chats/widgets/chatItem.dart';
import 'package:flutter/material.dart';

class Chats extends StatelessWidget {
  final List<Conversation> chats;

  const Chats(this.chats);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return ChatItem(conversation: chats[index]);
          },
        ),
      ),
    );
  }
}
//builder
