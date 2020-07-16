import 'package:deliver_flutter/db/Messages.dart';
import 'package:deliver_flutter/models/chatWithMessage.dart';
import 'package:moor/moor.dart';

import '../Chats.dart';
import '../database.dart';
part 'ChatDao.g.dart';

@UseDao(tables: [Chats, Messages])
class ChatDao extends DatabaseAccessor<Database> with _$ChatDaoMixin {
  final Database db;
  ChatDao(this.db) : super(db);

  Stream watchAllChats() => select(chats).watch();

  Future insertChat(Chat newChat) => into(chats).insert(newChat);

  Future deleteChat(Chat chat) => delete(chats).delete(chat);

  Future updateChat(Chat updatedChat) => update(chats).replace(updatedChat);

  Stream getByContactId(String contactId) {
    return ((select(chats)
              ..orderBy([
                (c) =>
                    OrderingTerm(expression: c.chatId, mode: OrderingMode.desc)
              ])
              ..where((c) =>
                  c.sender.equals(contactId) | c.reciever.equals(contactId)))
            .join([
      innerJoin(
          messages,
          messages.id.equalsExp(chats.lastMessage) &
              messages.chatId.equalsExp(chats.chatId))
    ])
              ..orderBy([OrderingTerm.desc(messages.time)]))
        .watch()
        .map(
          (rows) => rows.map(
            (row) {
              return ChatWithMessage(
                chat: row.readTable(chats),
                lastMessage: row.readTable(messages),
              );
            },
          ).toList(),
        );
  }

  Stream getById(int id) {
    return (select(chats)..where((c) => c.chatId.equals(id))).watch();
  }
}
