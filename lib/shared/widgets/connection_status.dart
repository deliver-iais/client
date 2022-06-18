import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionStatus extends StatelessWidget {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _coreServices = GetIt.I.get<CoreServices>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  final _countDownController = CountDownController();
  final BehaviorSubject<bool> _disableFastConnection =
      BehaviorSubject.seeded(false);

  ConnectionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<TitleStatusConditions>(
      initialData: TitleStatusConditions.Normal,
      stream: _messageRepo.updatingStatus.stream,
      builder: (context, snapshot) {
        if (snapshot.data != TitleStatusConditions.Normal) {
          return AnimatedContainer(
            width: double.infinity,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: tertiaryBorder,
            ),
            curve: Curves.easeInOut,
            duration: ANIMATION_DURATION * 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Lottie.asset(
                      snapshot.data! == TitleStatusConditions.Connecting
                          ? "assets/animations/connecting.zip"
                          : snapshot.data! == TitleStatusConditions.Disconnected
                              ? "assets/animations/disconnected.zip"
                              : "assets/animations/update.zip",
                      height: 35,
                      width: 35,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title(snapshot.data ?? TitleStatusConditions.Normal),
                      style: theme.textTheme.subtitle1?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    )
                  ],
                ),
                if (snapshot.data! == TitleStatusConditions.Disconnected)
                  StreamBuilder<int>(
                    initialData: 0,
                    stream: disconnectedTime.stream,
                    builder: (c, timeSnapShot) {
                      if (timeSnapShot.hasData && timeSnapShot.data != null) {
                        _disableFastConnection.add(false);
                        if (timeSnapShot.data! > 0) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () => _routingServices
                                    .openConnectionSettingPage(),
                                child: CircularCountDownTimer(
                                  key: Key(
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                  ),
                                  duration: timeSnapShot.data!,
                                  controller: _countDownController,
                                  width: 25,
                                  strokeWidth: 3,
                                  height: 25,
                                  isReverseAnimation: true,
                                  ringColor: theme.disabledColor,
                                  fillColor: theme.backgroundColor,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(fontSize: 13),
                                  textFormat: CountdownTextFormat.S,
                                  isReverse: true,
                                  onComplete: () {
                                    _coreServices.retryConnection();
                                    _disableFastConnection.add(true);
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              StreamBuilder<bool>(
                                initialData: false,
                                stream: _disableFastConnection.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && !snapshot.data!) {
                                    return IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _coreServices.retryFasterConnection();
                                        _disableFastConnection.add(true);
                                      },
                                      icon: Icon(
                                        CupertinoIcons.refresh,
                                        color: theme.primaryColor,
                                        //  size: 30,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              )
                            ],
                          );
                        } else if (timeSnapShot.data == -1) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          );
                        }
                      }

                      return const SizedBox.shrink();
                    },
                  )
              ],
            ),
          );
        }
        return const SizedBox.shrink();
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
      case TitleStatusConditions.Normal:
        return _i18n.get("connected");
      case TitleStatusConditions.Syncing:
        return _i18n.get("syncing");
    }
  }
}
