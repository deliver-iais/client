import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart' hide showMenu;
import 'package:flutter/material.dart' as material show showMenu;

/// A mixin to provide convenience methods to record a tap position and show a popup menu.
mixin CustomPopupMenu<T extends StatefulWidget> on State<T> {
  late Offset _tapPosition;

  /// Pass this method to an onTapDown parameter to record the tap position.
  // ignore: type_annotate_public_apis
  void storePosition(details) {
    if (details is TapDownDetails ||
        details is DragDownDetails ||
        details is TapUpDetails) {
      // ignore: avoid_dynamic_calls
      _tapPosition = details.globalPosition;
    }
  }

  /// Use this method to show the menu.
  // ignore: avoid_shadowing_type_parameters
  Future<T?> showMenu<T>({
    required BuildContext context,
    required List<PopupMenuEntry<T>> items,
    Offset offset = Offset.zero,
    T? initialValue,
    double elevation = 4,
    String? semanticLabel,
    ShapeBorder? shape,
    Color? color,
    bool captureInheritedThemes = true,
    bool useRootNavigator = false,
  }) {
    final m = MediaQuery.of(context);

    final position = RelativeRect.fromSize(
      _tapPosition.translate(offset.dx, offset.dy) & const Size(0, 0),
      m.size,
    );

    return material.showMenu<T>(
      context: context,
      position: position,
      items: items,
      initialValue: initialValue,
      elevation: elevation,
      semanticLabel: semanticLabel,
      shape: shape,
      color: color,
      // captureInheritedThemes: captureInheritedThemes,
      useRootNavigator: useRootNavigator,
    );
  }
}
