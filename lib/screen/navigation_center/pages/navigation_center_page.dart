import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/localSearchResult.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatsPage.dart';
import 'package:deliver_flutter/screen/app-contacts/widgets/contactsPage.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/screen/navigation_center/widgets/searchBox.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';

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

  var rootingServices = GetIt.I.get<RoutingService>();
  var contactRepo = GetIt.I.get<ContactRepo>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();

  final Function tapOnCurrentUserAvatar;

  List<UserAsContact> globalSearchResult = List();

  List<LocalSearchResult> localSearchResult = List();

  NavigationTabs tab = NavigationTabs.Chats;

  AppLocalization _appLocalization;

  var _roomRepo = GetIt.I.get<RoomRepo>();

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _routingService = GetIt.I.get<RoutingService>();
  bool _searchMode = false;

  String query;

  BehaviorSubject<String> subject = new BehaviorSubject<String>();

  @override
  void initState() {
    super.initState();
    subject.stream.debounceTime(Duration(milliseconds: 250)).listen((text) {
      setState(() {
        query = text;
      });
    });
  }

  _NavigationCenterState(this.tapOnSelectChat, this.tapOnCurrentUserAvatar);

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
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
                              _accountRepo.currentUserUid,
                              18,
                              showAsStreamOfAvatar: true,
                            ),
                          ),
                        ),
                        onTap: tapOnCurrentUserAvatar,
                      ),
                    ],
                  ),
                  title: StreamBuilder<TitleStatusConditions>(
                      stream: _messageRepo.updatingStatus.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data == TitleStatusConditions.Normal) {
                          return buildText(context);
                        } else if (snapshot.data ==
                            TitleStatusConditions.Updating) {
                          return Text(
                              _appLocalization.getTraslateValue("connecting"),
                              style: TextStyle(fontSize: 20));
                        } else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              buildText(context),
                              SizedBox(
                                width: 7,
                              ),
                              Text(
                                  _appLocalization
                                      .getTraslateValue("disconnect"),
                                  style: TextStyle(fontSize: 16,color: Theme.of(context).primaryColor ))
                            ],
                          );
                        }
                      }),
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
                  SearchBox(
                    onChange: (str) {
                      if (str.length > 0) {
                        setState(() {
                          _searchMode = true;
                        });
                        subject.add(str);
                      } else {
                        setState(() {
                          _searchMode = false;
                        });
                      }
                    },
                  ),
                  _searchMode
                      ? searchResult()
                      : Expanded(
                          child: (tab == NavigationTabs.Chats)
                              ? ChatsPage(key: ValueKey("ChatsPage"))
                              : ContactsPage(key: ValueKey("ContactsPage"))),
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

  Text buildText(BuildContext context) {
    return Text(
      data(),
      style: Theme.of(context).textTheme.headline2,
    );
  }

  String data() {
    return tab == NavigationTabs.Chats
        ? _appLocalization.getTraslateValue("chats")
        : _appLocalization.getTraslateValue("contacts");
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
                color: Theme.of(context).backgroundColor,
                icon: Icon(
                  Icons.create,
                  color: Colors.white,
                  size: 20,
                ),
                itemBuilder: (context) => [
                      if (kDebugMode)
                        PopupMenuItem(
                            child: RaisedButton(
                          color: Theme.of(context).backgroundColor,
                          child: Row(
                            children: [
                              Text(appLocalization.getTraslateValue("newChat")),
                            ],
                          ),
                          onPressed: () {
                            initialDataBase();
                            Navigator.pop(context);
                          },
                        )),
                      PopupMenuItem(
                          child: RaisedButton(
                        color: Theme.of(context).backgroundColor,
                        child: Row(
                          children: [
                            Text(appLocalization.getTraslateValue("newGroup")),
                          ],
                        ),
                        onPressed: () {
                          _routingService.openMemberSelection(isChannel: false);
                          Navigator.pop(context);
                        },
                      )),
                      PopupMenuItem(
                          child: RaisedButton(
                        color: Theme.of(context).backgroundColor,
                        onPressed: () {
                          _routingService.openMemberSelection(isChannel: true);
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Text(appLocalization.getTraslateValue("newChannel"))
                          ],
                        ),
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
                        onTap: () {
                          ExtendedNavigator.of(context)
                              .popAndPush(Routes.newContact);
                        },
                      )),
                    ]),
      ),
      onPressed: null,
    );
  }

  initialDataBase() {
    GetIt.I.get<MessageRepo>().sendTextMessage(randomUid(), '0');
  }

  Widget searchResult() {
    return Expanded(
      child: Column(
        children: [
          FutureBuilder<List<UserAsContact>>(
              future: contactRepo.searchUser(query),
              builder:
                  (BuildContext c, AsyncSnapshot<List<UserAsContact>> snaps) {
                if (snaps.data != null && snaps.data.length > 0) {
                  return Container(
                      child: Expanded(
                          child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                            _appLocalization.getTraslateValue("global_search")),
                        ListView.builder(
                          itemCount: snaps.data.length,
                          itemBuilder: (BuildContext ctxt, int index) =>
                              GestureDetector(
                            onTap: () {
                              rootingServices
                                  .openRoom(snaps.data[index].uid.asString());
                            },
                            child: _contactResultWidget(
                                uid: snaps.data[index].uid,
                                lastName: snaps.data[index].lastName,
                                firstName: snaps.data[index].firstName,
                                username: snaps.data[index].username,
                                context: c),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )));
                } else {
                  return SizedBox.shrink();
                }
              }),
          FutureBuilder<List<LocalSearchResult>>(
              future: _roomRepo.searchInRoomAndContacts(
                  query, tab == NavigationTabs.Chats ? true : false),
              builder: (BuildContext c,
                  AsyncSnapshot<List<LocalSearchResult>> snaps) {
                if (snaps.hasData &&
                    snaps.data != null &&
                    snaps.data.length > 0) {
                  return Container(
                      child: Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                    children: [
                      Text(_appLocalization.getTraslateValue("local_search")),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snaps.data.length,
                        itemBuilder: (BuildContext ctxt, int index) =>
                            GestureDetector(
                          onTap: () {
                            rootingServices
                                .openRoom(snaps.data[index].uid.asString());
                          },
                          child: _contactResultWidget(
                              uid: snaps.data[index].uid,
                              lastName: snaps.data[index].lastName,
                              firstName: snaps.data[index].firstName,
                              username: snaps.data[index].username,
                              context: c),
                        ),
                      )
                    ],
                  ))));
                } else {
                  return SizedBox.shrink();
                }
              })
        ],
      ),
    );
  }
}

Widget _contactResultWidget(
    {Uid uid,
    String firstName,
    String lastName,
    String username,
    BuildContext context}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatarWidget(uid != null ? uid : Uid.getDefault(), 23),
          SizedBox(
            width: 20,
          ),
          Text(
            "$firstName $lastName" ?? username,
            style: TextStyle(fontSize: 19),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      )
    ],
  );
}
