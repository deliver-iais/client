import 'package:deliver_flutter/db/database.dart';
import '../dao/MessageDao.dart';

class MessageRepo {
  MessageDao messageDao;

  deleteMessage(Message message) {
    messageDao.deleteMessage(message);
  }

  insertMessage(Message newMessage) {
    messageDao.insertMessage(newMessage);
  }

  updateMessage(Message updatedMessage) {
    messageDao.updateMessage(updatedMessage);
  }
}
