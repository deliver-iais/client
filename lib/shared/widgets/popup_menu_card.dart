import 'package:flutter/material.dart';

class PopupMenuCard<T> extends PopupMenuEntry<T> {
  final List<PopupMenuEntry> items;

  const PopupMenuCard({
    required this.items,
    super.key,
  });

  @override
  PopupMenuCardState createState() => PopupMenuCardState();

  @override
  double get height => 100;

  @override
  bool represents(T? value) {
    return false;
  }
}

class PopupMenuCardState extends State<PopupMenuCard> {
  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconTheme.of(context).copyWith(
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Column(children: widget.items),
    );
  }
}
