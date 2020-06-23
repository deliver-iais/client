import 'package:deliver_flutter/screen/chats/models/message.dart';

import './models/conversation.dart';

class ChatsData {
  static List<Conversation> chatsList = [
    Conversation(
      0,
      SendedMessage(
        "hi1",
        DateTime(2020, 2, 21),
        0,
      ),
      false,
    ),
    Conversation(
      1,
      SendedMessage(
        "hi2",
        DateTime(2020, 5, 21),
        1,
      ),
      true,
    ),
    Conversation(
      2,
      SendedMessage(
        "hi3",
        DateTime(2020, 4, 21),
        2,
      ),
      true,
    ),
    Conversation(
      3,
      RecievedMessage(
        "hi4",
        DateTime(2020, 3, 25),
        false,
      ),
      false,
    ),
    Conversation(
      4,
      RecievedMessage(
        "hi5",
        DateTime(2020, 6, 23, 11, 8),
        true,
      ),
      false,
    ),
  ];
}
