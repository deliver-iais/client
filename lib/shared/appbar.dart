import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/message_service.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'appbarTitle.dart';
import 'package:deliver_flutter/shared/appbarPic.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Appbar extends StatelessWidget {
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
              AppbarPic(),
              SizedBox(
                width: 10,
              ),
              AppbarTitle(),
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
              child: isHomePage(context)
                  ? PopupMenuButton(
                      icon: Icon(
                        Icons.create,
                        color: Colors.white,
                        size: 20,
                      ),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                child: GestureDetector(
                              child: Text("Add New Chat"),
                              onTap: () {
                                initialDataBase();
                              },
                            )),
                            PopupMenuItem(
                                child: GestureDetector(
                              child: Text("Go To Profile"),
                              onTap: () {
                                ExtendedNavigator.of(context)
                                    .push(Routes.profilePage);
                              },
                            )),
                            PopupMenuItem(
                                child: GestureDetector(
                              child: Text("New Group"),
                              onTap: () {},
                            )),
                            PopupMenuItem(
                                child: GestureDetector(
                              child: Text("New Channel"),
                              onTap: () {},
                            ))
                          ])
                  : PopupMenuButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                child: GestureDetector(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text("New Contact"),
                                ],
                              ),
                              onTap: () {},
                            )),
                          ]),
            ),
          )
        ],
      ),
    );
  }

  isHomePage(context) => RouteData.of(context).path == Routes.homePage;

  initialDataBase() {
    GetIt.I.get<MessageService>().sendFileMessage(randomUid(), 'test');
//    GetIt.I
//        .get<MessageService>()
//        .sendFileMessage('users:Judi', 'C:\\Users\\Fatemeh\\Desktop\\r.mp3');
  }
}

//TODO 3 tay akhar ؟؟
