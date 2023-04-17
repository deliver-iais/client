import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'resizable_widget_args_info.dart';
import 'resizable_widget_child_data.dart';
import 'separator.dart';
import 'separator_args_info.dart';
import 'widget_size_info.dart';

typedef SeparatorFactory = Widget Function(SeparatorArgsBasicInfo basicInfo);

enum ResizableWidgetResizeImplReturnState { VALID, INVALID }

class ResizableWidgetResizeImplReturn {
  ResizableWidgetResizeImplReturnState state;
  double size;
  double percent;

  ResizableWidgetResizeImplReturn({
    required this.size,
    required this.percent,
    required this.state,
  });
}

class ResizableWidgetModel {
  final _i18n = GetIt.I.get<I18N>();
  final ResizableWidgetArgsInfo _info;
  final children = <ResizableWidgetChildData>[];
  double? maxSize;

  double? get maxSizeWithoutSeparators => maxSize == null
      ? null
      : maxSize! - (children.length ~/ 2) * _info.separatorSize;

  ResizableWidgetModel(this._info);

  void init(SeparatorFactory separatorFactory) {
    final originalChildren = _info.children;
    final size = originalChildren.length;
    final originalPercentages =
        _info.percentages ?? List.filled(size, 1 / size);
    final maxPercentages = _info.maxPercentages;
    final minPercentages = _info.minPercentages;
    for (var i = 0; i < size - 1; i++) {
      children
        ..add(
          ResizableWidgetChildData(
            originalChildren[i],
            originalPercentages[i],
            (maxPercentages != null ? maxPercentages[i] : null),
            (minPercentages != null ? minPercentages[i] : null),
          ),
        )
        ..add(
          ResizableWidgetChildData(
            separatorFactory.call(
              SeparatorArgsBasicInfo(
                2 * i + 1,
                _info.separatorSize,
                _info.separatorColor,
                isHorizontalSeparator: _info.isHorizontalSeparator,
                isDisabledSmartHide: _info.isDisabledSmartHide,
              ),
            ),
            null,
            null,
            null,
          ),
        );
    }
    children.add(
      ResizableWidgetChildData(
        originalChildren[size - 1],
        originalPercentages[size - 1],
        (maxPercentages != null ? maxPercentages[size - 1] : null),
        (minPercentages != null ? minPercentages[size - 1] : null),
      ),
    );
  }

  void setSizeIfNeeded(BoxConstraints constraints) {
    final max = _info.isHorizontalSeparator
        ? constraints.maxHeight
        : constraints.maxWidth;
    final isMaxSizeChanged = maxSize == null || maxSize! != max;
    if (!isMaxSizeChanged || children.isEmpty) {
      return;
    }

    maxSize = max;
    final remain = maxSizeWithoutSeparators!;

    for (final c in children) {
      if (c.widget is Separator) {
        c
          ..percentage = 0
          ..size = _info.separatorSize;
      } else {
        c
          ..size = remain * c.percentage!
          ..defaultPercentage = c.percentage;
      }
    }
  }

  void resize(int separatorIndex, Offset offset) {
    final directionFactor = _i18n.isPersian ? -1.0 : 1.0;

    final leftReturn =
        _resizeImpl(separatorIndex - 1, offset * directionFactor, apply: false);
    if (leftReturn.state != ResizableWidgetResizeImplReturnState.VALID) {
      return;
    }

    final rightReturn = _resizeImpl(
      separatorIndex + 1,
      offset * (-1) * directionFactor,
      apply: false,
    );
    if (rightReturn.state != ResizableWidgetResizeImplReturnState.VALID) {
      return;
    }
    __applyResizeImpl(separatorIndex - 1, leftReturn);
    __applyResizeImpl(separatorIndex + 1, rightReturn);

    if (leftReturn.size < 0) {
      _resizeImpl(
        separatorIndex - 1,
        _info.isHorizontalSeparator
            ? Offset(0, -leftReturn.size)
            : Offset(-leftReturn.size, 0),
      );
      _resizeImpl(
        separatorIndex + 1,
        _info.isHorizontalSeparator
            ? Offset(0, leftReturn.size)
            : Offset(leftReturn.size, 0),
      );
    }
    if (rightReturn.size < 0) {
      _resizeImpl(
        separatorIndex - 1,
        _info.isHorizontalSeparator
            ? Offset(0, rightReturn.size)
            : Offset(rightReturn.size, 0),
      );
      _resizeImpl(
        separatorIndex + 1,
        _info.isHorizontalSeparator
            ? Offset(0, -rightReturn.size)
            : Offset(-rightReturn.size, 0),
      );
    }
  }

  void callOnResized() {
    _info.onResized?.call(
      children
          .where((x) => x.widget is! Separator)
          .map((x) => WidgetSizeInfo(x.size!, x.percentage!))
          .toList(),
    );
  }

  ResizableWidgetResizeImplReturn _resizeImpl(
    int widgetIndex,
    Offset offset, {
    bool apply = true,
  }) {
    final size = children[widgetIndex].size ?? 0;
    final appliedSize =
        size + (_info.isHorizontalSeparator ? offset.dy : offset.dx);
    final appliedPercentage = size / maxSizeWithoutSeparators!;

    /// Check if transformation will exceed the requested Min / Max value for the specific row / column
    if (((children[widgetIndex].minPercentage != null) &&
            (children[widgetIndex].minPercentage! > appliedPercentage) &&
            (((!_info.isHorizontalSeparator) && (offset.dx < 0)) ||
                ((_info.isHorizontalSeparator) && (offset.dy < 0)))) ||
        ((children[widgetIndex].maxPercentage != null) &&
            (children[widgetIndex].maxPercentage! < appliedPercentage) &&
            (((!_info.isHorizontalSeparator) && (offset.dx > 0)) ||
                ((_info.isHorizontalSeparator) && (offset.dy > 0))))) {
      return ResizableWidgetResizeImplReturn(
        size: children[widgetIndex].size!,
        percent: children[widgetIndex].percentage!,
        state: ResizableWidgetResizeImplReturnState.INVALID,
      );
    }

    final data = ResizableWidgetResizeImplReturn(
      size: appliedSize,
      percent: appliedPercentage,
      state: ResizableWidgetResizeImplReturnState.VALID,
    );
    if (apply) {
      __applyResizeImpl(widgetIndex, data);
    }
    return data;
  }

  void __applyResizeImpl(
    int widgetIndex,
    ResizableWidgetResizeImplReturn data,
  ) {
    children[widgetIndex].size = data.size;
    children[widgetIndex].percentage = data.percent;
  }
}
