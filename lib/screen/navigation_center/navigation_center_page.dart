import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/has_call_row.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chats_page.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/splash/splash_screen.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/connection_status.dart';
import 'package:deliver/shared/widgets/out_of_date.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_size/window_size.dart';

BehaviorSubject<String> modifyRoutingByNotificationTapInBackgroundInAndroid =
    BehaviorSubject.seeded("");
BehaviorSubject<String> modifyRoutingByNotificationAcceptCallInBackgroundInAndroid =
BehaviorSubject.seeded("");


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
  static final _sharedDao = GetIt.I.get<SharedDao>();

  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<String> _searchMode = BehaviorSubject.seeded("");
  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");

  @override
  void initState() {
    modifyRoutingByNotificationTapInBackgroundInAndroid.listen((event) {
      if (event.isNotEmpty) {
        _routingService.openRoom(event);
      }
    });
    modifyRoutingByNotificationAcceptCallInBackgroundInAndroid.listen((event) {
      if (event.isNotEmpty) {
        _routingService.openCallScreen(event.asUid(),isCallAccepted: true);
      }
    });

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
    final theme = Theme.of(context);
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: onWindowSizeChange,
      child: SizeChangedLayoutNotifier(
        child: Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
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
                    DescribedFeatureOverlay(
                      featureId: feature3,
                      tapTarget:
                          CircleAvatarWidget(_authRepo.currentUserUid, 20),
                      backgroundColor: Colors.indigo,
                      targetColor: Colors.indigoAccent,
                      title: const Text('You can go to setting'),
                      overflowMode: OverflowMode.extendBackground,
                      description: _featureDiscoveryDescriptionWidget(
                        isCircleAvatarWidget: true,
                        description:
                            "1. You can chang your profile in the setting\n2. You can sync your contact and start chat with one of theme \n3. You can chang app theme\n4. You can chang app",
                      ),
                      child: GestureDetector(
                        child: Center(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: CircleAvatarWidget(
                              _authRepo.currentUserUid,
                              20,
                            ),
                          ),
                        ),
                        onTap: () {
                          _routingServices.openSettings(popAllBeforePush: true);
                        },
                      ),
                    ),
                  ],
                ),
                titleSpacing: 8.0,
                title: Text(
                  _i18n.get("chats"),
                  style: theme.textTheme.headline6,
                  key: ValueKey(randomString(10)),
                ),
                actions: [
                  if (!isDesktop)
                    DescribedFeatureOverlay(
                      featureId: feature2,
                      tapTarget: const Icon(
                        CupertinoIcons.qrcode_viewfinder,
                      ),
                      backgroundColor: Colors.deepPurple,
                      targetColor: Colors.deepPurpleAccent,
                      title: const Text('You can scan QR Code'),
                      description: _featureDiscoveryDescriptionWidget(
                        description:
                            'for desktop app you can scan QR Code and login to your account',
                      ),
                      child: IconButton(
                        onPressed: () {
                          _routingService.openScanQrCode();
                        },
                        icon: const Icon(
                          CupertinoIcons.qrcode_viewfinder,
                        ),
                      ),
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
          body: RepaintBoundary(
            child: Column(
              children: <Widget>[
                const HasCallRow(),
                const ConnectionStatus(),
                RepaintBoundary(
                  child: SearchBox(
                    onChange: _queryTermDebouncedSubject.add,
                    onCancel: () => _queryTermDebouncedSubject.add(""),
                  ),
                ),
                if (!isLarge(context)) const AudioPlayerAppBar(),
                StreamBuilder<String>(
                  stream: _searchMode.stream,
                  builder: (c, s) {
                    if (s.hasData && s.data!.isNotEmpty) {
                      return searchResult(s.data!);
                    } else {
                      return Expanded(
                        child: ChatsPage(scrollController: _scrollController),
                      );
                    }
                  },
                ),
                _newVersionInfo(),
                _outOfDateWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool onWindowSizeChange(SizeChangedLayoutNotification notification) {
    if (isDesktop && !isWeb) {
      getWindowInfo().then((size) {
        _sharedDao.put(
          SHARED_DAO_WINDOWS_SIZE,
          '${size.frame.left}_${size.frame.top}_${size.frame.right}_${size.frame.bottom}',
        );
      });
    }
    return true;
  }

  Widget _outOfDateWidget() {
    return StreamBuilder<bool>(
      stream: outOfDateObject.stream,
      builder: (c, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data!) {
          showOutOfDateDialog(context);
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _newVersionInfo() {
    return StreamBuilder<NewerVersionInformation?>(
      stream: newVersionInformation.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.version.isNotEmpty) {
          Future.delayed(Duration.zero, () {
            showFloatingModalBottomSheet(
              context: context,
              enableDrag: false,
              isDismissible: false,
              builder: (c) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8, left: 24, right: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        "assets/animations/new_version.zip",
                        height: 200,
                      ),
                      Text(
                        _i18n.get("update_we"),
                        style: const TextStyle(fontSize: 25),
                      ),
                      Text(
                        "${_i18n.get(
                          "version",
                        )} ${snapshot.data!.version} - Size ${snapshot.data!.size}",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        snapshot.data!.description,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 19),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (var downloadLink in snapshot.data!.downloadLinks)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () {
                                launch(
                                  downloadLink.url,
                                );
                              },
                              child: Text(
                                downloadLink.label,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              _i18n.get("remind_me_later"),
                              style: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(c);
                            },
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ).ignore();
          });

          return const SizedBox.shrink();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget buildMenu(BuildContext context) {
    final theme = Theme.of(context);
    return DescribedFeatureOverlay(
      featureId: feature1,
      tapTarget: Icon(CupertinoIcons.plus, color: theme.colorScheme.onSurface),
      backgroundColor: Colors.blue,
      targetColor: Colors.lightBlueAccent,
      title: const Text('You can create new group and new channel'),
      description: _featureDiscoveryDescriptionWidget(
        description:
            'If you touch this icon you can create new channel or new group with the your contact',
      ),
      child: IconTheme(
        data: IconThemeData(
          size: (PopupMenuTheme.of(context).textStyle?.fontSize ?? 14) + 4,
          color: PopupMenuTheme.of(context).textStyle?.color,
        ),
        child: PopupMenuButton(
          icon: const Icon(
            CupertinoIcons.plus_app,
          ),
          onSelected: selectChatMenu,
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              child: Row(
                children: [
                  const Icon(CupertinoIcons.group),
                  const SizedBox(width: 8),
                  Text(_i18n.get("newGroup")),
                ],
              ),
              value: "newGroup",
            ),
            PopupMenuItem<String>(
              child: Row(
                children: [
                  const Icon(CupertinoIcons.news),
                  const SizedBox(width: 8),
                  Text(
                    _i18n.get("newChannel"),
                  )
                ],
              ),
              value: "newChannel",
            )
          ],
        ),
      ),
    );
  }

  void selectChatMenu(String key) {
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
    final theme = Theme.of(context);
    return Expanded(
      child: FutureBuilder<List<List<Uid>>>(
        future: searchUidList(query),
        builder: (c, snaps) {
          if (!snaps.hasData || snaps.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final global = snaps.data![0];
          final bots = snaps.data![1];
          final roomAndContacts = snaps.data![2];

          if (global.isEmpty && bots.isEmpty && roomAndContacts.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TGS.asset(
                  'assets/animations/not-found.tgs',
                  width: 180,
                  height: 150,
                ),
                Text(
                  _i18n.get("not_found"),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline6,
                ),
              ],
            );
          }

          return ListView(
            children: [
              if (global.isNotEmpty) buildTitle(_i18n.get("global_search")),
              if (global.isNotEmpty) ...searchResultWidget(global),
              if (bots.isNotEmpty) buildTitle(_i18n.get("bots")),
              if (bots.isNotEmpty) ...searchResultWidget(bots),
              if (roomAndContacts.isNotEmpty)
                buildTitle(_i18n.get("local_search")),
              if (roomAndContacts.isNotEmpty)
                ...searchResultWidget(roomAndContacts),
            ],
          );
        },
      ),
    );
  }

  Widget buildTitle(String title) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      width: double.infinity,
      color: theme.dividerColor.withAlpha(10),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: theme.primaryTextTheme.caption,
      ),
    );
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
                _roomRepo.createRoomIfNotExist(uidList[index].asString());
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

  Widget _contactResultWidget({
    required Uid uid,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            CircleAvatarWidget(uid, 24),
            const SizedBox(
              width: 20,
            ),
            FutureBuilder<String>(
              future: _roomRepo.getName(uid),
              builder: (c, snaps) {
                return Text(
                  snaps.data ?? "",
                  style: theme.textTheme.subtitle1,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider()
      ],
    );
  }

  Widget _featureDiscoveryDescriptionWidget({
    required String description,
    bool isCircleAvatarWidget = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(description),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async =>
                      FeatureDiscovery.completeCurrentStep(context),
                  child: Text(
                    'Understood',
                    style:
                        theme.textTheme.button!.copyWith(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => FeatureDiscovery.dismissAll(context),
                  child: Text(
                    'Dismiss',
                    style:
                        theme.textTheme.button!.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            if (isAndroid && isCircleAvatarWidget)
              InkWell(
                onTap: () {
                  FeatureDiscovery.dismissAll(context);
                  _routingService.openContacts();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'sync contacts',
                      style: theme.textTheme.button!
                          .copyWith(color: Colors.lightGreenAccent),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.lightGreenAccent,
                    )
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
