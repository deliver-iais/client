import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
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

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

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

  NavigationTabs tab = NavigationTabs.Chats;

  AppLocalization _appLocalization;

  var _roomRepo = GetIt.I.get<RoomRepo>();

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _routingService = GetIt.I.get<RoutingService>();
  var _botRepo = GetIt.I.get<BotRepo>();
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
                              _appLocalization.getTraslateValue("updating"),
                              style: TextStyle(fontSize: 20, color: ExtraTheme.of(context).textDetails));
                        } else if (snapshot.data ==
                            TitleStatusConditions.Connecting) {
                          return Text(
                              _appLocalization.getTraslateValue("connecting"),
                              style: TextStyle(fontSize: 20, color: ExtraTheme.of(context).textDetails));
                        } else if (snapshot.hasData &&
                            snapshot.data ==
                                TitleStatusConditions.Disconnected) {
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
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: ExtraTheme.of(context).textDetails))
                            ],
                          );
                        } else {
                          return buildText(context);
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
              color: ExtraTheme.of(context).bottomNavigationAppbar,
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
              ? ExtraTheme.of(context).activePageIcon
              : ExtraTheme.of(context).inactivePageIcon,
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
          color: ExtraTheme.of(context).menuIconButton,
        ),
        child: tab == NavigationTabs.Chats
            ? PopupMenuButton(
                color: ExtraTheme.of(context).popupMenuButton,
                icon: Icon(
                  Icons.create,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: selectChatMenu,
                itemBuilder: (context) => [
                      // if (kDebugMode)
                      //   PopupMenuItem<String>(
                      //     child: Row(
                      //       children: [
                      //         Text(appLocalization.getTraslateValue("newChat")),
                      //       ],
                      //     ),
                      //     value: "newChat",
                      //   ),
                      PopupMenuItem<String>(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.group,
                                color: ExtraTheme.of(context).popupMenuButtonDetails,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                appLocalization.getTraslateValue("newGroup"),
                                style: TextStyle(fontSize: 15, color: ExtraTheme.of(context).popupMenuButtonDetails),
                              ),
                            ],
                          ),
                        ),
                        value: "newGroup",
                      ),
                      PopupMenuItem<String>(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              "assets/icons/channel_icon.png",
                              width: 25,
                              height: 25,
                              color: ExtraTheme.of(context).popupMenuButtonDetails,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              appLocalization
                                  .getTraslateValue("newChannel"),
                              style: TextStyle(fontSize: 15, color: ExtraTheme.of(context).popupMenuButtonDetails),
                            )
                          ],
                        ),
                        value: "newChannel",
                      )
                    ])
            : IconButton(
                color: ExtraTheme.of(context).popupMenuButton,
                onPressed: () {
                  _routingService.openCreateNewContactPage();
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ))));
  }

  selectChatMenu(String key) {
    switch (key) {
      case "newChat":
        initialDataBase();
        break;
      case "newGroup":
        _routingService.openMemberSelection(isChannel: false);
        break;
      case "newChannel":
        _routingService.openMemberSelection(isChannel: true);
        break;
    }
  }

  initialDataBase() {
    GetIt.I.get<MessageRepo>().sendTextMessage(randomUid(), '0');
  }

  Widget searchResult() {
    return Expanded(
      child: Column(
        children: [
          FutureBuilder<List<Uid>>(
              future: contactRepo.searchUser(query),
              builder: (BuildContext c, AsyncSnapshot<List<Uid>> snaps) {
                if (snaps.data != null && snaps.data.length > 0) {
                  return Container(
                      child: Expanded(
                          child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                            _appLocalization.getTraslateValue("global_search")),
                        //    searchResultWidget(snaps, c),
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
          FutureBuilder<List<Uid>>(
              future: _botRepo.searchBotByName(query),
              builder: (c, bot) {
                if (bot.hasData && bot.data != null && bot.data.length > 0) {
                  return Column(
                    children: [
                      Text(_appLocalization.getTraslateValue("bots")),
                      Container(height: 200, child: searchResultWidget(bot, c))
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
          FutureBuilder<List<Uid>>(
              future: _roomRepo.searchInRoomAndContacts(
                  query, tab == NavigationTabs.Chats ? true : false),
              builder: (BuildContext c, AsyncSnapshot<List<Uid>> snaps) {
                if (snaps.hasData &&
                    snaps.data != null &&
                    snaps.data.length > 0) {
                  return Container(
                      child: Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                    children: [
                      Text(
                        _appLocalization.getTraslateValue("local_search"),
                        style: TextStyle(color: ExtraTheme.of(context).textDetails),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        child: searchResultWidget(snaps, c),
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

  ListView searchResultWidget(AsyncSnapshot<List<Uid>> snaps, BuildContext c) {
    return ListView.builder(
      itemCount: snaps.data.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return GestureDetector(
          onTap: () {
            _roomRepo.insertRoom(snaps.data[index].asString());
            rootingServices.openRoom(snaps.data[index].asString());
          },
          child: _contactResultWidget(uid: snaps.data[index], context: c),
        );
      },
    );
  }

  Widget _contactResultWidget({Uid uid, BuildContext context}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatarWidget(uid != null ? uid : Uid.getDefault(), 23),
            SizedBox(
              width: 20,
            ),
            FutureBuilder(
                future: _roomRepo.getRoomDisplayName(uid),
                builder: (BuildContext c, AsyncSnapshot<String> snaps) {
                  if (snaps.hasData && snaps.data != null) {
                    return Text(
                      snaps.data,
                      style: TextStyle(
                        color: ExtraTheme.of(context).displayName,
                        fontSize: 18,
                      ),
                    );
                  } else {
                    return Text(
                      "unKnown",
                      style: TextStyle(
                        color: ExtraTheme.of(context).displayName,
                        fontSize: 18,
                      ),
                    );
                  }
                }),
          ],
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
