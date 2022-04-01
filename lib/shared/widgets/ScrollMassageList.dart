import 'dart:math';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollMessageList extends StatefulWidget {
  final Widget child;
  final int itemCount;

  final ItemScrollController controller;
  final ItemPositionsListener itemPositionsListener;

  const ScrollMessageList(
      {Key? key,
      required this.child,
      required this.itemCount,
      required this.controller,
      required this.itemPositionsListener})
      : super(key: key);

  @override
  _ScrollMessageListState createState() => _ScrollMessageListState();
}

class _ScrollMessageListState extends State<ScrollMessageList> {
  double _barOffset = 0.0;
  int _index = 0;
  bool _startScroll = false;

  double height = 165;
  final BehaviorSubject<double> _bottom = BehaviorSubject.seeded(0.0);

  @override
  void initState() {
    super.initState();
    widget.itemPositionsListener.itemPositions.addListener(() {
      if (!_startScroll) _restPosition();
    });
  }

  _restPosition() {
    List<ItemPosition> pos =
        widget.itemPositionsListener.itemPositions.value.toList();
    pos.sort((a, b) => (b.index) - (a.index));
    double h = ((((widget.itemCount - pos.first.index) / widget.itemCount) *
        MediaQuery.of(context).size.height));
    _barOffset = h;
    _bottom.add(h);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    var h = MediaQuery.of(context).size.height;
    _startScroll = true;
    _barOffset = min(_barOffset - details.delta.dy, h - height);

    if (_barOffset >= 0) {
      double k = h - _barOffset;
      if (details.delta.dy < 0) {
        k = k - height;
      }
      _index = max((((k) / h) * widget.itemCount).ceil(), 1);

      _bottom.add(_barOffset);
      widget.controller.jumpTo(index: _index, alignment: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isDesktop()
        ? widget.child
        : Stack(children: <Widget>[
            ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: widget.child,
            ),
            StreamBuilder<double>(
                stream: _bottom.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Positioned(
                      right: 2.0,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: max(
                                MediaQuery.of(context).size.height -
                                    snapshot.data! -
                                    height,
                                2),
                            bottom: snapshot.data!),
                        child: GestureDetector(
                            onVerticalDragUpdate: _onVerticalDragUpdate,
                            onVerticalDragEnd: (d) => _startScroll = false,
                            onVerticalDragCancel: () => _startScroll = false,
                            onVerticalDragDown: (d) => _startScroll = false,
                            child: _buildScroll()),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
          ]);
  }

  Widget _buildScroll() {
    return Container(
      height: min(60, widget.itemCount.toDouble()),
      width: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
