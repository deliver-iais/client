import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
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
    print('hi');
    var currentPageService = GetIt.I.get<CurrentPageService>();
    print('currentPage : ' + currentPageService.currentPage.toString());
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
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
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
                        color: ExtraTheme
                            .of(context)
                            .secondColor,
                      ),
                      child: Icon(
                         currentPageService.currentPage == 0
                            ? Icons.create
                            : Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    onPressed: () {
                      {
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(100, 30, 20, 100),
                          items: [
                            PopupMenuItem(
                                child: GestureDetector(
                                    onTap: () {
                                      ExtendedNavigator.of(context).pushNamed(
                                          Routes.settingsPage);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Text("New Contact")
                                      ],
                                    )
                                )),
                            PopupMenuItem<String>(
                                child:GestureDetector(
                                    onTap: () {
                                      ExtendedNavigator.of(context).pushNamed(
                                          Routes.settingsPage);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Text("New Group")
                                      ],
                                    )
                                ) ),
                            PopupMenuItem<String>(
                                child: GestureDetector(
                                    onTap: () {
                                      ExtendedNavigator.of(context).pushNamed(
                                          Routes.settingsPage);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Text("New Channel ")
                                      ],
                                    )
                                )),

                          ],
                          elevation: 8.0,
                        );
                      }
                    },
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
}
