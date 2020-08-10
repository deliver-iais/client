import 'package:deliver_flutter/models/message.dart';

class Conversation {
  final int contactId;
  final Message lastMessage;
  final bool mentioned;

  Conversation(this.contactId, this.lastMessage, this.mentioned);
}
