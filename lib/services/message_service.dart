import 'package:deliver_flutter/db/database.dart';
import 'package:random_string/random_string.dart';

class MessageService {
  Future<Message> sendMessage(Message message) async {
    await Future.delayed(Duration(seconds: 5));
    return message.copyWith(id: int.parse(randomNumeric(5)));
  }
}
