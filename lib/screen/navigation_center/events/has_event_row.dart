import 'package:clock/clock.dart';
import 'package:confetti/confetti.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/screen/navigation_center/events/count_down_timer.dart';
import 'package:deliver/services/event_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rive/rive.dart';
import 'package:rxdart/rxdart.dart';

class HasEventsRow extends StatefulWidget {
  const HasEventsRow({super.key});

  @override
  HasEventsRowState createState() => HasEventsRowState();
}

class HasEventsRowState extends State<HasEventsRow> {
  static final _eventService = GetIt.I.get<EventService>();
  final BehaviorSubject<bool> timeStampFired = BehaviorSubject.seeded(false);
  bool _isOpened = false;
  late final ExpandableController _expandableController = ExpandableController(
    initialExpanded: _isOpened,
  );
  late final ConfettiController _controllerCenter;

  final _eventTime = DateTime(2023, 3, 21, 0, 54, 29).millisecondsSinceEpoch;
  // ignore: avoid_redundant_argument_values
  final _finalDay = DateTime(2023, 4, 3, 0, 0, 0).millisecondsSinceEpoch;

  @override
  void initState() {
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 5));
    if (_eventTime < clock.now().millisecondsSinceEpoch) {
      timeStampFired.add(true);
    }
    _expandableController.addListener(() {
      _isOpened = !_isOpened;
      if (_isOpened) _controllerCenter.play();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController(artboard.stateMachines.first);
    artboard.addController(controller);
  }

  @override
  Widget build(BuildContext context) {
    if (_finalDay < clock.now().millisecondsSinceEpoch) {
      return const SizedBox();
    }

    final theme = Theme.of(context);
    return Stack(
      children: [
        Align(
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirectionality: BlastDirectionality.explosive,
            // start again as soon as the animation is finished
            colors: const [
              Colors.greenAccent,
              Colors.lightBlue,
              Colors.pinkAccent,
              Colors.deepOrange,
              Colors.purple,
              Colors.white
            ],
            // manually specify the colors to be used
            createParticlePath: drawStar, // define a custom shape/path.
          ),
        ),
        StreamBuilder<bool>(
          initialData: false,
          stream: timeStampFired.stream,
          builder: (context, snapshot) {
            return ExpandableNotifier(
              controller: _expandableController,
              child: snapshot.data!
                  ? Expandable(
                      collapsed: Container(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        child: ExpandableButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              Container(
                                transform: Matrix4.translationValues(0, -5, 0),
                                height: 40,
                                width: 40,
                                child: RiveAnimation.asset(
                                  'assets/animations/happy.riv',
                                  fit: BoxFit.fitWidth,
                                  // Update the play state when the widget's initialized
                                  onInit: _onRiveInit,
                                ),
                              ),
                              const Spacer(),
                              Image.asset(
                                'assets/images/norouz.webp',
                                width: 60,
                              ),
                              Text(
                                'سال نو مبارک',
                                style: theme.textTheme.titleSmall!
                                    .copyWith(height: 1.5),
                              ),
                              const Spacer(),
                              Container(
                                transform: Matrix4.translationValues(0, -5, 0),
                                height: 40,
                                width: 40,
                                child: RiveAnimation.asset(
                                  'assets/animations/happy.riv',
                                  fit: BoxFit.fitWidth,
                                  // Update the play state when the widget's initialized
                                  onInit: _onRiveInit,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                      expanded: ExpandableButton(
                        child: Container(
                          padding: const EdgeInsets.only(top: 8.0),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Ws.asset(
                                'assets/animations/norouz.ws',
                                width: 190,
                                // height: 150,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Expandable(
                      collapsed: Container(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                  'assets/images/norouz.webp',
                                  width: 60,
                                ),
                                Text(
                                  "تا تحویل سال نو",
                                  style: theme.textTheme.titleSmall!
                                      .copyWith(height: 1.5),
                                ),
                                CountDownTimer(
                                  timeStamp: _eventTime,
                                  timeStampFired: timeStampFired,
                                ),
                              ],
                            ),
                            StreamBuilder<CountTimer>(
                              stream: _eventService.getEventTimerStream(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.days > 0 ||
                                    snapshot.data!.hours > 0) {
                                  return const SizedBox(height: 3);
                                }
                                return LinearPercentIndicator(
                                  lineHeight: 3,
                                  percent: ((60 - snapshot.data!.minutes) / 60),
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.all(0),
                                  progressColor:
                                      detectBackGroundColorProgressBar(
                                    snapshot.data!.minutes,
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      expanded: const SizedBox.shrink(),
                    ),
            );
          },
        ),
      ],
    );
  }

  Color detectBackGroundColorProgressBar(int remindingMinutes) {
    if (remindingMinutes > 30) {
      return backgroundColorCard;
    } else if (remindingMinutes > 10) {
      return Colors.yellowAccent;
    } else if (remindingMinutes > 5) {
      return Colors.deepOrangeAccent;
    } else {
      return Colors.red;
    }
  }
}
