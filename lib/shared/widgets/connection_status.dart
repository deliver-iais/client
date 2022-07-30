import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ConnectionStatus extends StatelessWidget {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _coreServices = GetIt.I.get<CoreServices>();
  static final _routingServices = GetIt.I.get<RoutingService>();

  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<TitleStatusConditions>(
      initialData: TitleStatusConditions.Normal,
      stream: _messageRepo.updatingStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? TitleStatusConditions.Normal;

        return AnimatedOpacity(
          duration: SUPER_SLOW_ANIMATION_DURATION,
          opacity: status != TitleStatusConditions.Normal ? 1 : 0,
          child: AnimatedContainer(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            height: status != TitleStatusConditions.Normal ? 44 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: status == TitleStatusConditions.Connected ||
                      status == TitleStatusConditions.Normal ||
                      status == TitleStatusConditions.Updating ||
                      status == TitleStatusConditions.Syncing
                  ? elevation(
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primary,
                      5,
                    )
                  : theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: tertiaryBorder,
            ),
            curve: Curves.easeInOut,
            duration: SUPER_SLOW_ANIMATION_DURATION,
            child: Directionality(
              textDirection: _i18n.defaultTextDirection,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (status == TitleStatusConditions.Disconnected)
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 23,
                          onPressed: _routingServices.openConnectionSettingPage,
                          icon: Icon(
                            CupertinoIcons.settings,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        textDirection: _i18n.isPersian
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        title(status),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 5),
                      if (status == TitleStatusConditions.Connecting ||
                          status == TitleStatusConditions.Syncing ||
                          status == TitleStatusConditions.Updating)
                        SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  if (status == TitleStatusConditions.Disconnected)
                    StreamBuilder<int>(
                      initialData: 0,
                      stream: disconnectedTime.stream,
                      builder: (c, timeSnapShot) {
                        if (timeSnapShot.hasData && timeSnapShot.data != null) {
                          if (timeSnapShot.data! > 0) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(25, 15),
                                      alignment: Alignment.center,
                                    ),
                                    onPressed:
                                        _coreServices.retryFasterConnection,
                                    child: Row(
                                      textDirection: _i18n.defaultTextDirection,
                                      children: [
                                        Text(
                                          _i18n.get("reconnecting"),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        CircularCountDownTimer(
                                          key: UniqueKey(),
                                          duration: timeSnapShot.data!,
                                          width: 16,
                                          strokeWidth: 0,
                                          height: 16,
                                          isReverseAnimation: true,
                                          ringColor: Colors.transparent,
                                          fillColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          textStyle: Theme.of(context)
                                              .primaryTextTheme
                                              .bodyText2
                                              ?.copyWith(fontSize: 12),
                                          textFormat: CountdownTextFormat.S,
                                          isReverse: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // const SizedBox(width: 6),
                              ],
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    )
                ],
              ),
            ),
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
        return _i18n.get("connected").capitalCase;
      case TitleStatusConditions.Normal:
        return _i18n.get("connected").capitalCase;
      case TitleStatusConditions.Syncing:
        return _i18n.get("syncing").capitalCase;
    }
  }
}
