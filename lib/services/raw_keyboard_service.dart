import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/screen/room/messageWidgets/custom_context_menu/methods/custom_text_selection_methods.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/keyboard.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';

class RawKeyboardService {
  final _routingService = GetIt.I.get<RoutingService>();

  void controlFHandle() {}

  void controlCHandle(TextEditingController controller, BuildContext context) {
    saveToClipboard(
      controller.selection.textInside(controller.text),
    );
  }

  Future<void> controlVHandle(
    TextEditingController controller,
    BuildContext context,
    Uid roomUid,
  ) async {
    final files = await Pasteboard.files();
    final image = await Pasteboard.image;

    if (files.isNotEmpty || image != null) {
      final fileList = <model.File>[];

      if (files.isNotEmpty) {
        fileList.addAll(files.map(pathToFileModel));
      }

      if (image != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/screenshot-${clock.now().hashCode}.png',
        ).create();
        file.writeAsBytesSync(image);

        fileList.add(fileToFileModel(file));
      }

      if (context.mounted) {
        showCaptionDialog(
          context: context,
          files: fileList,
          caption: controller.text.isNotEmpty
              ? !isLinuxNative
                  ? controller.text
                  : null
              : null,
          roomUid: roomUid,
        );
      }

      // TODO(any): why duration, and why not copying controller data in caption text for better experience
      Timer(Duration.zero, () {
        controller.clear();
      });
    } else {
      await CustomContextMenuMethods.handlePaste(controller);
    }
  }

  void controlXHandle(TextEditingController controller) {
    Clipboard.setData(
      ClipboardData(text: controller.selection.textInside(controller.text)),
    );
  }

  void controlAHandle(TextEditingController controller) {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.value.text.length,
    );
  }

  void sendMention(void Function() showMention) {
    showMention();
  }

  void sendBotCommandsByEnter(void Function() sendBotCommentByEnter) {
    sendBotCommentByEnter();
  }

  void searchHandling(RawKeyEvent event) {
    if (isMetaAndKeyPressed(event, PhysicalKeyboardKey.escape)) {
      controlFHandle();
    }
  }

  void escapeHandling(RawKeyEvent event) {
    if (isKeyPressed(event, PhysicalKeyboardKey.escape)) {
      _routingService.maybePop();
    }
  }

  KeyEventResult navigateInMentions(
    String? mentionData,
    void Function() scrollDownInMention,
    RawKeyEvent event,
    void Function() scrollUpInMention,
  ) {
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowUp) &&
        !event.isAltPressed &&
        mentionData != null) {
      scrollUpInMention();
      return KeyEventResult.handled;
    }
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowDown) &&
        !event.isAltPressed &&
        mentionData != null) {
      scrollDownInMention();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult navigateInBotCommand(
    RawKeyEvent event,
    void Function() scrollDownInBotCommands,
    void Function() scrollUpInBotCommands,
    String botCommandData,
  ) {
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowDown)) {
      scrollDownInBotCommands();
      return KeyEventResult.handled;
    } else if (isKeyPressed(event, PhysicalKeyboardKey.arrowUp)) {
      scrollUpInBotCommands();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void handleCopyPastKeyPress(
    TextEditingController controller,
    RawKeyEvent event,
    BuildContext context,
    Uid roomUid,
  ) {
    if (isMetaAndKeyPressed(event, PhysicalKeyboardKey.keyA)) {
      controlAHandle(controller);
    } else if (isMetaAndKeyPressed(event, PhysicalKeyboardKey.keyC)) {
      controlCHandle(controller, context);
    } else if (isMetaAndKeyPressed(event, PhysicalKeyboardKey.keyX)) {
      controlXHandle(controller);
    } else if (isMetaAndKeyPressed(event, PhysicalKeyboardKey.keyV)) {
      controlVHandle(controller, context, roomUid);
    }
  }
}
