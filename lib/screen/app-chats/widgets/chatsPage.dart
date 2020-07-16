import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/ChatDao.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatItem.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatsPage extends StatelessWidget {
  final String loggedinUserId;

  const ChatsPage({Key key, @required this.loggedinUserId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    var chatDao = GetIt.I.get<ChatDao>();
    return StreamBuilder(
        stream: chatDao.getByContactId(loggedinUserId),
        builder: (context, snapshot) {
          final chats = snapshot.data ?? [];
          return Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return GestureDetector(
                    child: ChatItem(chatWithMessage: chats[index]),
                    onTap: () {
                      currentPageService.resetPage();
                      ExtendedNavigator.of(context).pushNamed(
                          Routes.privateChat(chatId: chats[index].chat.chatId));
                    },
                  );
                },
              ),
            ),
          );
        });
  }
}
