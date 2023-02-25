import 'package:deliver/screen/room/messageWidgets/custom_context_menu/context_menus/custom_material_context_menu.dart';
import 'package:deliver/screen/room/messageWidgets/custom_context_menu/context_menus/desktop/custom_desktop_input_box_context_menu.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomContextMenu {
  TextEditingController textController;
  BuildContext buildContext;
  Uid roomUid;
  EditableTextState editableTextState;

  CustomContextMenu({
    required this.buildContext,
    required this.textController,
    required this.roomUid,
    required this.editableTextState,
  });

  Widget getCustomTextSelectionController() {
    if (isAndroid || isIOS) {
      return CustomMaterialContextMenu(
        roomUid: roomUid,
        buildContext: buildContext,
        textController: textController,
        editableTextState:editableTextState,
      ).buildToolbar();
    } else {
      return CustomDesktopInputBoxContextMenu(
        roomUid: roomUid,
        buildContext: buildContext,
        textController: textController,
        editableTextState: editableTextState,
      ).buildToolbar();
    }
  }
}
