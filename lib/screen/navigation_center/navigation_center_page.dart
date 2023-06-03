import 'package:animations/animations.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/call/has_call_row.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chats_page.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_room_counter.dart';
import 'package:deliver/screen/navigation_center/events/has_event_row.dart';
import 'package:deliver/screen/navigation_center/search/search_rooms_widget.dart';
import 'package:deliver/screen/navigation_center/widgets/create_muc_floating_action_button.dart';
import 'package:deliver/screen/navigation_center/widgets/feature_discovery_description_widget.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/show_case/pages/show_case_page.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/client_version_informion.dart';
import 'package:deliver/shared/widgets/connection_status.dart';
import 'package:deliver/shared/widgets/dot_animation/jumping_dot_animation.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hovering/hovering.dart';
import 'package:rxdart/rxdart.dart';

final modifyRoutingByNotificationTapInBackgroundInAndroid =
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

final modifyRoutingByCallNotificationActionInBackgroundInAndroid =
    BehaviorSubject<CallNotificationActionInBackground?>.seeded(null);

class NavigationCenter extends StatefulWidget {
  const NavigationCenter({super.key});

  @override
  NavigationCenterState createState() => NavigationCenterState();
}

class NavigationCenterState extends State<NavigationCenter>
    with CustomPopupMenu, SingleTickerProviderStateMixin {
  static final _routingServices = GetIt.I.get<RoutingService>();

  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();

  final BehaviorSubject<bool> _searchMode = BehaviorSubject.seeded(false);
  final TextEditingController _searchBoxController = TextEditingController();
  void Function()? _onNavigationCenterBackPressed;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _searchBoxAnimationController;
  late final Animation<double> _searchBoxAnimation;

  @override
  void initState() {
    _searchBoxAnimationController = AnimationController(
      vsync: this,
      duration: AnimationSettings.standard,
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
          isIncomingCall: true,
        );
      }
    });

    _routingService.registerPreMaybePopScope(
      "navigation_center_page",
      checkSearchBoxIsOpenOrNot,
    );
    //_callRepo.listenBackgroundCall();
    super.initState();
  }

  @override
  void dispose() {
    _searchBoxController.dispose();
    _scrollController.dispose();
    _searchMode.close();
    super.dispose();
  }

  bool get showShowcase =>
      settings.showShowcasePage.value && SHOWCASES_IS_AVAILABLE;

  NavigationCenterState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidContainerWidget(
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: _buildAppBar(),
        floatingActionButton: const CreateMucFloatingActionButton(),
        body: RepaintBoundary(
          child: Column(
            children: <Widget>[
              StreamBuilder<bool>(
                stream: settings.showEvents.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!) {
                    return const HasEventsRow();
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
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
                  duration: AnimationSettings.standard,
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
                        return !showShowcase
                            ? ChatsPage(
                                scrollController: _scrollController,
                              )
                            : const ShowcasePage();
                      }
                    },
                  ),
                ),
              ),
              NewVersion.newVersionInfo(),
              NewVersion.aborted(context),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> checkSearchBoxIsOpenOrNot() async {
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      return true;
    }
    if (_onNavigationCenterBackPressed != null) {
      _onNavigationCenterBackPressed?.call();
      return false;
    }
    return true;
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
                      duration: AnimationSettings.slow,
                    );
                  }
                },
                child: AppBar(
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  titleSpacing: 8.0,
                  title: ConnectionStatus(isShowCase: showShowcase),
                  actions: [
                    if (isMobileNative)
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
                    StreamBuilder<PerformanceMode>(
                      stream: PerformanceMonitor.performanceProfile,
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data!.level <=
                                PerformanceMode.POWER_SAVER.level) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanDown: storeDragDownPosition,
                            child: IconButton(
                              onPressed: () async {
                                final value = await this.showMenu(
                                  context: context,
                                  items: [
                                    PopupMenuItem(
                                      value: "go_to_settings",
                                      child: Text(
                                        _i18n["power_saver_turned_on"],
                                      ),
                                    )
                                  ],
                                );
                                if (value == "go_to_settings") {
                                  _routingServices.openPowerSaverSettings();
                                }
                              },
                              icon: const Icon(
                                Icons.energy_savings_leaf_outlined,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    if (SHOWCASES_IS_AVAILABLE)
                      DescribedFeatureOverlay(
                        featureId: SHOW_CASE_FEATURE,
                        tapTarget: !showShowcase
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
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => setState(
                              () {
                                settings.showShowcasePage.toggleValue();
                                _routingService.animateResizablePanels();
                              },
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              clipBehavior: Clip.none,
                              children: [
                                HoverContainer(
                                  width: 40,
                                  height: 40,
                                  cursor: SystemMouseCursors.click,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.85),
                                    borderRadius: messageBorder,
                                  ),
                                  hoverDecoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: messageBorder,
                                  ),
                                  child: PageTransitionSwitcher(
                                    duration: AnimationSettings.standard,
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
                                    child: !showShowcase
                                        ? Icon(
                                            Icons.storefront_outlined,
                                            color: theme.colorScheme.surface,
                                          )
                                        : Icon(
                                            CupertinoIcons.chat_bubble_fill,
                                            color: theme.colorScheme.surface,
                                          ),
                                  ),
                                ),
                                if (showShowcase)
                                  const UnreadRoomCounterWidget(),
                                if (showShowcase)
                                  JumpingDotAnimation(
                                    dotsColor: theme.colorScheme.primary,
                                  ),
                              ],
                            ),
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
