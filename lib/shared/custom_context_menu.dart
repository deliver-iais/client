import 'package:flutter/material.dart' hide showMenu;
import 'package:flutter/material.dart' as material show showMenu;

/// A mixin to provide convenience methods to record a tap position and show a popup menu.
mixin CustomPopupMenu<T extends StatefulWidget> on State<T> {
  late Offset _tapPosition;

  /// Pass this method to an onTapDown parameter to record the tap position.
  void storePosition(TapDownDetails details) =>
      _tapPosition = details.globalPosition;

  /// Use this method to show the menu.
  // ignore: avoid_shadowing_type_parameters
  Future<T?> showMenu<T>({
    required BuildContext context,
    required List<PopupMenuEntry<T>> items,
    T? initialValue,
    double? elevation,
    String? semanticLabel,
    ShapeBorder? shape,
    Color? color,
    bool captureInheritedThemes = true,
    bool useRootNavigator = false,
  }) {
    RenderObject? overlay = Overlay.of(context)!.context.findRenderObject();

    return material.showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        _tapPosition.dx,
        _tapPosition.dy - 30,
        overlay!.semanticBounds.size.width - _tapPosition.dx,
        overlay.semanticBounds.size.height + _tapPosition.dy,
      ),
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
