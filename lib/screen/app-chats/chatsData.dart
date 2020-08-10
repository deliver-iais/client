import 'package:deliver_flutter/models/message.dart';

import 'package:deliver_flutter/models/conversation.dart';

class ChatsData {
  static List<Conversation> chatsList = [
    Conversation(
      0,
      SentMessage(
        "hi1",
        DateTime(2020, 2, 21),
        0,
      ),
      false,
    ),
    Conversation(
      1,
      SentMessage(
        "hi2",
        DateTime(2020, 5, 21),
        1,
      ),
      true,
    ),
    Conversation(
      2,
      SentMessage(
        "hi3",
        DateTime(2020, 5, 27),
        2,
      ),
      true,
    ),
    Conversation(
      3,
      ReceivedMessage(
        "hi4",
        DateTime(2020, 3, 25),
        false,
      ),
      false,
    ),
    Conversation(
      4,
      ReceivedMessage(
        "hi5",
        DateTime(2020, 6, 27, 11, 8),
        true,
      ),
      false,
    ),
  ];
}
