import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollMessageList extends StatefulWidget {
  final double heightScrollThumb;
  final Widget child;
  final int itemCount;

  final ItemScrollController controller;
  final ItemPositionsListener itemPositionsListener;

  const DraggableScrollbar(
      {Key? key,
        required this.heightScrollThumb,
        required this.child,
        required this.itemCount,
        required this.controller,
        required this.itemPositionsListener})
      : super(key: key);

  @override
  _DraggableScrollbarState createState() => _DraggableScrollbarState();
}

class _DraggableScrollbarState extends State<DraggableScrollbar> {
  late double _barOffset;

  bool _startScroll = false;

  int _index = 0;

  final BehaviorSubject<double> _botton = BehaviorSubject.seeded(0.0);

  @override
  void initState() {
    super.initState();
    _barOffset = 0.0;
    widget.itemPositionsListener.itemPositions.addListener(() {
      if (!_startScroll) _restPosition();
    });
  }

  _restPosition() {
    List<ItemPosition> res =
    widget.itemPositionsListener.itemPositions.value.toList();
    res.sort((a, b) => (b.index) - (a.index));
    double h = ((((widget.itemCount - res.first.index) / widget.itemCount) *
        MediaQuery.of(context).size.height));
    _botton.add(h);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _startScroll = true;

    List<ItemPosition> l =
    widget.itemPositionsListener.itemPositions.value.toList();
    l.sort((a, b) => (b.index) - (a.index));
    if (_index <= 0) {
      _index = l.last.index;
    }

    if (details.delta.dy > 0) {
      _index = _index++;
    } else {
      _index = _index--;
    }

    if (_index <= 0 || _index >= widget.itemCount) {
      return;
    }

    _barOffset = ((((widget.itemCount - _index) / widget.itemCount) *
        (MediaQuery.of(context).size.height)));

    _botton.add(_barOffset);

    widget.controller.jumpTo(index: _index, alignment: 0.5);
    _startScroll = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: widget.child,
      ),
      StreamBuilder<double>(
          stream: _botton.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Positioned(
                right: 2.0,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: max(
                          MediaQuery.of(context).size.height -
                              snapshot.data! -
                              160,
                          5),
                      bottom: snapshot.data!),
                  child: GestureDetector(
                      onVerticalDragUpdate: _onVerticalDragUpdate,
                      onVerticalDragCancel: () => _startScroll = false,
                      onVerticalDragDown: (d) => _startScroll = false,
                      child: _buildScrollThumb()),
                ),
              );
            }
            return SizedBox.shrink();
          }),
    ]);
  }

  Widget _buildScrollThumb() {
    return Container(
      height: 60,
      width: 8,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }