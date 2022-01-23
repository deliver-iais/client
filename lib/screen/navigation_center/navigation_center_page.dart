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
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';

class NavigationCenter extends StatefulWidget {
  const NavigationCenter({Key? key}) : super(key: key);

  @override
  _NavigationCenterState createState() => _NavigationCenterState();
}

class _NavigationCenterState extends State<NavigationCenter> {
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _contactRepo = GetIt.I.get<ContactRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _botRepo = GetIt.I.get<BotRepo>();

  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<String> _searchMode = BehaviorSubject.seeded("");
  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");

  @override
  void initState() {
    _queryTermDebouncedSubject.stream
        .debounceTime(const Duration(milliseconds: 250))
        .listen((text) => _searchMode.add(text));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchMode.close();
    _queryTermDebouncedSubject.close();
    super.dispose();
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
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0.0,
                  curve: Curves.easeOut,
                  duration: ANIMATION_DURATION * 3,
                );
              }
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
                        child: CircleAvatarWidget(_authRepo.currentUserUid, 20),
                      ),
                    ),
                    onTap: () {
                      _routingServices.openSettings(popAllBeforePush: true);
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
                          _routingService.openScanQrCode();
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
      body: RepaintBoundary(
        child: Column(
          children: <Widget>[
            RepaintBoundary(
              child: SearchBox(
                  onChange: _queryTermDebouncedSubject.add,
                  onCancel: () => _queryTermDebouncedSubject.add("")),
            ),
            if (!isLarge(context)) AudioPlayerAppBar(),
            StreamBuilder<String>(
                stream: _searchMode.stream,
                builder: (c, s) {
                  if (s.hasData && s.data!.isNotEmpty) {
                    return searchResult(s.data!);
                  } else {
                    return Expanded(
                        child: ChatsPage(scrollController: _scrollController));
                  }
                })
          ],
        ),
      ),
    );
  }

  Widget buildMenu(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ExtraTheme.of(context).menuIconButton,
        ),
        child: IconTheme(
          data: IconThemeData(
            size: (PopupMenuTheme.of(context).textStyle?.fontSize ?? 14) + 4,
            color: PopupMenuTheme.of(context).textStyle?.color,
          ),
          child: PopupMenuButton(
              icon: Icon(Icons.create,
                  color: Theme.of(context).colorScheme.onSurface),
              onSelected: selectChatMenu,
              itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.group),
                          const SizedBox(width: 8),
                          Text(_i18n.get("newGroup")),
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
                            _i18n.get("newChannel"),
                          )
                        ],
                      ),
                      value: "newChannel",
                    )
                  ]),
        ));
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

  Widget searchResult(String query) {
    return Expanded(
        child: FutureBuilder<List<List<Uid>>>(
            future: searchUidList(query),
            builder: (BuildContext c, AsyncSnapshot<List<List<Uid>>> snaps) {
              if (!snaps.hasData || snaps.data!.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final global = snaps.data![0];
              final bots = snaps.data![1];
              final roomAndContacts = snaps.data![2];

              if (global.isEmpty && bots.isEmpty && roomAndContacts.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const TGS.asset(
                      'assets/animations/not-found.tgs',
                      width: 180,
                      height: 150,
                      repeat: true,
                    ),
                    Text(_i18n.get("not_found"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6),
                  ],
                );
              }

              return ListView(children: [
                if (global.isNotEmpty) buildTitle(_i18n.get("global_search")),
                if (global.isNotEmpty) ...searchResultWidget(global),
                if (bots.isNotEmpty) buildTitle(_i18n.get("bots")),
                if (bots.isNotEmpty) ...searchResultWidget(bots),
                if (roomAndContacts.isNotEmpty)
                  buildTitle(_i18n.get("local_search")),
                if (roomAndContacts.isNotEmpty)
                  ...searchResultWidget(roomAndContacts),
              ]);
            }));
  }

  Widget buildTitle(String title) {
    return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 4),
        width: double.infinity,
        color: Theme.of(context).dividerColor.withAlpha(10),
        child: Text(title,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.caption));
  }

  Future<List<List<Uid>>> searchUidList(String query) async {
    return [
      await _contactRepo.searchUser(query),
      await _botRepo.searchBotByName(query),
      await _roomRepo.searchInRoomAndContacts(query)
    ];
  }

  List<Widget> searchResultWidget(List<Uid> uidList) {
    return List.generate(
      uidList.length,
      (index) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _roomRepo.insertRoom(uidList[index].asString());
                _routingServices.openRoom(uidList[index].asString());
              },
              child:
                  _contactResultWidget(uid: uidList[index], context: context),
            ),
          ),
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
            CircleAvatarWidget(uid, 24),
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
        const SizedBox(height: 8),
        const Divider()
      ],
    );
  }
}
