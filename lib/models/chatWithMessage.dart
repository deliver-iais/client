import 'package:deliver_flutter/db/database.dart';
import 'package:flutter/material.dart';

class ChatWithMessage {
  final Chat chat;
  final Message lastMessage;

  ChatWithMessage({@required this.chat, @required this.lastMessage});
}
