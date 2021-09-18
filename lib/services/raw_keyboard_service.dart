import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:we/box/dao/room_dao.dart';
import 'package:we/repository/roomRepo.dart';
import 'package:we/screen/navigation_center/widgets/search_box.dart';
import 'package:we/screen/room/widgets/inputMessage.dart';
import 'package:we/services/routing_service.dart';

class RawKeyboardService {
  String _inputBoxText = "";
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  Function _openSearchBox;
  Function _scrollDownInChat;
  Function _scrollUpInChat;
  String _mentionData = "-";
  bool isScrollInBotCommand;

  set scrollUpInChat(Function value) {
    _scrollUpInChat = value;
  }

  set scrollDownInChat(Function value) {
    _scrollDownInChat = value;
  }

  var _currentRoom;

  set currentRoom(value) {
    _currentRoom = value;
  }

  set openSearchBox(Function value) {
    _openSearchBox = value;
  }

  void controllFHandle() {
    if (_openSearchBox != null) _openSearchBox();
  }

  Future<void> controllCHandle(TextEditingController controller) async {
    _inputBoxText = controller.text;
    await Clipboard.setData(ClipboardData(text: controller.text));
  }

  void controllVHandle(TextEditingController controller) {
    controller.text = controller.text + _inputBoxText;
  }

  Future<void> controllXHandle(TextEditingController controller) async {
    await Clipboard.setData(ClipboardData(text: controller.text));
    _inputBoxText = controller.text;
    controller.clear();
  }

  void controllAHandle(TextEditingController controller) {
    controller.selection = TextSelection(
        baseOffset: 0, extentOffset: controller.value.text.length);
  }

  void escapeHandle(int replyMessageId, Function resetRoomPageDetails) {
    if (InputMessage.myFocusNode == null) {
      if (_routingService.isAnyRoomOpen()) _routingService.pop();
      if (SearchBox.searchBoxFocusNode.hasFocus)
        SearchBox.searchBoxFocusNode.unfocus();
    } else {
      if (InputMessage.myFocusNode?.hasFocus) {
        if (replyMessageId == 0) {
          _routingService.pop();
        }
        if (replyMessageId > 0) {
          resetRoomPageDetails();
        }
      } else if (SearchBox.searchBoxFocusNode.hasFocus) {
        if (_routingService.isAnyRoomOpen())
          FocusScope.of(InputMessage.myFocusNode.context)
              .requestFocus(InputMessage.myFocusNode);
      } else {
        _routingService.pop();
      }
    }
  }

  void scrollUpInRoom() {
    int index = -1;
    _roomDao
        .getAllRooms()
        .then((room) => _roomRepo.getAllRooms().then((value) => {
              for (var element in value)
                {
                  index++,
                  if (element.node == _currentRoom.node)
                    if (index - 1 >= 0)
                      _routingService.openRoom(room[index - 1].uid)
                }
            }));
  }

  void scrollUpInChatPage() {
    if (_scrollUpInChat != null) _scrollUpInChat();
  }

  void scrollDownInChatPage() {
    if (_scrollUpInChat != null) _scrollDownInChat();
  }

  void scrollDownInRoom() {
    int index = -1;
    _roomDao
        .getAllRooms()
        .then((room) => _roomRepo.getAllRooms().then((value) => {
              for (var element in value)
                {
                  index++,
                  if (element.node == _currentRoom.node)
                    if (index + 1 < room.length)
                      _routingService.openRoom(room[index + 1].uid)
                }
            }));
  }

  void sendMention(Function showMention) {
    showMention();
  }

  void scrollDownInMentions(Function scrollDownInMention) {
    scrollDownInMention();
  }

  void scrollUpInMentions(Function scrollUpInMention) {
    scrollUpInMention();
  }

  void scrollUpInBotCommand(Function scrollUpInBotCommands) {
    scrollUpInBotCommands();
  }

  void scrollDownInBotCommand(Function scrollDownInBotCommands) {
    scrollDownInBotCommands();
  }

  void searchHandeling({event}) {
    if (event.physicalKey == PhysicalKeyboardKey.keyF && event.isControlPressed)
      controllFHandle();
  }

  void escapeHandeling(
      {event, int replyMessageId, Function resetRoomPageDetails}) {
    if (event.isKeyPressed(LogicalKeyboardKey.escape))
      escapeHandle(replyMessageId, resetRoomPageDetails);
  }

  navigateInMentions(
      String mentionData,
      Function scrollDownInMention,
      Function sendMentionByEnter,
      event,
      int mentionSelectedIndex,
      Function scrollUpInMention) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
        mentionData != "-" &&
        mentionSelectedIndex >= 0) {
      sendMention(sendMentionByEnter);
      return KeyEventResult.handled;
    }
    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
        !event.isAltPressed &&
        mentionData != "-") {
      _mentionData = mentionData;
      scrollUpInMentions(scrollUpInMention);
    }
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
        !event.isAltPressed &&
        mentionData != "-") {
      _mentionData = mentionData;
      scrollDownInMentions(scrollDownInMention);
    } else if (mentionData == "-") {
      _mentionData = "-";
    }
  }

  navigateInBotCommand(
      event, Function scrollDownInBotCommands, Function scrollUpInBotCommands) {
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      scrollDownInBotCommand(scrollDownInBotCommands);
      isScrollInBotCommand = true;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      scrollUpInBotCommand(scrollUpInBotCommands);
      isScrollInBotCommand = true;
    }
  }

  void handleCopyPastKeyPress(TextEditingController controller, event) {
    if (event.isKeyPressed(LogicalKeyboardKey.keyA) && event.isControlPressed)
      controllAHandle(controller);
    if (event.isKeyPressed(LogicalKeyboardKey.keyC) && event.isControlPressed)
      controllCHandle(controller);

    if (event.isKeyPressed(LogicalKeyboardKey.keyX) && event.isControlPressed)
      controllXHandle(controller);
    if (event.isKeyPressed(LogicalKeyboardKey.keyV) && event.isControlPressed)
      controllVHandle(controller);
  }

  navigateInRooms({event}) {
    if (event.isAltPressed) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        scrollUpInRoom();
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        scrollDownInRoom();
      }
    }
  }

  scrollInChatPage({event}) {
    if (_mentionData == "-" && !isScrollInBotCommand) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) scrollUpInChatPage();
      if (event.logicalKey == LogicalKeyboardKey.arrowDown)
        scrollDownInChatPage();
    }
  }
}
