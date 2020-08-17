import 'package:auto_route/auto_route.dart';
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text("New Group"),
                                        ],
                                      ),
                                      onTap: () {
                                        initialDataBase();

                                        /// todo
                                      },
                                    )),
                                    PopupMenuItem(
                                        child: GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text("New Channel"),
                                        ],
                                      ),
                                      onTap: () {
                                        // todo c
                                      },
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
                    onPressed: currentPageService.currentPage == 0
                        ? initialDataBase
                        : null,
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
    GetIt.I.get<MessageService>().sendTextMessage('users:Judi', 'test');
    // messageDao
    //     .insertMessage(MessagesCompanion(
    //       roomId: Value('users:Judi'),
    //       packetId: Value(2),
    //       time: Value(DateTime.now().subtract(Duration(days: 2))),
    //       from: Value('users:john'),
    //       to: Value('users:jain'),
    //       type: Value(MessageType.file),
    //       json: Value('{\"uuid\":\"File:a.png\",\"size\":' +
    //           Int64.parseInt('5000000').toString() +
    //           ',\"type\":\"image\",\"name\":\"a.png\",\"caption\":\"hi a\",\"width\":100,\"height\":100,\"duration\":0}'),
    //     ))
  }
}

//TODO 3 tay akhar ؟؟
