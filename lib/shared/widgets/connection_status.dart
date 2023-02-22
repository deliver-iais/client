import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver/shared/widgets/dot_animation/loading_dot_animation/loading_dot_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:random_string/random_string.dart';

class ConnectionStatus extends StatefulWidget {
  final bool isShowCase;

  const ConnectionStatus({super.key, required this.isShowCase});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _coreService = GetIt.I.get<CoreServices>();
  static final _routingService = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              return Directionality(
                textDirection:
                    _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
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
                          style:
                              theme.textTheme.headline6!.copyWith(fontSize: 20),
                          key: ValueKey(randomString(10)),
                        ),
                      ),
                    ),
                    if (status.data != TitleStatusConditions.Connected)
                      LoadingDotAnimation(
                        dotsColor: theme.textTheme.headline6?.color ??
                            theme.colorScheme.primary,
                      ),
                    if (status.data == TitleStatusConditions.Disconnected)
                      IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 23,
                        onPressed: _coreService.fasterRetryConnection,
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
        return _i18n.get("disconnected").capitalCase;
      case TitleStatusConditions.Connecting:
        return _i18n.get("connecting").capitalCase;
      case TitleStatusConditions.Updating:
        return _i18n.get("updating").capitalCase;
      case TitleStatusConditions.Connected:
        if (widget.isShowCase) {
          return _i18n.get("showcase").capitalCase;
        } else {
          return _i18n.get("chats").capitalCase;
        }
      case TitleStatusConditions.Syncing:
        return _i18n.get("syncing").capitalCase;
    }
  }
}
