import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatsPage.dart';
import 'package:deliver_flutter/screen/app-contacts/widgets/contactsPage.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/screen/navigation_center/widgets/searchBox.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

enum NavigationTabs { Chats, Contacts }

class NavigationCenter extends StatefulWidget {
  final void Function(String) tapOnSelectChat;

  final Function tapOnCurrentUserAvatar;

  const NavigationCenter(
      {Key key, this.tapOnSelectChat, this.tapOnCurrentUserAvatar})
      : super(key: key);

  @override
  _NavigationCenterState createState() =>
      _NavigationCenterState(this.tapOnSelectChat, this.tapOnCurrentUserAvatar);
}

class _NavigationCenterState extends State<NavigationCenter> {
  final void Function(String) tapOnSelectChat;

  final Function tapOnCurrentUserAvatar;

  NavigationTabs tab = NavigationTabs.Chats;

  var accountRepo = GetIt.I.get<AccountRepo>();
  var routingService = GetIt.I.get<RoutingService>();

  _NavigationCenterState(this.tapOnSelectChat, this.tapOnCurrentUserAvatar);

  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
    AppLocalization appLocalization = AppLocalization.of(context);
    return StreamBuilder<bool>(
        stream: audioPlayerService.isOn,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(snapshot.data == true ? 100 : 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: AppBar(
                  elevation: 0,
                  leading: Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                        child: Container(
                          child: Center(
                            child: CircleAvatarWidget(
                              accountRepo.currentUserUid,
                              accountRepo.currentUsername,
                              18,
                              showAsStreamOfAvatar: true,
                            ),
                          ),
                        ),
                        onTap: tapOnCurrentUserAvatar,
                      ),
                    ],
                  ),
                  title: Text(
                    tab == NavigationTabs.Chats
                        ? appLocalization.getTraslateValue("chats")
                        : appLocalization.getTraslateValue("contacts"),
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  actions: [
                    buildMenu(context),
                    SizedBox(
                      width: 16,
                    )
                  ],
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: <Widget>[
                  SearchBox(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 150),
                      child: (tab == NavigationTabs.Chats)
                          ? ChatsPage(key: ValueKey("ChatsPage"))
                          : ContactsPage(key: ValueKey("ContactsPage")),
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: Theme.of(context).backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildIconButton(
                      context, Icons.question_answer, NavigationTabs.Chats),
                  SizedBox(
                    width: 20,
                  ),
                  buildIconButton(
                      context, Icons.people, NavigationTabs.Contacts),
                ],
              ),
            ),
          );
        });
  }

  IconButton buildIconButton(
      BuildContext context, IconData icon, NavigationTabs assignedTab) {
    return IconButton(
        icon: Icon(
          icon,
          color: assignedTab == tab
              ? ExtraTheme.of(context).active
              : ExtraTheme.of(context).details,
          size: 28,
        ),
        onPressed: () {
          if (assignedTab != tab) {
            setState(() {
              tab = assignedTab;
            });
          }
        });
  }

  IconButton buildMenu(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return IconButton(
      padding: const EdgeInsets.only(top: 4, left: 6, bottom: 4, right: 0),
      icon: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ExtraTheme.of(context).secondColor,
        ),
        child: tab == NavigationTabs.Chats
            ? PopupMenuButton(
                icon: Icon(
                  Icons.create,
                  color: Colors.white,
                  size: 20,
                ),
                itemBuilder: (context) => [
                      if (kDebugMode)
                        PopupMenuItem(
                            child: GestureDetector(
                          child:
                              Text(appLocalization.getTraslateValue("newChat")),
                          onTap: () {
                            initialDataBase();
                          },
                        )),
                      if (kDebugMode)
                        PopupMenuItem(
                            child: GestureDetector(
                          child: Text("Go to Profile"),
                          onTap: () {
                            routingService.openProfile(
                                accountRepo.currentUserUid.getString());
                          },
                        )),
                      if (kDebugMode)
                        PopupMenuItem(
                            child: GestureDetector(
                          child: Text("Go to Group"),
                          onTap: () {
                            var fakeGroupUid = Uid()
                              ..category = Categories.Group
                              ..node = "123123";
                            routingService
                                .openProfile(fakeGroupUid.getString());
                          },
                        )),
                      PopupMenuItem(
                          child: GestureDetector(
                        child:
                            Text(appLocalization.getTraslateValue("newGroup")),
                        onTap: () {
                          // ExtendedNavigator.of(context)
                          //     .push(Routes.memberSelectionPage);
                        },
                      )),
                      PopupMenuItem(
                          child: GestureDetector(
                        child: Text(
                            appLocalization.getTraslateValue("newChannel")),
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
                        child: Text(
                            appLocalization.getTraslateValue("newContact")),
                        onTap: () {},
                      )),
                    ]),
      ),
      onPressed: null,
    );
  }

  initialDataBase() {
    GetIt.I
        .get<MessageRepo>()
        .sendTextMessage(randomUid(), 'hello welcome to our app');
  }
}
