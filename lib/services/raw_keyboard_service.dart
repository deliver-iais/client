import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/services/routing_service.dart';
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

  void controlFHandle() {
  }

  void controlCHandle(TextEditingController controller) {
    Clipboard.setData(
      ClipboardData(text: controller.selection.textInside(controller.text)),
    );
  }

  Future<void> controlVHandle(
    TextEditingController controller,
    BuildContext context,
    Uid roomUid,
  ) async {
    final files = await Pasteboard.files();
    final image = await Pasteboard.image;
    final fileList = <model.File>[];
    var name = "";
    if (files.isNotEmpty) {
      for (final file in files) {
        name = file.replaceAll("\\", "/").split("/").last;
        fileList.add(model.File(file, name, extension: name.split(".").last));
      }
    } else if (image != null) {
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/screenshot-${clock.now().hashCode}.png',
      ).create();
      file.writeAsBytesSync(image);
      name = file.path.replaceAll("\\", "/").split("/").last;
      fileList
          .add(model.File(file.path, name, extension: name.split(".").last));
    } else {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final start = controller.selection.start;
      final end = controller.selection.end;
      controller
        ..text = controller.text.substring(0, start) +
            data!.text!.replaceAll("\r", "") +
            controller.text.substring(end)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: start + data.text!.replaceAll("\r", "").length),
        );
    }
    if (fileList.isNotEmpty) {
      showCaptionDialog(
        context: context,
        files: fileList,
        caption: controller.text.isNotEmpty
            ? !isLinux
                ? controller.text
                : null
            : null,
        roomUid: roomUid,
        type: fileList.length == 1 ? name.split(".").last : "file",
      );
      Timer(Duration.zero, () {
        controller.clear();
      });
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

  void scrollDownInMentions(void Function() scrollDownInMention) {
    scrollDownInMention();
  }

  void scrollUpInMentions(void Function() scrollUpInMention) {
    scrollUpInMention();
  }

  void sendMention(void Function() showMention) {
    showMention();
  }

  void scrollUpInBotCommand(void Function() scrollUpInBotCommands) {
    scrollUpInBotCommands();
  }

  void sendBotCommandsByEnter(void Function() sendBotCommentByEnter) {
    sendBotCommentByEnter();
  }

  void scrollDownInBotCommand(void Function() scrollDownInBotCommands) {
    scrollDownInBotCommands();
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

  void navigateInMentions(
    String? mentionData,
    void Function() scrollDownInMention,
    RawKeyEvent event,
    int mentionSelectedIndex,
    void Function() scrollUpInMention,
  ) {
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowUp) &&
        !event.isAltPressed &&
        mentionData != null) {
      scrollUpInMentions(scrollUpInMention);
    }
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowDown) &&
        !event.isAltPressed &&
        mentionData != null) {
      scrollDownInMentions(scrollDownInMention);
    }
  }

  void navigateInBotCommand(
    RawKeyEvent event,
    void Function() scrollDownInBotCommands,
    void Function() scrollUpInBotCommands,
    String botCommandData,
  ) {
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowDown)) {
      scrollDownInBotCommand(scrollDownInBotCommands);
    } else if (isKeyPressed(event, PhysicalKeyboardKey.arrowUp)) {
      scrollUpInBotCommand(scrollUpInBotCommands);
    }
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
      controlCHandle(controller);
    } else if (isMetaAndKeyPressed(event, PhysicalKeyboardKey.keyX)) {
      controlXHandle(controller);
    } else if (isMetaAndKeyPressed(event, PhysicalKeyboardKey.keyV)) {
      controlVHandle(controller, context, roomUid);
    }
  }
}
