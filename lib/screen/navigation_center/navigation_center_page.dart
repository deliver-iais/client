import 'dart:ui';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chatsPage.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver/theme/extra_theme.dart';
import "package:universal_html/js.dart" as js;

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:random_string/random_string.dart';
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

  final _rootingServices = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _botRepo = GetIt.I.get<BotRepo>();

  final ScrollController _scrollController = ScrollController();
  final Function tapOnCurrentUserAvatar;
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: GestureDetector(
            onTap: () {
              _scrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: AppBar(
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
              title: TitleStatus(
                style: Theme.of(context).textTheme.headline6,
                normalConditionWidget: Text(I18N.of(context).get("chats"),
                    style: Theme.of(context).textTheme.headline6,
                    key: ValueKey(randomString(10))),
              ),
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
          if (!isLarge(context)) AudioPlayerAppBar(),
          _searchMode
              ? searchResult(_i18n)
              : Expanded(child: ChatsPage(scrollController: _scrollController)),
        ],
      ),
    );
  }

  Widget buildMenu(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ExtraTheme.of(context).menuIconButton,
        ),
        child: PopupMenuButton(
            icon: Icon(Icons.create),
            onSelected: selectChatMenu,
            itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.group),
                        SizedBox(width: 8),
                        Text(i18n.get("newGroup")),
                      ],
                    ),
                    value: "newGroup",
                  ),
                  PopupMenuItem<String>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.rss_feed_rounded),
                        SizedBox(width: 8),
                        Text(
                          i18n.get("newChannel"),
                        )
                      ],
                    ),
                    value: "newChannel",
                  )
                ])
    );
  }

  selectChatMenu(String key) {
    switch (key) {
      case "newGroup":
        showAddHomePageDialog(context);
     //  _routingService.openMemberSelection(isChannel: false);
        break;
      case "newChannel":
        _routingService.openMemberSelection(isChannel: true);
        break;
    }
  }

  Widget searchResult(I18N _i18n) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder<List<Uid>>(
                future: _contactRepo.searchUser(query),
                builder: (BuildContext c, AsyncSnapshot<List<Uid>> snaps) {
                  if (snaps.data != null && snaps.data.length > 0) {
                    return Container(
                        child: Expanded(
                            child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(_i18n.get("global_search")),
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
                          style: Theme.of(context).primaryTextTheme.caption,
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
      itemBuilder: (BuildContext ctx, int index) {
        return GestureDetector(
          onTap: () {
            _roomRepo.insertRoom(snaps.data[index].asString());
            _rootingServices.openRoom(snaps.data[index].asString());
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
                  return Text(
                    snaps.data ?? "",
                    style: Theme.of(context).textTheme.subtitle1,
                  );
                }),
          ],
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Future<bool> showAddHomePageDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Icon(
                      Icons.add_circle,
                      size: 70,
                      color: Theme.of(context).primaryColor,
                    )),
                SizedBox(height: 20.0),
                Text(
                  'Add to Homepage',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Want to add this application to home screen?',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                    onPressed: () async{
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        final _isWebDialogShownKey = "is-web-dialog-shown";
                      //  final _isWebDialogShown = _prefs.getBool(_isWebDialogShownKey) ?? false;
                        if (true) {
                          final bool isDeferredNotNull =
                          js.context.callMethod("isDeferredNotNull") as bool;

                          if (isDeferredNotNull) {
                            debugPrint(">>> Add to HomeScreen prompt is ready.");
                            await showAddHomePageDialog(context);
                           // _prefs.setBool(_isWebDialogShownKey, true);
                          } else {
                            debugPrint(">>> Add to HomeScreen prompt is not ready yet.");
                          }
                        }
                      });
                    },
                    child: Text("Yes!"))
              ],
            ),
          ),
        );
      },
    );
  }
}