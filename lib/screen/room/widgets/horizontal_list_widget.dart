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
      if (widget.controller.position.maxScrollExtent > 0) {
        setState(() {});
      }
    });
    widget.controller.addListener(() {
      if (widget.controller.position.maxScrollExtent ==
          widget.controller.position.pixels) {
        setState(() {
          _isFirstOfTheList = false;
          _isEndOfTheList = true;
        });
      } else if (widget.controller.position.pixels == 0) {
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
        if (!_isFirstOfTheList)
          fadeLayout(
            isLeftPosition: true,
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: widget.primaryColor.withAlpha(100),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: IconButton(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(),
              icon: Icon(
                arrowIcon,
                color: widget.primaryColor,
              ),
              onPressed: () {
                widget.controller.animateTo(
                  isLeftPosition
                      ? widget.controller.position.pixels -
                          widget.maxWidth * 0.7
                      : widget.controller.position.pixels +
                          widget.maxWidth * 0.7,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
            ),
          ),
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
              colors: [
                widget.fadeLayoutColor,
                widget.fadeLayoutColor.withAlpha(80),
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
