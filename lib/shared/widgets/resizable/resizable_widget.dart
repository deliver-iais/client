import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/resizable/resizable_widget_args_info.dart';
import 'package:deliver/shared/widgets/resizable/resizable_widget_child_data.dart';
import 'package:deliver/shared/widgets/resizable/resizable_widget_controller.dart';
import 'package:deliver/shared/widgets/resizable/separator.dart';
import 'package:deliver/shared/widgets/resizable/widget_size_info.dart';
import 'package:flutter/material.dart';

/// The callback argument type of [ResizableWidget.onResized].
typedef OnResizedFunc = void Function(List<WidgetSizeInfo> infoList);

/// Holds resizable widgets as children.
/// Users can resize the internal widgets by dragging.
class ResizableWidget extends StatefulWidget {
  /// Resizable widget list.
  final List<Widget> children;

  /// Sets the default [children] width or height as percentages.
  ///
  /// If you set this value,
  /// the length of [percentages] must match the one of [children],
  /// and the sum of [percentages] must be equal to 1.
  ///
  /// If this value is [null], [children] will be split into the same size.
  final List<double>? percentages;

  /// Applies a Maximum Percent of the screen each widget can occupy
  /// At least one element must be set to double.infinity
  final List<double?>? maxPercentages;

  /// Applies a Minimum Percent of the screen each widget can occupy
  /// At least one element must be set to 0.0
  final List<double?>? minPercentages;

  /// When set to true, creates horizontal separators.
  final bool isHorizontalSeparator;

  /// When set to true, Smart-Hide-Function is disabled.
  ///
  /// Smart-Hide-Function is that users can hide / show the both ends widgets
  /// by double-clicking the separators.
  final bool isDisabledSmartHide;

  /// Separator size.
  final double separatorSize;

  /// Separator color.
  final Color separatorColor;

  /// Callback of the resizing event.
  /// You can get the size and percentage of the internal widgets.
  ///
  /// Note that [onResized] is called every frame when resizing [children].
  final OnResizedFunc? onResized;

  /// Creates [ResizableWidget].
  ResizableWidget({
    Key? key,
    required this.children,
    this.percentages,
    this.maxPercentages,
    this.minPercentages,
    this.isHorizontalSeparator = false,
    this.isDisabledSmartHide = false,
    this.separatorSize = 4,
    this.separatorColor = Colors.white12,
    this.onResized,
  }) : super(key: key) {
    assert(children.isNotEmpty);
    assert(percentages == null || percentages!.length == children.length);
    assert(
      percentages == null ||
          percentages!.reduce((value, element) => value + element) == 1,
    );
    assert(maxPercentages == null || maxPercentages!.contains(double.infinity));
    assert(
      minPercentages == null ||
          minPercentages!.reduce((value, element) => value! + element!)! < 1,
    );
  }

  @override
  ResizableWidgetState createState() => ResizableWidgetState();
}

class ResizableWidgetState extends State<ResizableWidget> {
  late ResizableWidgetArgsInfo _info;
  late ResizableWidgetController controller;

  @override
  void initState() {
    super.initState();

    _info = ResizableWidgetArgsInfo(widget);
    controller = ResizableWidgetController(_info);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          controller.setSizeIfNeeded(constraints);
          return StreamBuilder(
            stream: controller.eventStream.stream,
            builder: (context, snapshot) => _info.isHorizontalSeparator
                ? Column(
                    children: controller.children.map(_buildChild).toList(),
                  )
                : Row(
                    children: normalizeVertical(controller.children)
                        .map(_buildChild)
                        .toList(),
                  ),
          );
        },
      );

  List<ResizableWidgetChildData> normalizeVertical(
    List<ResizableWidgetChildData> children,
  ) {
    const minSize = NAVIGATION_PANEL_MIN_WIDTH;

    final wholeSize = children.fold<double>(
      0.0,
      (previousValue, element) => previousValue + (element.size ?? 0),
    );

    final separatorCount = children
        .where(
          (c) => c.widget is Separator,
        )
        .length;

    final validChildrenCount = children.length - separatorCount;

    if (minSize * validChildrenCount >= wholeSize) {
      return children
          .map((e) => e..size = wholeSize / children.length)
          .toList();
    } else {
      var dept = 0.0;

      for (final child in children) {
        if (child.widget is Separator) {
          continue;
        }

        if ((child.size ?? 0) < minSize) {
          dept += minSize - (child.size ?? 0);
          child.size = minSize;
        }
      }

      for (final child in children) {
        if (child.widget is Separator) {
          continue;
        }

        if ((child.size ?? 0) > minSize) {
          final availableResource = (child.size ?? 0) - minSize;

          if (dept < availableResource) {
            child.size = (child.size ?? 0) - dept;
            dept = 0;
            break;
          } else {
            dept -= availableResource;
            child.size = (child.size ?? 0) - availableResource;
          }
        }
      }
    }

    return children;
  }

  Widget _buildChild(ResizableWidgetChildData child) {
    if (child.widget is Separator) {
      return child.widget;
    }

    return SizedBox(
      width: _info.isHorizontalSeparator ? double.infinity : child.size,
      height: _info.isHorizontalSeparator ? child.size : double.infinity,
      child: child.widget,
    );
  }
}
