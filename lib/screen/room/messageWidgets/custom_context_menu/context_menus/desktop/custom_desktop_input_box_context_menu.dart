import 'package:deliver/screen/room/messageWidgets/custom_context_menu/context_menus/desktop/widgets/desktop_custom_context_menu_toolbar_widget.dart';
import 'package:deliver/screen/room/messageWidgets/custom_context_menu/methods/custom_text_selection_methods.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

class CustomDesktopInputBoxContextMenu {
  TextEditingController textController;
  BuildContext buildContext;
  Uid roomUid;
  EditableTextState editableTextState;

  CustomDesktopInputBoxContextMenu({
    required this.buildContext,
    required this.textController,
    required this.roomUid,
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
              .onPressed()
          : null,
      handleCopy: editableTextState.copyEnabled
          ? () => editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.copy,
              )
              .onPressed()
          : null,
      handleSelectAll: editableTextState.selectAllEnabled
          ? () => editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.selectAll,
              )
              .onPressed()
          : null,
      handlePaste: editableTextState.pasteEnabled
          ? () {
              if (!isDesktopNative) {
                editableTextState.contextMenuButtonItems
                    .firstWhere(
                      (element) => element.type == ContextMenuButtonType.paste,
                    )
                    .onPressed();
              } else {
                CustomContextMenuMethods.desktopPastHandle(
                  textController,
                  roomUid,
                  buildContext,
                );
              }
            }
          : null,
      handleUnderline: () => CustomContextMenuMethods.handleFormatting(
        UnderlineFeature.specialChar,
        textController,
      ),
      handleSpoiler: () => CustomContextMenuMethods.handleFormatting(
        SpoilerFeature.specialChar,
        textController,
      ),
      handleBold: () => CustomContextMenuMethods.handleFormatting(
        BoldFeature.specialChar,
        textController,
      ),
      handleItalic: () => CustomContextMenuMethods.handleFormatting(
        ItalicFeature.specialChar,
        textController,
      ),
      handleStrikethrough: () => CustomContextMenuMethods.handleFormatting(
        StrikethroughFeature.specialChar,
        textController,
      ),
      isAnyThingSelected: () =>
          CustomContextMenuMethods.isAnyThingSelected(textController),
      handleCreateLink: () => CustomContextMenuMethods.handleCreateLink(
        buildContext,
        textController,
      ),
    );
  }
}
