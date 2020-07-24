import 'package:deliver_flutter/db/database.dart';
import 'package:flutter/material.dart';

class RoomWithMessage {
  final Room room;
  final Message lastMessage;

  RoomWithMessage({@required this.room, @required this.lastMessage});
}
