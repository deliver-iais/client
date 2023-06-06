import 'package:animations/animations.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/call/has_call_row.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chats_page.dart';
import 'package:deliver/screen/navigation_center/events/has_event_row.dart';
import 'package:deliver/screen/navigation_center/widgets/create_muc_floating_action_button.dart';
import 'package:deliver/screen/navigation_center/widgets/navigation_center_appBar/navigation_center_appbar_actions_widget.dart';
import 'package:deliver/services/routing_service.dart';
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

class NavigationCenterState extends State<NavigationCenter> {
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();
  final SearchController _searchBoxController = SearchController();
  final ScrollController _sliverScrollController = ScrollController();
  late ScrollController _chatScrollController;

  void _setChatScrollController(ScrollController chatScrollController) {
    _chatScrollController = chatScrollController;
  }

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
          isVideoCall: event.isVideo,
          isIncomingCall: true,
        );
      }
    });
    //_callRepo.listenBackgroundCall();
    super.initState();
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
        body: DefaultTabController(
          length: 4,
          child: NestedScrollView(
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
                  title: ConnectionStatus(normalTitle: _i18n.get("chats")),
                  actions: [
                    NavigationCenterAppbarActionsWidget(
                      searchController: _searchBoxController,
                    ),
                  ],
                  bottom: TabBar(
                    onTap: (index) {
                      if (_chatScrollController.hasClients) {
                        _chatScrollController.animateTo(
                          0.0,
                          curve: Curves.easeOut,
                          duration: AnimationSettings.slow,
                        );
                      }
                    },
                    labelPadding: const EdgeInsets.all(10),
                    tabs: [
                      Text(_i18n.get("all")),
                      Text(_i18n.get("personal")),
                      Text(_i18n.get("channel")),
                      Text(_i18n.get("group")),
                    ],
                  ),
                ),
              ];
            },
            body: Column(
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
                if (!isLarge(context)) const AudioPlayerAppBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildChatPageByCategory(),
                      _buildChatPageByCategory(
                        roomCategory: Categories.USER,
                      ),
                      _buildChatPageByCategory(
                        roomCategory: Categories.CHANNEL,
                      ),
                      _buildChatPageByCategory(
                        roomCategory: Categories.GROUP,
                      )
                    ],
                  ),
                ),
                NewVersion.newVersionInfo(),
                NewVersion.aborted(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatPageByCategory({Categories? roomCategory}) {
    return ChatsPage(
      setChatScrollController: _setChatScrollController,
      scrollController: _sliverScrollController,
      roomCategory: roomCategory,
    );
  }
}
