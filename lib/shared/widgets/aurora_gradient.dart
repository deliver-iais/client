
import 'package:aurora/aurora.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class AuroraGradient extends StatefulWidget {
  const AuroraGradient({
    super.key,
  });

  @override
  AuroraGradientState createState() => AuroraGradientState();
}

class AuroraGradientState extends State<AuroraGradient>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController
          ..reset()
          ..forward();
      }
    });

    _animationController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return settings.showCallBackGroundAnimation.value
        ? AnimatedAurora(
            animation: _animation,
          )
        : NonAnimatedAurora();
  }
}

class AnimatedAurora extends AnimatedWidget {
  static final _callRepo = GetIt.I.get<CallRepo>();

  const AnimatedAurora({
    super.key,
    required Animation<double> animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF595cff), Color(0xFFc6f8ff)],
          ),
        ),
        child: StreamBuilder<bool>(
          stream: _callRepo.isConnectedSubject,
          initialData: false,
          builder: (context, snapshot) {
            final multiply =
                (snapshot.data! ? 1.0 : 0.3) + (isLarge(context) ? 0.4 : 0.0);
            final animation = listenable as Animation<double>;
            final animation1 =
                Curves.easeInOutBack.transform(animation.value) * 250;
            final animation2 =
                Curves.easeInOutCirc.transform(animation.value) * 200;
            final animation3 =
                Curves.easeInOutQuad.transform(animation.value) * 300;
            final animation4 =
                Curves.easeInOut.transform(animation.value) * 400 * multiply;
            return AnimatedScale(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              scale: multiply,
              child: NonAnimatedAurora(
                animation1: animation1,
                animation2: animation2,
                animation3: animation3,
                animation4: animation4,
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget NonAnimatedAurora({
  double animation1 = 0.0,
  double animation2 = 0.0,
  double animation3 = 0.0,
  double animation4 = 0.0,
}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        top: -10 - animation1 / 4,
        left: -50 - animation1 / 4,
        child: Aurora(
          size: 500 + animation1 / 2,
          colors: const [
            Color(0xFFf74c06),
            Color(0xFFf9bc2c),
          ],
        ),
      ),
      Positioned(
        top: -20 - animation2 / 4,
        right: -50 + animation2 / 4,
        child: Aurora(
          size: 300 + animation2,
          colors: const [
            Color(0xFFf3f520),
            Color(0xFF59d102),
          ],
        ),
      ),
      Positioned(
        bottom: -100,
        right: -300,
        child: Aurora(
          size: 500 + animation3,
          colors: const [Color(0xFFff0f7b), Color(0xFFf89b29)],
        ),
      ),
      Positioned(
        bottom: -50 + animation4 / 3,
        left: -50 + animation4 / 3,
        child: Aurora(
          size: 400 + animation4,
          colors: const [Color(0xFFf44369), Color(0xFF3e3b92)],
        ),
      ),
    ],
  );
}
