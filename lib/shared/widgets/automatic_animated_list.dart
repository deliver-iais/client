import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

const Duration _kDuration = Duration(milliseconds: 300);

class Update<T> {
  final List<T> list;
  final List<Key>? onlyChanges;

  Update(this.list, this.onlyChanges);
}

class AutomaticAnimatedListController<T> {
  late final _subject = BehaviorSubject<Update<T>>.seeded(Update([], null));

  ValueStream<Update<T>> get stream => _subject.stream;

  List<T> get values => _subject.value.list;

  void update(List<T> list, {List<Key>? onlyChanges}) {
    _subject.add(Update(list, onlyChanges));
  }
}

@Deprecated("great_list_view is better implementation")
class AutomaticAnimatedList<T> extends StatefulWidget {
  const AutomaticAnimatedList({
    Key? key,
    required this.itemBuilder,
    required this.keyingFunction,
    required this.automaticAnimatedListController,
    required this.changeKeyingFunction,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.insertDuration = _kDuration,
    this.removeDuration = _kDuration,
  }) : super(key: key);

  final Widget Function(BuildContext, T, Animation<double>) itemBuilder;
  final Key Function(T item) keyingFunction;
  final dynamic Function(T item) changeKeyingFunction;
  final AutomaticAnimatedListController<T> automaticAnimatedListController;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  final Duration insertDuration;
  final Duration removeDuration;

  @override
  _AutomaticAnimatedListState<T> createState() =>
      _AutomaticAnimatedListState<T>();
}

class _AutomaticAnimatedListState<T> extends State<AutomaticAnimatedList<T>> {
  List<T> list = [];
  late final StreamSubscription<Update<T>> streamSubscription;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  static final Function eq = const ListEquality().equals;

  Set<Key> lcsDynamic(List<T> a, List<T> b) {
    final key = widget.keyingFunction;

    var lengths = List<List<int>>.generate(
        a.length + 1, (_) => List.filled(b.length + 1, 0),
        growable: false);

    // row 0 and column 0 are initialized to 0 already
    for (int i = 0; i < a.length; i++) {
      for (int j = 0; j < b.length; j++) {
        if (key(a[i]) == key(b[j])) {
          lengths[i + 1][j + 1] = lengths[i][j] + 1;
        } else {
          lengths[i + 1][j + 1] = max(lengths[i + 1][j], lengths[i][j + 1]);
        }
      }
    }

    // read the substring out from the matrix
    Set<Key> reversedLcsBuffer = {};
    for (int x = a.length, y = b.length; x != 0 && y != 0;) {
      if (lengths[x][y] == lengths[x - 1][y]) {
        x--;
      } else if (lengths[x][y] == lengths[x][y - 1]) {
        y--;
      } else {
        reversedLcsBuffer.add(key(a[x - 1]));
        x--;
        y--;
      }
    }

    return reversedLcsBuffer;
  }

  removeItem(int index, T element) {
    _listKey.currentState?.removeItem(index,
        (context, animation) => widget.itemBuilder(context, element, animation),
        duration: widget.removeDuration);
  }

  insertItem(int index) {
    _listKey.currentState?.insertItem(index, duration: widget.insertDuration);
  }

  @override
  void initState() {
    super.initState();

    streamSubscription =
        widget.automaticAnimatedListController.stream.listen((update) {
      // Fast Change Detector
      if (eq(list.map((e) => widget.keyingFunction(e)).toList(),
          update.list.map((e) => widget.keyingFunction(e)).toList())) {
        return;
      }

      late final Set<Key> commons;

      if (update.onlyChanges != null && update.onlyChanges!.isNotEmpty) {
        commons = update.list
            .where((element) =>
                !update.onlyChanges!.contains(widget.keyingFunction(element)))
            .fold(<Key>{},
                (value, element) => value..add(widget.keyingFunction(element)));
      } else {
        commons = lcsDynamic(list, update.list);
      }

      for (int i = 0; i < list.length && list.isNotEmpty; i++) {
        final element = list[i];
        if (!commons.contains(widget.keyingFunction(element))) {
          list.removeAt(i);
          removeItem(i, element);
          i--;
        }
      }

      update.list.forEachIndexed((index, element) {
        if (!commons.contains(widget.keyingFunction(element))) {
          list.insert(index, element);
          insertItem(index);
        }
      });

      list = list;
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemBuilder: (BuildContext context, int index, Animation animation) =>
          widget.itemBuilder(
              context, list[index], animation as Animation<double>),
    );
  }
}
