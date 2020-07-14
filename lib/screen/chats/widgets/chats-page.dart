import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/chats/chatsData.dart';
import 'package:deliver_flutter/screen/chats/widgets/chatItem.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: ChatsData.chatsList.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return GestureDetector(
              child: ChatItem(conversation: ChatsData.chatsList[index]),
              onTap: () {
                currentPageService.resetPage();
                NestedNavigator(
                  name: 'nestedNav',
                );
                ExtendedNavigator.byName('nestedNav').pushNamed("/chat:" + "");
              },
            );
          },
        ),
      ),
    );
  }
}
