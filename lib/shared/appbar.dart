import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/message_service.dart';
import 'package:deliver_flutter/shared/mainWidget.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'appbarTitle.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/shared/appbarPic.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Appbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    return Padding(
      padding: const EdgeInsets.all(0),
      child: AppBar(
        leading: currentPageService.currentPage == -1
            ? new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () {
                  currentPageService.setToHome();
                  ExtendedNavigator.of(context).pop();
                },
              )
            : null,
        backgroundColor: Theme.of(context).backgroundColor,
        title: MainWidget(
            Row(
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
                Container(
                  child: IconButton(
                    icon: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ExtraTheme.of(context).secondColor,
                      ),
                      child: currentPageService.currentPage == 0
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
                                        ExtendedNavigator.of(context).push(Routes.profilePage);
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text("New Contact"),
                                        ],
                                      ),
                                      onTap: () {
                                        // todo
                                      },
                                    )),
                                  ]),
                    ),
                    iconSize: 38,
                  ),
                )
              ],
            ),
            5,
            3),
      ),
    );
  }

  initialDataBase() {
    GetIt.I.get<MessageService>().sendTextMessage('0:Judi', 'test');
  }
}

//TODO 3 tay akhar ؟؟
