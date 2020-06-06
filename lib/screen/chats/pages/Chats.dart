import 'package:deliver_flutter/screen/chats/models/conversation.dart';
import 'package:deliver_flutter/screen/chats/widgets/chatItem.dart';
import 'package:flutter/material.dart';


class ChatsList extends StatelessWidget {
  final List<Conversation> chats;

  const ChatsList(this.chats);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: chats.map((conversation) {
          return ChatItem(conversation: conversation);
        }).toList(),
      ),
    );
  }
}