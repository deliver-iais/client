import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'appbarTitle.dart';
import 'package:deliver_flutter/shared/appbarPic.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';

class Appbar extends StatelessWidget {
  var accountRepo = GetIt.I.get<AccountRepo>();
  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return AppBar(
      leading: ExtendedNavigator.of(context).canPop() ? new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          ExtendedNavigator.of(context).pop();
        },
      ): null,
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
                              child: Text(
                                  appLocalization.getTraslateValue("newChat")),
                              onTap: () {
                                initialDataBase();
                              },
                            )),
                            PopupMenuItem(
                                child: GestureDetector(
                              child: Text(appLocalization
                                  .getTraslateValue("gotoProfile")),
                              onTap: () {
                                ExtendedNavigator.of(context).push(
                                    Routes.profilePage,
                                    arguments: ProfilePageArguments(
                                        userUid: accountRepo.currentUserUid));
                              },
                            )),
                        PopupMenuItem(
                            child: GestureDetector(
                              child: Text("Go to Group"),
                              onTap: () {
                                ExtendedNavigator.of(context).push(
                                    Routes.profilePage,
                                    arguments: ProfilePageArguments(
                                        userUid: Uid()..category = Categories.Group..node = "123123"));
                              },
                            )),
                            PopupMenuItem(
                                child: GestureDetector(
                              child: Text(
                                  appLocalization.getTraslateValue("newGroup")),
                              onTap: () {
                                ExtendedNavigator.of(context)
                                    .push(Routes.memberSelectionPage);
                              },
                            )),
                            PopupMenuItem(
                                child: GestureDetector(
                              child: Text(appLocalization
                                  .getTraslateValue("newChannel")),
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
                                  Text(appLocalization
                                      .getTraslateValue("newContact")),
                                ],
                              ),
                              onTap: () {},
                            )),
                          ]),
            ),
            onPressed: null,
          )
        ],
      ),
    );
  }

  isHomePage(context) => RouteData.of(context).path == Routes.homePage;

  initialDataBase() {
    GetIt.I
        .get<MessageRepo>()
        .sendTextMessage(randomUid(), 'hello welcome to our app');
  }
}
