import 'dart:math';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/dot_animation/loading_dot_animation/loading_dot_animation.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:random_string/random_string.dart';

class ConnectionStatus extends StatelessWidget {
  final String normalTitle;
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _coreService = GetIt.I.get<CoreServices>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _serverLessService = GetIt.I.get<ServerLessService>();

  const ConnectionStatus({required this.normalTitle, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<TitleStatusConditions>(
      initialData: TitleStatusConditions.Connecting,
      stream: _messageRepo.updatingStatus.stream,
      builder: (c, status) {
        final state = title(status.data!);
        return Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            AnimatedSwitchWidget(
              child: StreamBuilder<dynamic>(
                key: Key(state),
                stream: _i18n.localeStream,
                builder: (context, snapshot) {
                  if (status.data == TitleStatusConditions.Connected) {
                    return Row(
                      key: ValueKey(randomString(10)),
                      children: [
                        Text(
                          state,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: true,
                        ),
                      ],
                    );
                  } else {
                    return Obx(
                      () => _serverLessService.address.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    _buildDialog(context, theme);
                                  },
                                  child: SizedBox(
                                    height: 24,
                                    child: Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons
                                              .antenna_radiowaves_left_right,
                                          color: ACTIVE_COLOR,
                                          size: 12,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        if (settings.isSuperNode.value)
                                          Text(
                                            _i18n.get("local_network"),
                                            style:
                                                const TextStyle(fontSize: 18),
                                          )
                                        else
                                          Text(
                                            _i18n.get("local_network_server"),
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 28,
                                          width: 60,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              for (var i = 0;
                                                  i <
                                                      min(
                                                        4,
                                                        _serverLessService
                                                            .address.length,
                                                      );
                                                  i++)
                                                Positioned(
                                                  left: (14 * i).toDouble(),
                                                  top: 1,
                                                  bottom: 1,
                                                  child: CircleAvatarWidget(
                                                    _serverLessService
                                                        .address.keys
                                                        .elementAt(i)
                                                        .asUid(),
                                                    14,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.clear,
                                      size: 14,
                                      color: Colors.redAccent,
                                    ),
                                    Text(
                                      _i18n.get("internet"),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : buildRowStatus(status.data!, state, theme),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _buildDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Center(
          child: Icon(CupertinoIcons.antenna_radiowaves_left_right),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
            },
            child: const Text("close"),
          )
        ],
        content: SizedBox(
          height: _serverLessService.address.length < 4
              ? _serverLessService.address.length * 62
              : 400,
          width: 200,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ListView.builder(
              itemCount: _serverLessService.address.length,
              itemBuilder: (con, i) {
                final uid = _serverLessService.address.keys.toList()[i].asUid();
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(c);
                    _routingService.openRoom(uid);
                  },
                  child: Container(
                    margin: const EdgeInsetsDirectional.all(4),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      border: Border.all(
                        color: theme.focusColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatarWidget(
                          uid,
                          20,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        RoomName(
                          uid: uid,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Row buildRowStatus(
    TitleStatusConditions status,
    String state,
    ThemeData theme, {
    bool minSize = false,
  }) {
    return Row(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () {
              if (status == TitleStatusConditions.Disconnected) {
                _routingService.openConnectionSettingPage();
              }
            },
            child: Text(
              state,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: true,
              style: minSize
                  ? TextStyle(fontSize: 12, color: theme.hintColor)
                  : null,
              key: ValueKey(randomString(10)),
            ),
          ),
        ),
        LoadingDotAnimation(
          dotsColor:
              theme.textTheme.titleLarge?.color ?? theme.colorScheme.primary,
        ),
        if (status == TitleStatusConditions.Disconnected)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _coreService.fasterRetryConnection,
              child: Icon(
                CupertinoIcons.refresh,
                size: minSize ? 12 : 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  String title(TitleStatusConditions statusConditions) {
    switch (statusConditions) {
      case TitleStatusConditions.Disconnected:
        return _i18n.get("disconnected").capitalCase;
      case TitleStatusConditions.Connecting:
        return _i18n.get("connecting").capitalCase;
      case TitleStatusConditions.Updating:
        return _i18n.get("updating").capitalCase;
      case TitleStatusConditions.Connected:
        return normalTitle.capitalCase;
      case TitleStatusConditions.Syncing:
        return _i18n.get("syncing").capitalCase;
    }
  }
}
