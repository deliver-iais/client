import 'package:deliver/shared/widgets/blur_widget/blur_menu_card.dart';
import 'package:flutter/material.dart';

class BlurPopupMenuCard<T> extends PopupMenuEntry<T> {
  final List<PopupMenuEntry> items;

  const BlurPopupMenuCard({
    required this.items,
    super.key,
  });

  @override
  BlurPopupMenuCardState createState() => BlurPopupMenuCardState();

  @override
  double get height => 100;

  @override
  bool represents(T? value) {
    return false;
  }
}

class BlurPopupMenuCardState extends State<BlurPopupMenuCard> {
  @override
  Widget build(BuildContext context) {
    return BlurMenuCard(
      child: IconTheme(
        data: IconThemeData(
          size: (PopupMenuTheme.of(context).textStyle?.fontSize ?? 20) + 4,
          color: PopupMenuTheme.of(context).textStyle?.color,
        ),
        child: Column(
          children: widget.items,
        ),
      ),
    );
  }
}
