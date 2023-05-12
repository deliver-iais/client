import 'package:deliver/shared/widgets/resizable/resizable_widget.dart';
import 'package:flutter/material.dart';

class ResizableWidgetArgsInfo {
  final List<Widget> children;
  final List<double>? percentages;
  final List<double?>? maxPercentages;
  final List<double?>? minPercentages;
  final bool isHorizontalSeparator;
  final bool isDisabledSmartHide;
  final double separatorSize;
  final Color separatorColor;
  final OnResizedFunc? onResized;

  ResizableWidgetArgsInfo(ResizableWidget widget)
      : children = widget.children,
        percentages = widget.percentages,
        maxPercentages = widget.maxPercentages,
        minPercentages = widget.minPercentages,
        isHorizontalSeparator = widget.isHorizontalSeparator,
        isDisabledSmartHide = widget.isDisabledSmartHide,
        separatorSize = widget.separatorSize,
        separatorColor = widget.separatorColor,
        onResized = widget.onResized;
}
