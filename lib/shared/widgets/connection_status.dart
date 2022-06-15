import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ConnectionStatus extends StatelessWidget {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _coreServices = GetIt.I.get<CoreServices>();
  final _countDownController = CountDownController();

  ConnectionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<TitleStatusConditions>(
      initialData: TitleStatusConditions.Normal,
      stream: _messageRepo.updatingStatus.stream,
      builder: (context, snapshot) {
        return AnimatedContainer(
          width: double.infinity,
          height: snapshot.data == TitleStatusConditions.Normal ? 0 : 38,
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
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
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
              StreamBuilder<int>(
                initialData: 0,
                stream: disconnectedTime.stream,
                builder: (c, timeSnapShot) {
                  if (timeSnapShot.hasData &&
                      timeSnapShot.data != null &&
                      timeSnapShot.data! > 0) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircularCountDownTimer(
                          key: Key(
                            DateTime.now().millisecondsSinceEpoch.toString(),
                          ),
                          duration: timeSnapShot.data!,
                          controller: _countDownController,
                          width: 25,
                          strokeWidth: 3,
                          height: 25,
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
                          },
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            _coreServices.retryFasterConnection();
                          },
                          child: Icon(
                            CupertinoIcons.arrow_clockwise,
                            color: theme.primaryColor,
                            size: 24,
                          ),
                        )
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              )
            ],
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
      case TitleStatusConditions.Normal:
        return _i18n.get("connected");
    }
  }
}
