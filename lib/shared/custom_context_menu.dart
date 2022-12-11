import 'package:deliver/shared/widgets/blur_widget/blur_popup_menu_card.dart';
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
    TextDirection? textDirection,
    double? start,
    double? top
  }) {
    final screenSize = MediaQuery.of(context).size;

    final overlaySize =
        Overlay.of(context)!.context.findRenderObject()!.semanticBounds.size;

    final dx = screenSize.width - overlaySize.width;
    final dy = screenSize.height - overlaySize.height;
    final position;
    if(textDirection != null) {
      position = RelativeRect.fromDirectional(
        start: start ?? (_tapPosition.dx - dx),
        top: top ?? (_tapPosition.dy - dy),
        end: overlaySize.width,
        bottom: overlaySize.height,
        textDirection: textDirection!,
      );
    }else{
      position = RelativeRect.fromLTRB(
        _tapPosition.dx - dx,
        _tapPosition.dy - dy,
        overlaySize.width,
        overlaySize.height,
      );
    }

    return material.showMenu<T>(
      context: context,
      position: position,
      items: <PopupMenuEntry<T>>[
        BlurPopupMenuCard(
          items: items,
        )
      ],
      color: Colors.transparent,
    );
  }
}
