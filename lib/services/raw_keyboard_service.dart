import 'package:deliver/services/routing_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class RawKeyboardService {
  final _routingService = GetIt.I.get<RoutingService>();

  void controlFHandle() {
    // TODO: should be implemented
  }

  void controlCHandle(TextEditingController controller) {
    Clipboard.setData(
        ClipboardData(text: controller.selection.textInside(controller.text)));
  }

  void controlVHandle(TextEditingController controller) async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    controller.text = controller.text+ data!.text!;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
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

  void searchHandling({event}) {
    if (event.physicalKey == PhysicalKeyboardKey.keyF &&
        event.isControlPressed) {
      controlFHandle();
    }
  }

  void escapeHandling(event) {
    if (isKeyPressed(event, PhysicalKeyboardKey.escape)) {
      _routingService.maybePop();
    }
  }

  navigateInMentions(
      String mentionData,
      Function scrollDownInMention,
      event,
      int mentionSelectedIndex,
      Function scrollUpInMention) {
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
      event,
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

  void handleCopyPastKeyPress(TextEditingController controller, event) {
    if (isKeyPressed(event, PhysicalKeyboardKey.keyA) &&
        event.isControlPressed) {
      controlAHandle(controller);
    }
    if (isKeyPressed(event, PhysicalKeyboardKey.keyC) &&
        event.isControlPressed) {
      controlCHandle(controller);
    }
    if (isKeyPressed(event, PhysicalKeyboardKey.keyX) &&
        event.isControlPressed) {
      controlXHandle(controller);
    }
    if (isKeyPressed(event, PhysicalKeyboardKey.keyV) &&
        event.isControlPressed) {
      controlVHandle(controller);
    }
  }

  isKeyPressed(event, PhysicalKeyboardKey key) {
    return event is RawKeyDownEvent && event.physicalKey == key;
  }
}
