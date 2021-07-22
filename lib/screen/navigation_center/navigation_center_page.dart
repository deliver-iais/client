import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';

import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatsPage.dart';
import 'package:deliver_flutter/screen/contacts/contacts_page.dart';
import 'package:deliver_flutter/services/audioPlayerAppBar.dart';
import 'package:deliver_flutter/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';

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
  final ScrollController scrollController = ScrollController();

  final Function tapOnCurrentUserAvatar;

  var _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  var _routingService = GetIt.I.get<RoutingService>();
  var _botRepo = GetIt.I.get<BotRepo>();
  bool _searchMode = false;

  String query;

  BehaviorSubject<String> subject = new BehaviorSubject<String>();

  @override
  void initState() {
    subject.stream.debounceTime(Duration(milliseconds: 250)).listen((text) {
      setState(() {
        query = text;
      });
    });
    super.initState();
  }

  _NavigationCenterState(this.tapOnSelectChat, this.tapOnCurrentUserAvatar);

  @override
  Widget build(BuildContext context) {
    var _i18n = I18N.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: GestureDetector(
            onTap: () {
              scrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    child: Container(
                      child: Center(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: CircleAvatarWidget(
                            _authRepo.currentUserUid,
                            20,
                            showAsStreamOfAvatar: true,
                          ),
                        ),
                      ),
                    ),
                    onTap: tapOnCurrentUserAvatar,
                  ),
                ],
              ),
              titleSpacing: 8.0,
              title: StreamBuilder<TitleStatusConditions>(
                  stream: _messageRepo.updatingStatus.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data == TitleStatusConditions.Normal) {
                      return buildText(context);
                    } else if (snapshot.data ==
                        TitleStatusConditions.Updating) {
                      return Text(_i18n.get("updating"),
                          style: TextStyle(
                              fontSize: 20,
                              color:
                                  Theme.of(context).textTheme.headline2.color));
                    } else if (snapshot.data ==
                        TitleStatusConditions.Connecting) {
                      return Text(
                          _i18n.get("connecting"),
                          style: TextStyle(
                              fontSize: 20,
                              color:
                                  Theme.of(context).textTheme.headline2.color));
                    } else if (snapshot.hasData &&
                        snapshot.data == TitleStatusConditions.Disconnected) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          buildText(context),
                          SizedBox(
                            width: 7,
                          ),
                          Text(_i18n.get("disconnect"),
                              style: TextStyle(fontSize: 16, color: Colors.red))
                        ],
                      );
                    } else {
                      return buildText(context);
                    }
                  }),
              actions: [
                if (!isDesktop())
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ExtraTheme.of(context).menuIconButton,
                    ),
                    child: IconButton(
                        onPressed: () {
                          _routingService.openScanQrCode();
                        },
                        icon: Icon(
                          Icons.qr_code,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )),
                  ),
                SizedBox(
                  width: 8,
                ),
                buildMenu(context),
                SizedBox(
                  width: 8,
                )
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SearchBox(onChange: (str) {
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
            }, onCancel: () {
              setState(() {
                _searchMode = false;
              });
            }),
          ),
          AudioPlayerAppBar(),
          _searchMode
              ? searchResult(_i18n)
              : Expanded(child: ChatsPage(scrollController: scrollController)),
        ],
      ),
    );
  }

  Text buildText(BuildContext context) {
    return Text(
      I18N.of(context).get("chats"),
      style: Theme.of(context).textTheme.headline2,
    );
  }

  Widget buildMenu(BuildContext context) {
    I18N appLocalization = I18N.of(context);
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ExtraTheme.of(context).menuIconButton,
        ),
        child: PopupMenuButton(
            color: ExtraTheme.of(context).popupMenuButton,
            icon: Icon(
              Icons.create,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onSelected: selectChatMenu,
            itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.group,
                            color:
                                ExtraTheme.of(context).popupMenuButtonDetails,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            appLocalization.get("newGroup"),
                            style: TextStyle(
                                fontSize: 15,
                                color: ExtraTheme.of(context)
                                    .popupMenuButtonDetails),
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
                          appLocalization.get("newChannel"),
                          style: TextStyle(
                              fontSize: 15,
                              color: ExtraTheme.of(context)
                                  .popupMenuButtonDetails),
                        )
                      ],
                    ),
                    value: "newChannel",
                  )
                ]));
  }

  selectChatMenu(String key) {
    switch (key) {
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

  Widget searchResult(I18N _i18n) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                          Text(_i18n
                              .get("global_search")),
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
                        Text(_i18n.get("bots")),
                        Container(
                            height: 200, child: searchResultWidget(bot, c))
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
            FutureBuilder<List<Uid>>(
                future: _roomRepo.searchInRoomAndContacts(query),
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
                          _i18n.get("local_search"),
                          style: TextStyle(
                              color: ExtraTheme.of(context).textDetails),
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
                future: _roomRepo.getName(uid),
                builder: (BuildContext c, AsyncSnapshot<String> snaps) {
                  if (snaps.hasData && snaps.data != null) {
                    return Text(
                      snaps.data,
                      style: TextStyle(
                        color: ExtraTheme.of(context).chatOrContactItemDetails,
                        fontSize: 18,
                      ),
                    );
                  } else {
                    return Text(
                      "unKnown",
                      style: TextStyle(
                        color: ExtraTheme.of(context).chatOrContactItemDetails,
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
