import 'package:deliver/box/dao/recent_rooms_dao.dart';
import 'package:deliver/box/dao/recent_search_dao.dart';
import 'package:deliver/box/recent_rooms.dart';
import 'package:deliver/box/recent_search.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/screen/navigation_center/search/room_information_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RecentSearchAndRoomWidget extends StatelessWidget {
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _recentRoomsDao = GetIt.I.get<RecentRoomsDao>();
  static final _recentSearch = GetIt.I.get<RecentSearchDao>();
  static final _i18n = GetIt.I.get<I18N>();

  const RecentSearchAndRoomWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecentRoomList(),
        _buildRecentSearchList(context),
      ],
    );
  }

  Widget _buildRecentRoomList() {
    return FutureBuilder<List<RecentRooms>>(
      future: _recentRoomsDao.getAll(),
      builder: (context, recentRooms) {
        if (recentRooms.hasData && recentRooms.data != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (c, i) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _routingService.openRoom(
                            recentRooms.data![i].roomId,
                          );
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 60,
                                child: Column(
                                  children: [
                                    CircleAvatarWidget(
                                      recentRooms.data![i].roomId.asUid(),
                                      26,
                                      isHeroEnabled: false,
                                      showSavedMessageLogoIfNeeded: true,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    RoomName(
                                      uid: recentRooms.data![i].roomId.asUid(),
                                      forceToReturnSavedMessage: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            StreamBuilder<Room?>(
                              stream: _roomRepo.watchRoom(
                                recentRooms.data![i].roomId,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Positioned(
                                    bottom: 45,
                                    right: 8,
                                    child: UnreadMessageCounterWidget(
                                      recentRooms.data![i].roomId,
                                      snapshot.data!.lastMessageId,
                                      needBorder: true,
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: recentRooms.data!.length,
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildRecentSearchList(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<RecentSearch>>(
      stream: _recentSearch.getAll(),
      builder: (context, recentSearch) {
        if (recentSearch.hasData &&
            recentSearch.data != null &&
            recentSearch.data!.isNotEmpty) {
          return Column(
            children: [
              Directionality(
                textDirection: _i18n.defaultTextDirection,
                child: Container(
                  color: theme.dividerColor.withAlpha(10),
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _i18n.get("recent_search"),
                        style: getFadeTextStyle(context),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(100, 10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _i18n.get("clear_all"),
                          style: getFadeTextStyle(context),
                        ),
                        onPressed: () => _recentSearch.deleteAll(),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (c, i) {
                  return RoomInformationWidget(
                    uid: recentSearch.data![i].roomId.asUid(),
                  );
                },
                itemCount: recentSearch.data!.length,
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
