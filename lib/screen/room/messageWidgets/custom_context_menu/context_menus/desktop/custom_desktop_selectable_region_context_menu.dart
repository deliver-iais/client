import 'package:deliver/screen/room/messageWidgets/custom_context_menu/context_menus/desktop/widgets/desktop_custom_context_menu_toolbar_widget.dart';
import 'package:flutter/material.dart';

class CustomDesktopSelectableRegionContextMenu {
  SelectableRegionState editableTextState;

  CustomDesktopSelectableRegionContextMenu({
    required this.editableTextState,
  });

  Widget buildToolbar() {
    return DesktopCustomContextMenuToolbar(
      textSelectionToolbarAnchors: editableTextState.contextMenuAnchors,
      handleCopy: editableTextState.copyEnabled
          ? () => editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.copy,
              )
              .onPressed!()
          : null,
      handleSelectAll: editableTextState.selectAllEnabled
          ? () => editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.selectAll,
              )
              .onPressed!()
          : null,
    );
  }
}
