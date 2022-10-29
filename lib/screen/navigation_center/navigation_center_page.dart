import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/has_call_row.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chats_page.dart';
import 'package:deliver/screen/navigation_center/widgets/feature_discovery_description_widget.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/connection_status.dart';
import 'package:deliver/shared/widgets/out_of_date.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver/theme/theme.dart';
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

class CallNotificationActionInBackground {
  final String roomId;
  final bool isCallAccepted;

  CallNotificationActionInBackground({
    required this.roomId,
    required this.isCallAccepted,
  });
}

BehaviorSubject<CallNotificationActionInBackground?>
    modifyRoutingByCallNotificationActionInBackgroundInAndroid =
    BehaviorSubject.seeded(null);

class NavigationCenter extends StatefulWidget {
  const NavigationCenter({super.key});

  @override
  NavigationCenterState createState() => NavigationCenterState();
}

class NavigationCenterState extends State<NavigationCenter>
    with CustomPopupMenu {
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
  final TextEditingController _searchBoxController = TextEditingController();
  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");
  void Function()? _onNavigationCenterBackPressed;

  @override
  void initState() {
    modifyRoutingByNotificationTapInBackgroundInAndroid.listen((event) {
      if (event.isNotEmpty) {
        _routingService.openRoom(event);
      }
    });
    modifyRoutingByCallNotificationActionInBackgroundInAndroid.listen((event) {
      if (event?.roomId.isNotEmpty ?? false) {
        _routingService.openCallScreen(
          event!.roomId.asUid(),
          isCallAccepted: event.isCallAccepted,
        );
      }
    });

    _queryTermDebouncedSubject
        .debounceTime(const Duration(milliseconds: 250))
        .listen((text) => _searchMode.add(text));

    _routingService.registerPreMaybePopScope(
      "navigation_center_page",
      checkSearchBoxIsOpenOrNot,
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchBoxController.dispose();
    _scrollController.dispose();
    _searchMode.close();
    _queryTermDebouncedSubject.close();
    super.dispose();
  }

  NavigationCenterState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: onWindowSizeChange,
      child: SizeChangedLayoutNotifier(
        child: Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: _buildAppBar(),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: MouseRegion(
              hitTestBehavior: HitTestBehavior.translucent,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (e) => storePosition(e),
                child: FloatingActionButton(
                  heroTag: "navigation-center-fab",
                  onPressed: () {
                    this.showMenu(
                      context: context,
                      items: [
                        PopupMenuItem<String>(
                          key: const Key("newGroup"),
                          value: "newGroup",
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.group),
                              const SizedBox(width: 8),
                              Text(
                                _i18n.get("newGroup"),
                                style: theme.primaryTextTheme.bodyText2,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          key: const Key("newChannel"),
                          value: "newChannel",
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.news),
                              const SizedBox(width: 8),
                              Text(
                                _i18n.get("newChannel"),
                                style: theme.primaryTextTheme.bodyText2,
                              )
                            ],
                          ),
                        )
                      ],
                    ).then((value) => selectChatMenu(value ?? ""));
                  },
                  child: const Icon(Icons.add),
                ),
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
                    controller: _searchBoxController,
                  ),
                ),
                if (!isLarge(context)) const AudioPlayerAppBar(),
                StreamBuilder<String>(
                  stream: _searchMode,
                  builder: (c, s) {
                    if (s.hasData && s.data!.isNotEmpty) {
                      _onNavigationCenterBackPressed = () {
                        _queryTermDebouncedSubject.add("");
                        _searchBoxController.clear();
                      };
                      return searchResult(s.data!);
                    } else {
                      _onNavigationCenterBackPressed = null;
                      return Expanded(
                        child: ChatsPage(
                          scrollController: _scrollController,
                        ),
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

  bool checkSearchBoxIsOpenOrNot() {
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      return true;
    }
    if (_onNavigationCenterBackPressed != null) {
      _onNavigationCenterBackPressed?.call();
      return false;
    }
    return true;
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
      stream: _authRepo.outOfDateObject,
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
      stream: _authRepo.newVersionInformation,
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
                                launchUrl(Uri.parse(downloadLink.url));
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

  // Widget buildMenu(BuildContext context) {
  //   final theme = Theme.of(context);
  //   return DescribedFeatureOverlay(
  //     featureId: FEATURE_1,
  //     tapTarget: Icon(CupertinoIcons.plus, color: theme.colorScheme.onSurface),
  //     backgroundColor: theme.colorScheme.tertiaryContainer,
  //     targetColor: theme.colorScheme.tertiary,
  //     title: Text(
  //       _i18n.get("create_group_feature_discovery_title"),
  //       textDirection: _i18n.defaultTextDirection,
  //       style: TextStyle(
  //         color: theme.colorScheme.onTertiaryContainer,
  //       ),
  //     ),
  //     description: FeatureDiscoveryDescriptionWidget(
  //       description: _i18n.get("create_group_feature_description"),
  //       descriptionStyle: TextStyle(
  //         color: theme.colorScheme.onTertiaryContainer,
  //       ),
  //     ),
  //     child:
  //   );
  // }

  void selectChatMenu(String key) {
    switch (key) {
      case "newGroup":

        ToastDisplay.showToast(
          toastText: "rhgewlrhewirhwei;u",

        );

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
        builder: (c, snaps) {
          if (!snaps.hasData || snaps.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snaps.data![0];
          final global = snaps.data![1];
          final bots = snaps.data![2];
          final roomAndContacts = snaps.data![3];

          if (global.isEmpty && bots.isEmpty && roomAndContacts.isEmpty) {
            return const Tgs.asset(
              'assets/duck_animation/not_found.tgs',
            );
          }

          return ListView(
            children: [
              if (contacts.isNotEmpty) ...[
                buildTitle(_i18n.get("contacts")),
                ...searchResultWidget(contacts),
              ],
              if (roomAndContacts.isNotEmpty) ...[
                buildTitle(_i18n.get("local_search")),
                ...searchResultWidget(roomAndContacts)
              ],
              if (bots.isNotEmpty) ...[
                buildTitle(_i18n.get("bots")),
                ...searchResultWidget(bots)
              ],
              if (global.isNotEmpty) ...[
                buildTitle(_i18n.get("global_search")),
                ...searchResultWidget(global)
              ],
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
      //in contacts
      await _contactRepo.searchInContacts(query),
      //global search
      await _contactRepo.searchUser(query),
      //bot
      await _botRepo.searchBotByName(query),
      //in rooms
      await _roomRepo.searchInRooms(query)
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
            CircleAvatarWidget(uid, 24, showSavedMessageLogoIfNeeded: true),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: FutureBuilder<String>(
                future: _roomRepo.getName(uid, forceToReturnSavedMessage: true),
                builder: (c, snaps) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          snaps.data ?? "",
                          style: theme.textTheme.subtitle1,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      FutureBuilder<bool>(
                        initialData: _roomRepo.fastForwardIsVerified(uid),
                        future: _roomRepo.isVerified(uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                CupertinoIcons.checkmark_seal,
                                size: ((theme.textTheme.subtitle2)?.fontSize ??
                                    14),
                                color: ACTIVE_COLOR,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider()
      ],
    );
  }

  PreferredSize _buildAppBar() {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: GestureDetector(
        onTap: () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              curve: Curves.easeOut,
              duration: SLOW_ANIMATION_DURATION,
            );
          }
        },
        child: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              DescribedFeatureOverlay(
                featureId: FEATURE_3,
                tapTarget: CircleAvatarWidget(_authRepo.currentUserUid, 20),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                targetColor: theme.colorScheme.tertiary,
                title: Text(
                  _i18n.get("setting_icon_feature_discovery_title"),
                  textDirection: _i18n.defaultTextDirection,
                  style: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                overflowMode: OverflowMode.extendBackground,
                description: FeatureDiscoveryDescriptionWidget(
                  permissionWidget: (!isDesktop)
                      ? TextButton(
                          onPressed: () {
                            FeatureDiscovery.dismissAll(context);
                            _routingService.openContacts();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_i18n.get("sync_contact")),
                              const Icon(
                                Icons.arrow_forward,
                              )
                            ],
                          ),
                        )
                      : null,
                  description:
                      _i18n.get("setting_icon_feature_discovery_description"),
                  descriptionStyle: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
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
                    FocusManager.instance.primaryFocus?.unfocus();
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
                featureId: FEATURE_2,
                tapTarget: const Icon(
                  CupertinoIcons.qrcode_viewfinder,
                ),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                targetColor: theme.colorScheme.tertiary,
                title: Text(
                  _i18n.get("qr_code_feature_discovery_title"),
                  textDirection: _i18n.defaultTextDirection,
                  style: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                description: FeatureDiscoveryDescriptionWidget(
                  description:
                      _i18n.get("qr_code_feature_discovery_description"),
                  descriptionStyle: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
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
            if (false)
              DescribedFeatureOverlay(
                featureId: FEATURE_2,
                tapTarget: const Icon(Icons.storefront_outlined),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                targetColor: theme.colorScheme.tertiary,
                title: Text(
                  _i18n.get("qr_code_feature_discovery_title"),
                  textDirection: _i18n.defaultTextDirection,
                  style: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                description: FeatureDiscoveryDescriptionWidget(
                  description:
                      _i18n.get("qr_code_feature_discovery_description"),
                  descriptionStyle: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                child: IconButton(
                  onPressed: () => _routingService.openShowcase(),
                  icon: const Icon(Icons.storefront_outlined),
                ),
              ),
            const SizedBox(
              width: 8,
            )
          ],
        ),
      ),
    );
  }
}
