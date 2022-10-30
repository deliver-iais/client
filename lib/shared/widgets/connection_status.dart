import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver/shared/widgets/dot_animation/dot_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:random_string/random_string.dart';

class ConnectionStatus extends StatefulWidget {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _coreService = GetIt.I.get<CoreServices>();
  static final _routingService = GetIt.I.get<RoutingService>();

  const ConnectionStatus({super.key});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<TitleStatusConditions>(
      stream: ConnectionStatus._messageRepo.updatingStatus.stream,
      builder: (c, status) {
        var state = ConnectionStatus._i18n.get("chats");
        if (status.hasData && status.data != null) {
          switch (status.data!) {
            case TitleStatusConditions.Connected:
              break;
            case TitleStatusConditions.Disconnected:
              state = ConnectionStatus._i18n.get("disconnected");
              break;
            case TitleStatusConditions.Updating:
              state = ConnectionStatus._i18n.get("updating");
              break;
            case TitleStatusConditions.Connecting:
              state = ConnectionStatus._i18n.get("connecting");
              break;
            case TitleStatusConditions.Syncing:
              state = ConnectionStatus._i18n.get("syncing");
              break;
          }
        }

        return AnimatedSwitchWidget(
          child: StreamBuilder<dynamic>(
            key: Key(state),
            stream: ConnectionStatus._i18n.localeStream,
            builder: (context, snapshot) {
              return Directionality(
                textDirection: ConnectionStatus._i18n.isPersian
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (status.data == TitleStatusConditions.Disconnected) {
                          ConnectionStatus._routingService
                              .openConnectionSettingPage();
                        }
                      },
                      child: Text(
                        state,
                        style: theme.textTheme.headline6,
                        key: ValueKey(randomString(10)),
                      ),
                    ),
                    if (status.data != TitleStatusConditions.Connected)
                      DotAnimation(
                        dotsColor: Theme.of(context).primaryColor,
                      ),
                    if (status.data == TitleStatusConditions.Disconnected)
                      IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 23,
                        onPressed:
                            ConnectionStatus._coreService.retryFasterConnection,
                        icon: Icon(
                          CupertinoIcons.refresh,
                          color: theme.primaryColor,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String title(TitleStatusConditions statusConditions) {
    switch (statusConditions) {
      case TitleStatusConditions.Disconnected:
        return ConnectionStatus._i18n.get("disconnected").capitalCase;
      case TitleStatusConditions.Connecting:
        return ConnectionStatus._i18n.get("connecting").capitalCase;
      case TitleStatusConditions.Updating:
        return ConnectionStatus._i18n.get("updating").capitalCase;
      case TitleStatusConditions.Connected:
        return ConnectionStatus._i18n.get("connected").capitalCase;
      case TitleStatusConditions.Syncing:
        return ConnectionStatus._i18n.get("syncing").capitalCase;
    }
  }
}
