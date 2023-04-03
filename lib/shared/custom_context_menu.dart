import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/widgets/popup_menu_card.dart';
import 'package:flutter/material.dart' hide showMenu;
import 'package:flutter/material.dart' as material show showMenu;
import 'package:get_it/get_it.dart';

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
    final i18n = GetIt.I.get<I18N>();
    final screenSize = MediaQuery.of(context).size;

    final overlaySize = i18n.isRtl
        ? settings.appContext.findRenderObject()!.semanticBounds.size
        : Overlay.of(context).context.findRenderObject()!.semanticBounds.size;

    final dx = screenSize.width - overlaySize.width;
    final dy = screenSize.height - overlaySize.height;

    final position = i18n.isRtl
        ? RelativeRect.fromDirectional(
            textDirection: i18n.defaultTextDirection,
            end: _tapPosition.dx - dx,
            start: overlaySize.width,
            top: _tapPosition.dy - 5 - dy,
            bottom: overlaySize.height,
          )
        : RelativeRect.fromDirectional(
            textDirection: i18n.defaultTextDirection,
            start: _tapPosition.dx - dx,
            end: overlaySize.width,
            top: _tapPosition.dy - 5 - dy,
            bottom: overlaySize.height,
          );

    return material.showMenu<T>(
      context: context,
      position: position,
      items: <PopupMenuEntry<T>>[
        PopupMenuCard(
          items: items,
        ),
      ],
    );
  }
}
