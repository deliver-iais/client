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
  }) {
    final screenSize = MediaQuery.of(context).size;

    final overlaySize =
        Overlay.of(context)!.context.findRenderObject()!.semanticBounds.size;

    final dx = screenSize.width - overlaySize.width;
    final dy = screenSize.height - overlaySize.height;

    final position = RelativeRect.fromLTRB(
      _tapPosition.dx - dx,
      _tapPosition.dy - 5 - dy,
      overlaySize.width,
      overlaySize.height,
    );

    return material.showMenu<T>(
      context: context,
      position: position,
      items: items,
      elevation: 4,
    );
  }
}
