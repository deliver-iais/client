import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/widgets/inputMessage.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class RawKeyboardService {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  Function _openSearchBox;

  var _currentRoom;

  set currentRoom(value) {
    _currentRoom = value;
  }

  set openSearchBox(Function value) {
    _openSearchBox = value;
  }

  void controlFHandle() {
    if (_openSearchBox != null) _openSearchBox();
  }

  void controlCHandle(TextEditingController controller) {
    Clipboard.setData(
        ClipboardData(text: controller.selection.textInside(controller.text)));
  }

  void controlVHandle(TextEditingController controller) async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    controller.text = data.text;
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
    if (InputMessage.inputMessegeFocusNode == null) {
      if (_routingService.isAnyRoomOpen()) _routingService.pop();
    } else {
      if (InputMessage.inputMessegeFocusNode?.hasFocus == true) {
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
                  if (element.node == _currentRoom.node)
                    if (index - 1 >= 0)
                      _routingService.openRoom(room[index - 1].uid,context:context)
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
                  if (element.node == _currentRoom.node)
                    if (index + 1 < room.length)
                      _routingService.openRoom(room[index + 1].uid,context:context)
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
    if (event.physicalKey == PhysicalKeyboardKey.keyF && event.isControlPressed)
      controlFHandle();
  }

  void escapeHandeling(
      {event, int replyMessageId, Function resetRoomPageDetails}) {
    if (event.isKeyPressed(LogicalKeyboardKey.escape))
      escapeHandle(replyMessageId, resetRoomPageDetails);
  }

  navigateInMentions(
      String mentionData,
      Function scrollDownInMention,
      event,
      int mentionSelectedIndex,
      Function scrollUpInMention,
      Function sendMentionByEnter) {
    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
        !event.isAltPressed &&
        mentionData != "-") {
      scrollUpInMentions(scrollUpInMention);
    }
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
        !event.isAltPressed &&
        mentionData != "-") {
      scrollDownInMentions(scrollDownInMention);
    }
    if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
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
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      scrollDownInBotCommand(scrollDownInBotCommands);
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      scrollUpInBotCommand(scrollUpInBotCommands);
    } else if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
        botCommandData != "-") {
      sendBotCommandsByEnter(sendBotCommandByEnter);
    }
  }

  void handleCopyPastKeyPress(TextEditingController controller, event) {
    if (event.isKeyPressed(LogicalKeyboardKey.keyA) && event.isControlPressed)
      controlAHandle(controller);
    if (event.isKeyPressed(LogicalKeyboardKey.keyC) && event.isControlPressed)
      controlCHandle(controller);

    if (event.isKeyPressed(LogicalKeyboardKey.keyX) && event.isControlPressed)
      controlXHandle(controller);
    if (event.isKeyPressed(LogicalKeyboardKey.keyV) && event.isControlPressed)
      controlVHandle(controller);
  }

  navigateInRooms({event,BuildContext context}) {
    if (event.isAltPressed) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        scrollUpInRoom(context);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        scrollDownInRoom(context);
      }
    }
  }
}
