import 'package:deliver/shared/animation_settings.dart';
import 'package:flutter/material.dart';

class HorizontalListWidget extends StatefulWidget {
  final ScrollController controller;
  final double maxWidth;
  final Color primaryColor;
  final Color fadeLayoutColor;
  final Widget child;

  const HorizontalListWidget({
    Key? key,
    required this.controller,
    required this.maxWidth,
    required this.primaryColor,
    required this.fadeLayoutColor,
    required this.child,
  }) : super(key: key);

  @override
  HorizontalListWidgetState createState() => HorizontalListWidgetState();
}

class HorizontalListWidgetState extends State<HorizontalListWidget> {
  bool _isEndOfTheList = false;
  bool _isFirstOfTheList = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.controller.positions.isNotEmpty &&
          widget.controller.position.maxScrollExtent > 0) {
        setState(() {});
      }
    });
    widget.controller.addListener(() {
      if (widget.controller.position.maxScrollExtent <=
          widget.controller.position.pixels) {
        setState(() {
          _isFirstOfTheList = false;
          _isEndOfTheList = true;
        });
      } else if (widget.controller.position.pixels <= 0) {
        setState(() {
          _isFirstOfTheList = true;
          _isEndOfTheList = false;
        });
      } else if (widget.controller.position.pixels > 0) {
        setState(() {
          _isFirstOfTheList = false;
          _isEndOfTheList = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (!_isFirstOfTheList) fadeLayout(isLeftPosition: true),
        if (!_isFirstOfTheList)
          arrowIcon(
            arrowIcon: Icons.arrow_back_ios_outlined,
            isLeftPosition: true,
          ),
        if (!_isEndOfTheList) fadeLayout(),
        if (!_isEndOfTheList)
          arrowIcon(
            arrowIcon: Icons.arrow_forward_ios,
          ),
      ],
    );
  }

  Widget arrowIcon({required IconData arrowIcon, bool isLeftPosition = false}) {
    if (widget.controller.hasClients &&
        widget.controller.position.maxScrollExtent > 0) {
      return Positioned(
        left: isLeftPosition ? 0 : null,
        right: isLeftPosition ? null : 0,
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: widget.primaryColor.withOpacity(0.25),
            foregroundColor: widget.primaryColor.withOpacity(0.9),
            minimumSize: const Size.square(20),
            maximumSize: const Size.square(30),
            fixedSize: const Size.square(30),
            padding: const EdgeInsets.all(5),
          ),
          iconSize: 20,
          icon: Icon(arrowIcon),
          onPressed: () {
            widget.controller.animateTo(
              isLeftPosition
                  ? widget.controller.position.pixels - widget.maxWidth * 0.7
                  : widget.controller.position.pixels + widget.maxWidth * 0.7,
              duration: AnimationSettings.superSlow,
              curve: Curves.ease,
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget fadeLayout({
    bool isLeftPosition = false,
  }) {
    if (widget.controller.hasClients &&
        widget.controller.position.maxScrollExtent > 0) {
      return Positioned(
        left: isLeftPosition ? 0 : null,
        right: isLeftPosition ? null : 0,
        width: 60,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin:
                  isLeftPosition ? Alignment.centerLeft : Alignment.centerRight,
              end:
                  isLeftPosition ? Alignment.centerRight : Alignment.centerLeft,
              stops: const [0, 0.6, 1],
              colors: [
                widget.fadeLayoutColor,
                widget.fadeLayoutColor.withOpacity(0.5),
                widget.fadeLayoutColor.withOpacity(0),
              ],
            ),
          ),
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
