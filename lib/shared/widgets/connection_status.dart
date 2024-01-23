import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/serverless/serverless_service.dart';

import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/dot_animation/loading_dot_animation/loading_dot_animation.dart';
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
      initialData: TitleStatusConditions.Connected,
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
                  return Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            if (status.data ==
                                TitleStatusConditions.Disconnected) {
                              _routingService.openConnectionSettingPage();
                            }
                          },
                          child: Obx(
                            () => Text(
                              state,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              style: _serverLessService.address.isNotEmpty
                                  ? const TextStyle(fontSize: 16)
                                  : null,
                              softWrap: true,
                              key: ValueKey(randomString(10)),
                            ),
                          ),
                        ),
                      ),
                      if (status.data != TitleStatusConditions.Connected)
                        LoadingDotAnimation(
                          dotsColor: theme.textTheme.titleLarge?.color ??
                              theme.colorScheme.primary,
                        ),
                      if (status.data == TitleStatusConditions.Disconnected)
                        Obx(
                          () => MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _coreService.fasterRetryConnection,
                              child: Icon(
                                CupertinoIcons.refresh,
                                size: _serverLessService.address.isNotEmpty
                                    ? 18
                                    : 23,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Obx(
              () => _serverLessService.address.isNotEmpty &&
                      status.data != TitleStatusConditions.Connected
                  ? SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.antenna_radiowaves_left_right,
                            color: ACTIVE_COLOR,
                            size: 12,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            _i18n.get("local_network"),
                            style: const TextStyle(fontSize: 12),
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
                                    i < _serverLessService.address.length;
                                    i++)
                                  Positioned(
                                    left: (14 * i).toDouble(),
                                    top: 1,
                                    bottom: 1,
                                    child: CircleAvatarWidget(
                                      _serverLessService.address.keys
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
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
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
      case TitleStatusConditions.SaveLocalMessage:
        return _i18n.get("save_local_message").capitalCase;
    }
  }
}
