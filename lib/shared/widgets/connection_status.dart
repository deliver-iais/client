import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver/shared/widgets/dot_animation/loading_dot_animation/loading_dot_animation.dart';
import 'package:deliver/utils/call_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:random_string/random_string.dart';

class ConnectionStatus extends StatelessWidget {
  final String normalTitle;
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _coreService = GetIt.I.get<CoreServices>();
  static final _routingService = GetIt.I.get<RoutingService>();

  const ConnectionStatus({required this.normalTitle, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      stream: _coreService.proposeUseLocalNetwork,
      builder: (c, proposeUseLocalNetwork) {
        return StreamBuilder<TitleStatusConditions>(
          initialData: TitleStatusConditions.Connected,
          stream: _messageRepo.updatingStatus.stream,
          builder: (c, status) {
            final state = title(status.data!);

            return AnimatedSwitchWidget(
              child: StreamBuilder<dynamic>(
                key: Key(state),
                stream: _i18n.localeStream,
                builder: (context, snapshot) {
                  if (proposeUseLocalNetwork.data ?? false) {
                    return Row(
                      children: [
                        const Icon(
                          CupertinoIcons.antenna_radiowaves_left_right,
                          color: Colors.indigo,
                          size: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Text(_i18n.get("local_network_?")),
                        ),
                        Switch(
                          value: !(proposeUseLocalNetwork.data ?? false),
                          onChanged: (c) {
                            settings.inLocalNetwork.set(true);
                            _coreService.useLocalNetwork();
                            // CallUtils.checkForSystemAlertWindowPermission();
                          },
                        ),
                      ],
                    );
                  }
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
                          child: Text(
                            state,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: true,
                            key: ValueKey(randomString(10)),
                          ),
                        ),
                      ),
                      if (status.data != TitleStatusConditions.Connected &&
                          status.data != TitleStatusConditions.LocalNetwork)
                        LoadingDotAnimation(
                          dotsColor: theme.textTheme.titleLarge?.color ??
                              theme.colorScheme.primary,
                        ),
                      if (status.data == TitleStatusConditions.Disconnected)
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 23,
                          onPressed: _coreService.fasterRetryConnection,
                          icon: Icon(
                            CupertinoIcons.refresh,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
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
      case TitleStatusConditions.LocalNetwork:
        return _i18n.get("local_network").capitalCase;
      case TitleStatusConditions.SaveLocalMessage:
        return _i18n.get("save_local_message").capitalCase;
    }
  }
}
