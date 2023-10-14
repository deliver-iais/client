import 'package:deliver/screen/room/messageWidgets/custom_context_menu/context_menus/desktop/widgets/desktop_custom_context_menu_toolbar_widget.dart';
import 'package:flutter/material.dart';

class CustomDesktopContextMenu {
  EditableTextState editableTextState;

  CustomDesktopContextMenu({
    required this.editableTextState,
  });

  Widget buildToolbar() {
    return DesktopCustomContextMenuToolbar(
      textSelectionToolbarAnchors: editableTextState.contextMenuAnchors,
      clipboardStatus: editableTextState.clipboardStatus,
      handleCut: editableTextState.cutEnabled
          ? () => editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.cut,
              )
              .onPressed!()
          : null,
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
      handlePaste: editableTextState.pasteEnabled
          ? () {
              editableTextState.contextMenuButtonItems
                  .firstWhere(
                    (element) => element.type == ContextMenuButtonType.paste,
                  )
                  .onPressed!();
            }
          : null,
    );
  }
}
