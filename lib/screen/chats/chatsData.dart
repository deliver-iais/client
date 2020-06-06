import 'package:deliver_flutter/screen/chats/models/message.dart';

import './models/conversation.dart';

class ChatsData {
  static List<Conversation> chatsList = [
    Conversation(
      0,
      Message(
        "hi1",
        DateTime.now(),
        false,
        true,
      ),
    ),
    Conversation(
      1,
      Message(
        "hi2",
        DateTime(2020, 5, 21),
        false,
        true,
      ),
    ),
    Conversation(
      2,
      Message(
        "hi3",
        DateTime(2020, 4, 21),
        false,
        true,
      ),
    ),
    Conversation(
      3,
      Message(
        "hi4",
        DateTime(2020, 5, 25),
        false,
        true,
      ),
    ),
    Conversation(
      4,
      Message(
        "hi5",
        DateTime(2020, 5, 1),
        false,
        true,
      ),
    ),
  ];
}
