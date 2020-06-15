import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AppBarHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>(); 
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Row(
            children: <Widget>[
              Container(
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: ThemeColors.circleAvatarbackground,
                  child: FittedBox(
                    child: Icon(
                      Icons.person,
                      color: ThemeColors.circleAvatarIcon,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                currentPageService.currentPage == 0 ? "Chats" : "Contacts",
                style: Theme.of(context).textTheme.headline2,
              ),
            ],
          )),
    );
  }
}
