import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/shared/appbarPic.dart';
import 'package:deliver_flutter/shared/mucAppbarTitle.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class MucAppbar extends StatelessWidget {
  final String roomId;

  const MucAppbar({Key key, this.roomId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          ExtendedNavigator.of(context).pop();
        },
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              // AppbarPic(),
              SizedBox(
                width: 10,
              ),
              MucAppbarTitle(mucUid: roomId),
            ],
          ),
          IconButton(
            padding:
                const EdgeInsets.only(top: 4, left: 6, bottom: 4, right: 0),
            icon: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ExtraTheme.of(context).secondColor,
              ),
            ),
            onPressed: null,
          )
        ],
      ),
    );
  }
}
