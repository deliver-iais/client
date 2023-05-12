import 'dart:async';

import 'package:deliver/shared/widgets/resizable/resizable_widget_args_info.dart';
import 'package:deliver/shared/widgets/resizable/resizable_widget_child_data.dart';
import 'package:deliver/shared/widgets/resizable/resizable_widget_model.dart';
import 'package:deliver/shared/widgets/resizable/separator.dart';
import 'package:deliver/shared/widgets/resizable/separator_args_info.dart';
import 'package:flutter/material.dart';

class ResizableWidgetController {
  final eventStream = StreamController<Object>();
  final ResizableWidgetModel _model;

  List<ResizableWidgetChildData> get children => _model.children;

  ResizableWidgetController(ResizableWidgetArgsInfo info)
      : _model = ResizableWidgetModel(info) {
    _model.init(_separatorFactory);
  }

  void setSizeIfNeeded(BoxConstraints constraints) {
    _model.setSizeIfNeeded(constraints);
  }

  void resize(
    int separatorIndex,
    Offset offset, {
    bool shouldCallOnResize = true,
  }) {
    _model.resize(separatorIndex, offset);

    eventStream.add(this);

    if (shouldCallOnResize) {
      _model.callOnResized();
    }
  }

  Widget _separatorFactory(SeparatorArgsBasicInfo basicInfo) {
    return Separator(SeparatorArgsInfo(this, basicInfo));
  }
}
