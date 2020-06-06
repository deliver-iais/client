import 'package:deliver_flutter/screen/app-home/widgets/appBarHome.dart';
import 'package:deliver_flutter/screen/app-home/widgets/navigationBar.dart';
import 'package:deliver_flutter/screen/app-home/widgets/searchBox.dart';
import 'package:deliver_flutter/screen/chats/chatsData.dart';
import 'package:deliver_flutter/screen/chats/pages/Chats.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        children: <Widget>[
          AppBarHome(),
          SearchBox(),
          Expanded(
            child: ChatsList(ChatsData.chatsList),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(),
    );
  }
}
