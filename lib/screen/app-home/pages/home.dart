import 'package:deliver_flutter/screen/app-home/widgets/appBarHome.dart';
import 'package:deliver_flutter/screen/app-home/widgets/navigationBar.dart';
import 'package:deliver_flutter/screen/app-home/widgets/searchBox.dart';
import 'package:deliver_flutter/screen/chats/chatsData.dart';
import 'package:deliver_flutter/screen/chats/pages/Chats.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
