import 'package:deliver/screen/room/messageWidgets/custom_text_selection/text_selections/custom_desktop_text_selection_controls.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'text_selections/custom_material_text_selection_controls.dart';

class CustomTextSelectionController {
  TextEditingController textController;
  BuildContext buildContext;
  Uid roomUid;

  CustomTextSelectionController({
    required this.buildContext,
    required this.textController,
    required this.roomUid,
  });

  TextSelectionControls getCustomTextSelectionController() {
    if (isAndroid || isIOS) {
      return CustomMaterialTextSelectionControls(
        roomUid: roomUid,
        buildContext: buildContext,
        textController: textController,
      );
    } else {
      return CustomDesktopTextSelectionControls(
        roomUid: roomUid,
        buildContext: buildContext,
        textController: textController,
      );
    }
  }
}
