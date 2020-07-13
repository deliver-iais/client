import 'package:deliver_flutter/shared/appbar.dart';
import 'package:deliver_flutter/screen/privateChat/widgets/newMessageFeild.dart';
import 'package:flutter/material.dart';

class PrivateChat extends StatefulWidget {
  @override
  _PrivateChatState createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Appbar(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          NewMessageFeild(),
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}

//TODO

//moor
//appbar = profile pic + name of contanct
// from bottom to up
//messages
//picture with url
//language of text
//type of message : image or text
//te
//rtl or ltr
//time
//text feild
//imoji
//send icon
