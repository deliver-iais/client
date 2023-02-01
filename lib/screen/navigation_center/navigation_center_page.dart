import 'package:animations/animations.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/call/has_call_row.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chats_page.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_room_counter.dart';
import 'package:deliver/screen/navigation_center/search/search_rooms_widget.dart';
import 'package:deliver/screen/navigation_center/widgets/feature_discovery_description_widget.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/show_case/pages/show_case_page.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/connection_status.dart';
import 'package:deliver/shared/widgets/dot_animation/jumping_dot_animation.dart';
import 'package:deliver/shared/widgets/out_of_date.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:window_size/window_size.dart';

BehaviorSubject<String> modifyRoutingByNotificationTapInBackgroundInAndroid =
    BehaviorSubject.seeded("");

class CallNotificationActionInBackground {
  final String roomId;
  final bool isCallAccepted;
  final bool isVideo;

  CallNotificationActionInBackground({
    required this.roomId,
    required this.isCallAccepted,
    required this.isVideo,
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
    with CustomPopupMenu, SingleTickerProviderStateMixin {
  static final _routingServices = GetIt.I.get<RoutingService>();

  static final _i18n = GetIt.I.get<I18N>();

  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _sharedDao = GetIt.I.get<SharedDao>();
  static final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final BehaviorSubject<bool> _searchMode = BehaviorSubject.seeded(false);
  final TextEditingController _searchBoxController = TextEditingController();
  void Function()? _onNavigationCenterBackPressed;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _searchBoxAnimationController;
  late final Animation<double> _searchBoxAnimation;
  bool _isShowCaseEnable = SHOWCASES_IS_AVAILABLE && SHOWCASES_SHOWING_FIRST;

  @override
  void initState() {
    _searchBoxAnimationController = AnimationController(
      vsync: this,
      duration: MOTION_STANDARD_ANIMATION_DURATION,
      animationBehavior: AnimationBehavior.preserve,
    );
    _searchBoxAnimation = Tween(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _searchBoxAnimationController,
        curve: Curves.easeInOut,
      ),
    );
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
          isVideoCall: event.isVideo,
        );
      }
    });

    _sharedDao
        .getBooleanStream(
          SHARED_DAO_IS_SHOWCASE_ENABLE,
          // ignore: avoid_redundant_argument_values
          defaultValue: SHOWCASES_IS_AVAILABLE && SHOWCASES_SHOWING_FIRST,
        )
        .distinct()
        .listen(
          (event) => setState(
            () => _isShowCaseEnable = SHOWCASES_IS_AVAILABLE && event,
          ),
        );

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
                          key: const Key("contacts"),
                          value: "contacts",
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.person_2_alt),
                              const SizedBox(width: 8),
                              Text(
                                _i18n.get("contacts"),
                                style: theme.primaryTextTheme.bodyText2,
                              )
                            ],
                          ),
                        ),
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
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _searchBoxAnimation,
                    builder: (c, w) {
                      return SearchBox(
                        focusNode: MAIN_SEARCH_BOX_FOCUS_NODE,
                        animationValue: _searchBoxAnimation.value,
                        controller: _searchBoxController,
                        onChange: (c) {
                          _searchMode.add(true);
                        },
                        onCancel: () {
                          _searchMode.add(true);
                        },
                        onSearchEnd: () {
                          _searchBoxAnimationController.reverse();
                          _searchMode.add(false);
                        },
                        onTap: () {
                          _searchBoxAnimationController.forward();
                          _searchMode.add(true);
                        },
                      );
                    },
                  ),
                ),
                if (!isLarge(context)) const AudioPlayerAppBar(),
                Expanded(
                  child: PageTransitionSwitcher(
                    transitionBuilder: (
                      child,
                      animation,
                      secondaryAnimation,
                    ) {
                      return SharedAxisTransition(
                        fillColor: Colors.transparent,
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.scaled,
                        child: child,
                      );
                    },
                    child: StreamBuilder<bool>(
                      stream: _searchMode,
                      builder: (c, s) {
                        if (s.hasData && s.data != null && s.data!) {
                          _onNavigationCenterBackPressed = () {
                            if (_searchBoxController.text.isNotEmpty) {
                              _searchMode.add(true);
                              _searchBoxController.clear();
                            } else {
                              _searchBoxAnimationController.reverse();
                              _searchMode.add(false);
                            }
                          };
                          return SearchRoomsWidget(
                            searchBoxController: _searchBoxController,
                          );
                        } else {
                          _onNavigationCenterBackPressed = null;
                          return !_isShowCaseEnable
                              ? ChatsPage(
                                  scrollController: _scrollController,
                                )
                              : const ShowcasePage();
                        }
                      },
                    ),
                  ),
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
        if (snapshot.hasData) {
          _sharedDao.once(
            ONCE_SHOW_NEW_VERSION_INFORMATION,
            () async {
              await Future.delayed(Duration.zero);
              showFloatingModalBottomSheet(
                context: context,
                enableDrag: false,
                isDismissible: false,
                builder: (c) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Tgs.asset(
                          "assets/animations/new_version.tgs",
                          height: 230,
                          width: 300,
                        ),
                        Text(
                          "${_i18n.get("update")} $APPLICATION_NAME",
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
                            for (var downloadLink
                                in snapshot.data!.downloadLinks)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () =>
                                    _urlHandlerService.handleNormalLink(
                                  downloadLink.url,
                                  context,
                                ),
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
                              onPressed: () => Navigator.pop(c),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ).ignore();
            },
          );
        }

        return const SizedBox.shrink();
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
      case "contacts":
        _routingService.openContacts();
        break;
      case "newGroup":
        _routingService.openMemberSelection(isChannel: false);
        break;
      case "newChannel":
        _routingService.openMemberSelection(isChannel: true);
        break;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return BlurredPreferredSizedWidget(
      child: AnimatedBuilder(
        animation: _searchBoxAnimation,
        builder: (c, w) {
          return Container(
            color: Colors.transparent,
            height: _searchBoxAnimation.value * 2,
            child: Opacity(
              opacity: _searchBoxAnimation.value / 40,
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
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: DescribedFeatureOverlay(
                      featureId: SETTING_FEATURE,
                      tapTarget:
                          CircleAvatarWidget(_authRepo.currentUserUid, 30),
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
                        description: _i18n
                            .get("setting_icon_feature_discovery_description"),
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
                  ),
                  titleSpacing: 8.0,
                  title: ConnectionStatus(
                    isShowCase: _isShowCaseEnable,
                  ),
                  actions: [
                    if (!isDesktop)
                      DescribedFeatureOverlay(
                        featureId: QRCODE_FEATURE,
                        tapTarget: Icon(
                          CupertinoIcons.qrcode_viewfinder,
                          color: theme.colorScheme.tertiaryContainer,
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
                          description: _i18n
                              .get("qr_code_feature_discovery_description"),
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
                    if (SHOWCASES_IS_AVAILABLE)
                      DescribedFeatureOverlay(
                        featureId: SHOW_CASE_FEATURE,
                        tapTarget: !_isShowCaseEnable
                            ? Icon(
                                Icons.storefront_outlined,
                                color: theme.colorScheme.tertiaryContainer,
                              )
                            : Icon(
                                CupertinoIcons.chat_bubble_fill,
                                color: theme.colorScheme.tertiaryContainer,
                              ),
                        backgroundColor: theme.colorScheme.tertiaryContainer,
                        targetColor: theme.colorScheme.tertiary,
                        title: Text(
                          _i18n.get("chats_feature_discovery_title"),
                          textDirection: _i18n.defaultTextDirection,
                          style: TextStyle(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                        description: FeatureDiscoveryDescriptionWidget(
                          description:
                              _i18n.get("chats_feature_discovery_description"),
                          descriptionStyle: TextStyle(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () => _sharedDao
                              .toggleBoolean(SHARED_DAO_IS_SHOWCASE_ENABLE),
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: tertiaryBorder,
                                      ),
                                      child: PageTransitionSwitcher(
                                        transitionBuilder: (
                                          child,
                                          animation,
                                          secondaryAnimation,
                                        ) {
                                          return FadeScaleTransition(
                                            animation: animation,
                                            child: child,
                                          );
                                        },
                                        child: !_isShowCaseEnable
                                            ? Icon(
                                                Icons.storefront_outlined,
                                                color:
                                                    theme.colorScheme.surface,
                                              )
                                            : Icon(
                                                CupertinoIcons.chat_bubble_fill,
                                                color:
                                                    theme.colorScheme.surface,
                                              ),
                                      ),
                                    ),
                                    if (_isShowCaseEnable) ...[
                                      JumpingDotAnimation(
                                        dotsColor: theme.colorScheme.primary,
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                              const Positioned(
                                top: 3,
                                right: 0,
                                child: UnreadRoomCounterWidget(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(
                      width: 8,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
