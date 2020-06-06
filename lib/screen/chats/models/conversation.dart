import 'package:deliver_flutter/screen/chats/models/message.dart';

class Conversation{
  final int contactId;
  final Message lastMessage;

  Conversation(this.contactId, this.lastMessage);
}