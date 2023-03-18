import 'package:clock/clock.dart';
import 'package:confetti/confetti.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/screen/navigation_center/events/count_down_timer.dart';
import 'package:deliver/services/event_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rive/rive.dart';
import 'package:rxdart/rxdart.dart';

class HasEventsRow extends StatefulWidget {
  final int timeStamp;
  final String textBeforeTimeStamp;
  final String textAfterTimeStamp;
  final ConfettiController? controllerCenter;

  const HasEventsRow({
    super.key,
    required this.timeStamp,
    required this.textBeforeTimeStamp,
    required this.textAfterTimeStamp,
    this.controllerCenter,
  });

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

  @override
  void initState() {
    if (widget.timeStamp < clock.now().millisecondsSinceEpoch) {
      timeStampFired.add(true);
    }
    _expandableController.addListener(() {
      _isOpened = !_isOpened;
      if (_isOpened) widget.controllerCenter?.play();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController(artboard.stateMachines.first);
    artboard.addController(controller);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      initialData: false,
      stream: timeStampFired.stream,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: smallBorder,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 5,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            child: ExpandableNotifier(
              controller: _expandableController,
              child: snapshot.data!
                  ? Expandable(
                      collapsed: ExpandableButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SvgPicture.asset(
                              'assets/images/norouz.svg',
                              semanticsLabel: "norouz",
                              width: 40,
                              height: 40,
                            ),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: RiveAnimation.asset(
                                  'assets/animations/happy.riv',
                                  // Update the play state when the widget's initialized
                                  onInit: _onRiveInit,
                                ),
                              ),
                            ),
                            Text(
                              widget.textAfterTimeStamp,
                              style: theme.textTheme.titleSmall!
                                  .copyWith(height: 1.5),
                            ),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: RiveAnimation.asset(
                                  'assets/animations/happy.riv',
                                  // Update the play state when the widget's initialized
                                  onInit: _onRiveInit,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      expanded: ExpandableButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Ws.asset(
                              'assets/animations/norouz.ws',
                              width: 180,
                              height: 150,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expandable(
                      collapsed: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SvgPicture.asset(
                                'assets/images/norouz.svg',
                                semanticsLabel: "norouz",
                                width: 30,
                                height: 30,
                              ),
                              Text(
                                widget.textBeforeTimeStamp,
                                style: theme.textTheme.titleSmall!
                                    .copyWith(height: 1.5),
                              ),
                              CountDownTimer(
                                timeStamp: widget.timeStamp,
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
                                return const SizedBox.shrink();
                              }
                              return LinearPercentIndicator(
                                percent: ((60 - snapshot.data!.minutes) / 60),
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.all(0),
                                progressColor: detectBackGroundColorProgressBar(
                                  snapshot.data!.minutes,
                                ),
                              );
                            },
                          )
                        ],
                      ),
                      expanded: const SizedBox.shrink(),
                    ),
            ),
          ),
        );
      },
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
