import 'dart:async';

import 'dart:io';
import 'dart:typed_data';

import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/keyboard.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:path_provider/path_provider.dart';

class RawKeyboardService {
  final _routingService = GetIt.I.get<RoutingService>();

  void controlFHandle() {
    // TODO: should be implemented
  }

  void controlCHandle(TextEditingController controller) {
    Clipboard.setData(
        ClipboardData(text: controller.selection.textInside(controller.text)));
  }

  void controlVHandle(TextEditingController controller, BuildContext context,
      Uid roomUid) async {
    final files = await Pasteboard.files();
    Uint8List? image = await Pasteboard.image;
    List<model.File> fileList = [];
    String name = "";
    if (files.isNotEmpty) {
      for (var file in files) {
        name = file.replaceAll("\\", "/").split("/").last;
        fileList.add(model.File(file, name, extension: name.split(".").last));
      }
    } else if (image != null) {
      final tempDir = await getTemporaryDirectory();
      File file = await File(
              '${tempDir.path}/screenshot-${DateTime.now().hashCode}.png')
          .create();
      file.writeAsBytesSync(image);
      name = file.path.replaceAll("\\", "/").split("/").last;
      fileList
          .add(model.File(file.path, name, extension: name.split(".").last));
    } else {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      controller.text = controller.text + data!.text!;
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    }
    if (fileList.isNotEmpty) {
      showCaptionDialog(
          context: context,
          files: fileList,
          caption: controller.text.isNotEmpty
              ? !isLinux()
                  ? controller.text
                  : null
              : null,
          roomUid: roomUid,
          type: fileList.length == 1 ? name.split(".").last : "file");
      Timer(Duration.zero, () {
        controller.clear();
      });
    }
  }

  void controlXHandle(TextEditingController controller) {
    Clipboard.setData(
        ClipboardData(text: controller.selection.textInside(controller.text)));
  }

  void controlAHandle(TextEditingController controller) {
    controller.selection = TextSelection(
        baseOffset: 0, extentOffset: controller.value.text.length);
  }

  void scrollDownInMentions(Function scrollDownInMention) {
    scrollDownInMention();
  }

  void scrollUpInMentions(Function scrollUpInMention) {
    scrollUpInMention();
  }

  void sendMention(Function showMention) {
    showMention();
  }

  void scrollUpInBotCommand(Function scrollUpInBotCommands) {
    scrollUpInBotCommands();
  }

  sendBotCommandsByEnter(Function sendBotCommentByEnter) {
    sendBotCommentByEnter();
  }

  void scrollDownInBotCommand(Function scrollDownInBotCommands) {
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

  navigateInMentions(String mentionData, Function scrollDownInMention,
      RawKeyEvent event, int mentionSelectedIndex, Function scrollUpInMention) {
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowUp) &&
        !event.isAltPressed &&
        mentionData != "-") {
      scrollUpInMentions(scrollUpInMention);
    }
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowDown) &&
        !event.isAltPressed &&
        mentionData != "-") {
      scrollDownInMentions(scrollDownInMention);
    }
  }

  navigateInBotCommand(
      RawKeyEvent event,
      Function scrollDownInBotCommands,
      Function scrollUpInBotCommands,
      Function sendBotCommandByEnter,
      String botCommandData) {
    if (isKeyPressed(event, PhysicalKeyboardKey.arrowDown)) {
      scrollDownInBotCommand(scrollDownInBotCommands);
    } else if (isKeyPressed(event, PhysicalKeyboardKey.arrowUp)) {
      scrollUpInBotCommand(scrollUpInBotCommands);
    } else if (isKeyPressed(event, PhysicalKeyboardKey.enter) &&
        botCommandData != "-") {
      sendBotCommandsByEnter(sendBotCommandByEnter);
    }
  }

  void handleCopyPastKeyPress(TextEditingController controller,
      RawKeyEvent event, BuildContext context, Uid roomUid) {
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
