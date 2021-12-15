import 'dart:ui';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chats_page.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver/theme/extra_theme.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';

class NavigationCenter extends StatefulWidget {
  final void Function(String)? tapOnSelectChat;

  final Function? tapOnCurrentUserAvatar;

  const NavigationCenter(
      {Key? key, this.tapOnSelectChat, required this.tapOnCurrentUserAvatar})
      : super(key: key);

  @override
  _NavigationCenterState createState() => _NavigationCenterState();
}

class _NavigationCenterState extends State<NavigationCenter> {
  final _rootingServices = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _botRepo = GetIt.I.get<BotRepo>();

  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<bool> _searchMode = BehaviorSubject.seeded(false);

  String? query = "";

  BehaviorSubject<String> subject = BehaviorSubject<String>();

  @override
  void initState() {
    subject.stream
        .debounceTime(const Duration(milliseconds: 250))
        .listen((text) {
      query = text;
      _searchMode.add(true);
    });
    super.initState();
  }

  _NavigationCenterState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
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
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
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
                    onTap: () {
                      _rootingServices.openSettings(context: context);
                    },
                  ),
                ],
              ),
              titleSpacing: 8.0,
              title: TitleStatus(
                style: Theme.of(context).textTheme.headline6!,
                normalConditionWidget: Text(I18N.of(context)!.get("chats"),
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
                          _routingService.openScanQrCode(context);
                        },
                        icon: const Icon(
                          Icons.qr_code,
                        )),
                  ),
                const SizedBox(
                  width: 8,
                ),
                buildMenu(context),
                const SizedBox(
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
              if (str.isNotEmpty) {
                subject.add(str);
              } else {
                _searchMode.add(false);
              }
            }, onCancel: () {
              _searchMode.add(false);
            }),
          ),
          if (!isLarge(context)) AudioPlayerAppBar(),
          StreamBuilder<bool>(
              stream: _searchMode.stream,
              builder: (c, s) {
                if (s.hasData && s.data!) {
                  return searchResult();
                } else {
                  return Expanded(
                      child: ChatsPage(scrollController: _scrollController));
                }
              })
        ],
      ),
    );
  }

  I18N i18n = GetIt.I.get<I18N>();

  Widget buildMenu(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ExtraTheme.of(context).menuIconButton,
        ),
        child: PopupMenuButton(
            icon: const Icon(Icons.create),
            onSelected: selectChatMenu,
            itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.group),
                        const SizedBox(width: 8),
                        Text(i18n.get("newGroup")),
                      ],
                    ),
                    value: "newGroup",
                  ),
                  PopupMenuItem<String>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.rss_feed_rounded),
                        const SizedBox(width: 8),
                        Text(
                          i18n.get("newChannel"),
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
        _routingService.openMemberSelection(context, isChannel: false);
        break;
      case "newChannel":
        _routingService.openMemberSelection(context, isChannel: true);
        break;
    }
  }

  Widget searchResult() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder<List<Uid>>(
                future: _contactRepo.searchUser(query ?? ""),
                builder: (BuildContext c, AsyncSnapshot<List<Uid>> snaps) {
                  if (snaps.data != null && snaps.data!.isNotEmpty) {
                    return Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(_i18n.get("global_search")),
                          //    searchResultWidget(snaps, c),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ));
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
            FutureBuilder<List<Uid>>(
                future: _botRepo.searchBotByName(query!),
                builder: (c, bot) {
                  if (bot.hasData && bot.data != null && bot.data!.isNotEmpty) {
                    return Column(
                      children: [
                        Text(_i18n.get("bots")),
                        SizedBox(height: 200, child: searchResultWidget(bot, c))
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
            FutureBuilder<List<Uid>>(
                future: _roomRepo.searchInRoomAndContacts(query!),
                builder: (BuildContext c, AsyncSnapshot<List<Uid>> snaps) {
                  if (snaps.hasData &&
                      snaps.data != null &&
                      snaps.data!.isNotEmpty) {
                    return Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                      children: [
                        Text(
                          _i18n.get("local_search"),
                          style: Theme.of(context).primaryTextTheme.caption,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: searchResultWidget(snaps, c),
                        )
                      ],
                    )));
                  } else {
                    return const SizedBox.shrink();
                  }
                })
          ],
        ),
      ),
    );
  }

  ListView searchResultWidget(AsyncSnapshot<List<Uid>> snaps, BuildContext c) {
    return ListView.builder(
      itemCount: snaps.data!.length,
      itemBuilder: (BuildContext ctx, int index) {
        return GestureDetector(
          onTap: () {
            _roomRepo.insertRoom(snaps.data![index].asString());
            _rootingServices.openRoom(snaps.data![index].asString(),
                context: c);
          },
          child: _contactResultWidget(uid: snaps.data![index], context: c),
        );
      },
    );
  }

  Widget _contactResultWidget(
      {required Uid uid, required BuildContext context}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatarWidget(uid, 23),
            const SizedBox(
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
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
