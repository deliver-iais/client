import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/widgets/input_message.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class RawKeyboardService {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  late Function _openSearchBox;

  Uid? _currentRoom;

  set currentRoom(value) {
    _currentRoom = value;
  }

  set openSearchBox(Function value) {
    _openSearchBox = value;
  }

  void controlFHandle() {
    _openSearchBox();
  }

  void controlCHandle(TextEditingController controller) {
    Clipboard.setData(
        ClipboardData(text: controller.selection.textInside(controller.text)));
  }

  void controlVHandle(TextEditingController controller) async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    controller.text = data!.text!;
  }

  void controlXHandle(TextEditingController controller) {
    Clipboard.setData(
        ClipboardData(text: controller.selection.textInside(controller.text)));
  }

  void controlAHandle(TextEditingController controller) {
    controller.selection = TextSelection(
        baseOffset: 0, extentOffset: controller.value.text.length);
  }

  void escapeHandle(int replyMessageId, Function resetRoomPageDetails) {
    if (InputMessage.inputMessageFocusNode == null) {
      _routingService.popAll();
    } else {
      if (InputMessage.inputMessageFocusNode?.hasFocus == true) {
        if (replyMessageId == 0) {
          _routingService.pop();
        }
        if (replyMessageId > 0) {
          resetRoomPageDetails();
        }
      } else {
        _routingService.pop();
      }
    }
  }

  void scrollUpInRoom(BuildContext context) {
    int index = -1;
    _roomDao
        .getAllRooms()
        .then((room) => _roomRepo.getAllRooms().then((value) => {
              for (var element in value)
                {
                  index++,
                  if (element.node == _currentRoom?.node)
                    if (index - 1 >= 0)
                      _routingService.openRoom(room[index - 1].uid)
                }
            }));
  }

  void scrollDownInRoom(BuildContext context) {
    int index = -1;
    _roomDao
        .getAllRooms()
        .then((room) => _roomRepo.getAllRooms().then((value) => {
              for (var element in value)
                {
                  index++,
                  if (element.node == _currentRoom?.node)
                    if (index + 1 < room.length)
                      _routingService.openRoom(room[index + 1].uid)
                }
            }));
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

  void searchHandeling({event}) {
    if (event.physicalKey == PhysicalKeyboardKey.keyF &&
        event.isControlPressed) {
      controlFHandle();
    }
  }

  void escapeHandeling(
      {event, int? replyMessageId, Function? resetRoomPageDetails}) {
    if (isKeyPressed(event, PhysicalKeyboardKey.escape)) {
      escapeHandle(replyMessageId!, resetRoomPageDetails!);
    }
  }

  navigateInMentions(
      String mentionData,
      Function scrollDownInMention,
      event,
      int mentionSelectedIndex,
      Function scrollUpInMention,
      Function sendMentionByEnter) {
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
    if (isKeyPressed(event, PhysicalKeyboardKey.enter) &&
        mentionData != "-" &&
        mentionSelectedIndex >= 0) {
      sendMention(sendMentionByEnter);
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

  navigateInRooms({event, required BuildContext context}) {
    if (event.isAltPressed) {
      if (isKeyPressed(event, PhysicalKeyboardKey.arrowUp)) {
        scrollUpInRoom(context);
      }
      if (isKeyPressed(event, PhysicalKeyboardKey.arrowDown)) {
        scrollDownInRoom(context);
      }
    }
  }

  isKeyPressed(event, PhysicalKeyboardKey key) {
    return event is RawKeyDownEvent && event.physicalKey == key;
  }
}
