import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

import 'chatsButton.dart';
import 'contactsButton.dart';

class NavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: ThemeColors.secondColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ChatsButton(),
          SizedBox(
            width: 20,
          ),
          ContactsButton(),
        ],
      ),
    );
  }
}
