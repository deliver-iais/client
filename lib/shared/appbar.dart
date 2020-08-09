import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/shared/mainWidget.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:fimber/fimber.dart';
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
    Fimber.e("some");
    var messageDao = GetIt.I.get<MessageDao>();
    var roomDao = GetIt.I.get<RoomDao>();
    messageDao
        .insertMessage(Message(
          roomId: 26,
          id: 81,
          time: DateTime.now().subtract(Duration(days: 4)),
          from: '1111111111111111111115',
          to: '1111111111111111111111',
          edited: false,
          encrypted: false,
          type: MessageType.photo,
          content: 'https://tiltshiftmaker.com/photos/small/bamboo-small.jpg',
          seen: false,
        ))
        .then((value) => roomDao
            .insertRoom(Room(
                roomId: 26,
                sender: '1111111111111111111111',
                reciever: '1111111111111111111115',
                lastMessage: value))
            .catchError(null))
        .catchError(null);
  }
}
