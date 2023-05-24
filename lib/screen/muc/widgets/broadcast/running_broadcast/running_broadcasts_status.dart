import 'package:deliver/box/broadcast_message_status_type.dart';
import 'package:deliver/box/broadcast_status.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/muc/widgets/broadcast/running_broadcast/running_broadcast_status_card.dart';
import 'package:deliver/screen/navigation_center/search/not_result_widget.dart';
import 'package:deliver/services/broadcast_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/dot_animation/loading_dot_animation/loading_dot_animation.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class RunningBroadcastStatus extends StatefulWidget {
  final Uid roomUid;

  const RunningBroadcastStatus({Key? key, required this.roomUid})
      : super(key: key);

  @override
  State<RunningBroadcastStatus> createState() => _RunningBroadcastStatus();
}

class _RunningBroadcastStatus extends State<RunningBroadcastStatus> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final _broadcastService = GetIt.I.get<BroadcastService>();
  final BehaviorSubject<bool> _isBroadcastEmpty = BehaviorSubject.seeded(false);
  final BehaviorSubject<List<BroadcastStatus>> _allBroadcastStatus =
      BehaviorSubject.seeded([]);
  final _i18n = GetIt.I.get<I18N>();
  List<BroadcastStatus> _items = [];

  @override
  void initState() {
    _broadcastService
        .getAllBroadcastStatusAsStream(widget.roomUid)
        .listen((event) {
      _allBroadcastStatus.add(event);
      _isBroadcastEmpty.add(event.isEmpty);
      if (_items.isEmpty) {
        for (final status in event) {
          listKey.currentState?.insertItem(
            0,
            duration: const Duration(milliseconds: 500),
          );
          _items = [status, ..._items];
        }
      }
      if (listKey.currentState != null) {
        if (_items.length < event.length) {
          listKey.currentState?.insertItem(
            0,
            duration: const Duration(milliseconds: 500),
          );
          _items = [event.last, ..._items];
        } else if (_items.length > event.length) {
          final deletedItemIndex =
              _items.lastIndexWhere((e) => !event.contains(e));
          final deletedItem = _items[deletedItemIndex];
          listKey.currentState?.removeItem(
            deletedItemIndex,
            (_, animation) =>
                _buildStatusItems(context, deletedItem, animation),
            duration: const Duration(milliseconds: 500),
          );
          _items.removeAt(deletedItemIndex);
        } else {
          _items = event.reversed.toList();
          listKey.currentState?.build(context);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: StreamBuilder<bool>(
        stream: _isBroadcastEmpty,
        builder: (context, snapshot) {
          final listIsEmpty = snapshot.hasData && snapshot.data!;
          return AnimatedSwitcher(
            key: const Key("broad_cast_status"),
            duration: AnimationSettings.standard,
            child: listIsEmpty
                ? Padding(
                    padding: const EdgeInsetsDirectional.all(p8),
                    child: NoResultWidget(
                      text: _i18n.get("no_running_broadcast"),
                    ),
                  )
                : Column(
                    children: [
                      RunningBroadcastStatusCard(
                        broadcastRoomId: widget.roomUid,
                        allBroadcastStatus: _allBroadcastStatus,
                      ),
                      Expanded(
                        child: AnimatedList(
                          key: listKey,
                          initialItemCount: _items.length,
                          itemBuilder: (context, index, animation) =>
                              _buildStatusItems(
                            context,
                            _items[index],
                            animation,
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Color _getBroadcastStatusTypeColor(
    BroadcastMessageStatusType status,
    ThemeData theme,
  ) {
    return status == BroadcastMessageStatusType.FAILED
        ? theme.colorScheme.error.withOpacity(0.8)
        : theme.colorScheme.outline;
  }

  SlideTransition _buildStatusItems(
    BuildContext context,
    BroadcastStatus broadcastStatus,
    animation,
  ) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: const Offset(0, 0),
      ).animate(animation),
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(
          vertical: p4,
          horizontal: p8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.8),
          boxShadow: DEFAULT_BOX_SHADOWS,
          borderRadius: tertiaryBorder,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(p8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (broadcastStatus.isSmsBroadcast)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(p12),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.person,
                            size: 26,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    )
                  else
                    CircleAvatarWidget(
                      broadcastStatus.to.asUid(),
                      25,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: p8,
                    ),
                    child: SizedBox(
                      width: 150,
                      child: broadcastStatus.isSmsBroadcast
                          ? Text(broadcastStatus.to)
                          : RoomName(
                              uid: broadcastStatus.to.asUid(),
                            ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _broadcastService.getBroadcastStatusTypeAsString(
                      broadcastStatus.status,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getBroadcastStatusTypeColor(
                        broadcastStatus.status,
                        theme,
                      ),
                    ),
                  ),
                  if (broadcastStatus.status !=
                      BroadcastMessageStatusType.FAILED) ...[
                    const SizedBox(
                      width: p2,
                    ),
                    LoadingDotAnimation(
                      dotsColor: _getBroadcastStatusTypeColor(
                        broadcastStatus.status,
                        theme,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
