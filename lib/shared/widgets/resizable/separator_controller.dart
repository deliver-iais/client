import 'package:deliver/shared/widgets/resizable/resizable_widget_controller.dart';
import 'package:flutter/material.dart';

class SeparatorController {
  final int _index;
  final ResizableWidgetController _parentController;

  const SeparatorController(this._index, this._parentController);

  void onPanUpdate(DragUpdateDetails details, BuildContext context) {
    _parentController.resize(_index, details.delta);
  }
}
