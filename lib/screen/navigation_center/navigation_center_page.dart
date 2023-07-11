import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/has_call_row.dart';
import 'package:deliver/screen/navigation_center/announcement/announcement_bar.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chats_page.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_room_counter.dart';
import 'package:deliver/screen/navigation_center/events/has_event_row.dart';
import 'package:deliver/screen/navigation_center/widgets/create_muc_floating_action_button.dart';
import 'package:deliver/screen/navigation_center/widgets/navigation_center_appBar/navigation_center_appbar_actions_widget.dart';
import 'package:deliver/screen/room/widgets/search_message_room/search_messages_in_room.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/search_message_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/client_version_informion.dart';
import 'package:deliver/shared/widgets/connection_status.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
    with TickerProviderStateMixin {
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _searchMessageService = GetIt.I.get<SearchMessageService>();
  final SearchController _searchBoxController = SearchController();
  final ScrollController _sliverScrollController = ScrollController();
  final _sliverScrollControllerOffset = BehaviorSubject<double>.seeded(0);
  final Map<Categories?, ScrollController> _chatsScrollController = {};
  TabController? _tabController;

  void _setChatScrollController(
    ScrollController chatScrollController,
    Categories? roomCategory,
  ) {
    _chatsScrollController[roomCategory] = chatScrollController;
  }

  final _appBarItemPadding = const EdgeInsets.symmetric(horizontal: 12);

  @override
  void initState() {
    modifyRoutingByNotificationTapInBackgroundInAndroid.listen((event) {
      if (event.isNotEmpty) {
        _routingService.openRoom(event);
      }
    });
    _sliverScrollController.addListener(() {
      _sliverScrollControllerOffset.add(_sliverScrollController.offset);
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

    super.initState();
  }

  void _resetChatScrollControllers(Categories? cat) {
    final controller = _chatsScrollController[cat];
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: AnimationSettings.slow,
      );
    }
    _sliverScrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: AnimationSettings.slow,
    );
  }

  @override
  void dispose() {
    _sliverScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidContainerWidget(
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        floatingActionButton: const CreateMucFloatingActionButton(),
        body: StreamBuilder<Uid?>(
          stream: _searchMessageService.inSearchMessageMode,
          builder: (context, searchMessageMode) {
            if (searchMessageMode.hasData && searchMessageMode.data != null  && isLarge(context)) {
              return SearchMessageInRoomWidget(uid: searchMessageMode.data);
            } else {
              return StreamBuilder<List<Categories>>(
                stream: _roomRepo.watchRoomsCategories(),
                builder: (context, roomsCategoriesSnapshot) {
                  final allChatsCategory = <Categories?>[null];
                  final roomsCategories =
                      allChatsCategory + (roomsCategoriesSnapshot.data ?? []);
                  _tabController = TabController(
                      length: roomsCategories.length, vsync: this);
                  _tabController?.addListener(() {
                    if (_tabController!.previousIndex !=
                        _tabController!.index) {
                      _resetChatScrollControllers(null);
                      for (final cat in Categories.values) {
                        _resetChatScrollControllers(cat);
                      }
                    }
                  });
                  return NestedScrollView(
                    controller: _sliverScrollController,
                    floatHeaderSlivers: true,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          pinned: true,
                          floating: true,
                          elevation: 6,
                          backgroundColor: elevation(
                            theme.colorScheme.background,
                            theme.colorScheme.primary,
                            1.3,
                          ),
                          titleSpacing: 8.0,
                          toolbarHeight: APPBAR_HEIGHT,
                          title:
                              ConnectionStatus(normalTitle: _i18n.get("chats")),
                          actions: [
                            NavigationCenterAppbarActionsWidget(
                              searchController: _searchBoxController,
                            ),
                          ],
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(APPBAR_HEIGHT),
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              labelPadding: const EdgeInsets.all(10),
                              onTap: (index) {
                                final category = index == 0
                                    ? null
                                    : roomsCategories[index - 1];
                                _resetChatScrollControllers(category);
                              },
                              tabs: [
                                for (final category in roomsCategories)
                                  Padding(
                                    padding: _appBarItemPadding,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          _convertRoomCategoryToTabName(
                                              category),
                                        ),
                                        AnimatedBuilder(
                                          animation: _tabController!.animation!,
                                          builder: (context, child) {
                                            return UnreadRoomCounterWidget(
                                              categories: category,
                                              bgColor: Color.alphaBlend(
                                                theme.colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(
                                                  (1 -
                                                          _getUnreadCountColor(
                                                            roomsCategories
                                                                .indexOf(
                                                                    category),
                                                          )) *
                                                      0.5,
                                                ),
                                                theme.primaryColor.withOpacity(
                                                  _getUnreadCountColor(
                                                    roomsCategories
                                                        .indexOf(category),
                                                  ),
                                                ),
                                              ),
                                              needBorder: false,
                                              usePadding: true,
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: Column(
                      children: <Widget>[
                        NewVersion.newVersionDownloadingStatusCard(
                            context, _sliverScrollControllerOffset),
                        if (!isLarge(context)) const AnnouncementBar(),
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
                        if (!isLarge(context)) const AudioPlayerAppBar(),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              for (final category in roomsCategories)
                                _buildChatPageByCategory(
                                  roomCategory: category,
                                )
                            ],
                          ),
                        ),
                        NewVersion.newVersionInfo(),
                        NewVersion.aborted(context),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  double _getUnreadCountColor(int tabIndex) {
    final value = _tabController!.animation!.value;

    if (tabIndex == 0 && value < 1) {
      return 1 - value;
    } else if (value <= tabIndex && value > tabIndex - 1) {
      return value - (tabIndex - 1);
    } else if (value > tabIndex && value < tabIndex + 1) {
      return (tabIndex + 1) - value;
    }

    return 0.0;
  }

  String _convertRoomCategoryToTabName(Categories? roomCategory) {
    switch (roomCategory) {
      case Categories.BOT:
        return _i18n.get("bot");
      case Categories.BROADCAST:
        return _i18n.get("broadcast");
      case Categories.CHANNEL:
        return _i18n.get("channel");
      case Categories.GROUP:
        return _i18n.get("group");
      case Categories.STORE:
      case Categories.SYSTEM:
        return "";
      case Categories.USER:
        return _i18n.get("personal");
    }
    return _i18n.get("all");
  }

  Widget _buildChatPageByCategory({Categories? roomCategory}) {
    return ChatsPage(
      setChatScrollController: _setChatScrollController,
      scrollController: _sliverScrollController,
      roomCategory: roomCategory,
    );
  }
}
