import 'dart:async';
import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/widgets/bot_commands.dart';
import 'package:deliver/screen/room/widgets/emojiKeybord.dart';
import 'package:deliver/screen/room/widgets/recordAudioAnimation.dart';
import 'package:deliver/screen/room/widgets/recordAudioslideWidget.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/showMentionList.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/isPersian.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

class InputMessage extends StatefulWidget {
  final Room currentRoom;
  final int replyMessageId;
  final Function resetRoomPageDetails;
  final bool waitingForForward;
  final Function sendForwardMessage;
  final Function showMentionList;
  final Function scrollToLastSentMessage;
  static FocusNode myFocusNode;
  final Message editableMessage;

  @override
  _InputMessageWidget createState() => _InputMessageWidget();

  InputMessage(
      {@required this.currentRoom,
      this.replyMessageId,
      this.resetRoomPageDetails,
      this.waitingForForward = false,
      this.sendForwardMessage,
      this.editableMessage,
      this.showMentionList,
      this.scrollToLastSentMessage});
}

class _InputMessageWidget extends State<InputMessage> {
  MessageRepo messageRepo = GetIt.I.get<MessageRepo>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _uxService = GetIt.I.get<UxService>();
  final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();

  var checkPermission = GetIt.I.get<CheckPermissionsService>();
  TextEditingController _controller;
  Room currentRoom;
  bool autofocus = false;
  double x = 0.0;
  double size = 1;
  int _currentEditMessageId = 0;
  bool started = false;
  DateTime time = DateTime.now();
  BehaviorSubject<DateTime> recordSubject =
      BehaviorSubject.seeded(DateTime.now());

  double dx = 150.0;
  bool recordAudioPermission = false;
  FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  String mentionQuery;
  Timer recordAudioTimer;
  BehaviorSubject<bool> _showSendIcon = BehaviorSubject.seeded(false);
  BehaviorSubject<String> _mentionQuery = BehaviorSubject.seeded("-");
  BehaviorSubject<String> _botCommandQuery = BehaviorSubject.seeded("-");
  String path;
  Timer _tickTimer;
  TextSelection _textSelection;
  TextEditingController captionTextController = TextEditingController();

  bool startAudioRecorder = false;

  FocusNode keyboardRawFocusNode;

  Subject<ActivityType> isTypingActivitySubject = BehaviorSubject();
  Subject<ActivityType> noActivitySubject = BehaviorSubject();
  String _mentionData;
  int mentionSelectedIndex = -1;
  int botCommandSelectedIndex = -1;
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();

  void showButtonSheet() {
    if (isDesktop()) {
      _attachFileInWindowsMode();
    } else {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return ShareBox(
                currentRoomId: currentRoom.uid.asUid(),
                replyMessageId: widget.replyMessageId,
                resetRoomPageDetails: widget.resetRoomPageDetails,
                scrollToLastSentMessage: widget.scrollToLastSentMessage);
          });
    }
  }

  @override
  void initState() {
    InputMessage.myFocusNode = FocusNode();
    keyboardRawFocusNode = FocusNode();

    isTypingActivitySubject
        .throttle((_) => TimerStream(true, Duration(seconds: 10)))
        .listen((activityType) {
      messageRepo.sendActivity(widget.currentRoom.uid.asUid(), activityType);
    });
    noActivitySubject.listen((event) {
      messageRepo.sendActivity(widget.currentRoom.uid.asUid(), event);
    });
    currentRoom = widget.currentRoom;
    _controller = TextEditingController(
        text: currentRoom.draft != null ? currentRoom.draft : "");
    _showSendIcon
        .add(currentRoom.draft != null && currentRoom.draft.isNotEmpty);
    _controller.addListener(() {
      if (_controller.text.isNotEmpty && _controller.text.length > 0)
        _showSendIcon.add(true);
      else
        _showSendIcon.add(false);

      _roomRepo.updateRoomDraft(currentRoom.uid, _controller.text ?? "");

      var botCommandRegexp = RegExp(r"([a-zA-Z0-9_])*");
      var idRegexp = RegExp(r"([a-zA-Z0-9_])*");

      if (currentRoom.uid.asUid().category == Categories.BOT &&
          _controller.text != null &&
          _controller.text.isNotEmpty &&
          _controller.text[0] == "/" &&
          _controller.selection.start == _controller.selection.end &&
          _controller.selection.start >= 1 &&
          botCommandRegexp.hasMatch(
              _controller.text.substring(0 + 1, _controller.selection.start) ??
                  "")) {
        _botCommandQuery.add(
            _controller.text.substring(0 + 1, _controller.selection.start));
      } else if (_controller.text.isEmpty) {
        _botCommandQuery.add("-");
      }

      if (currentRoom.uid.asUid().category == Categories.GROUP &&
          _controller.selection.start > 0) {
        mentionQuery = "-";
        final str = _controller.text;
        int start = str.lastIndexOf("@", _controller.selection.start);

        if (start == -1) {
          _mentionQuery.add("-");
        }

        try {
          if (_controller.text.isNotEmpty &&
              _controller.text[start] == "@" &&
              _controller.selection.start == _controller.selection.end &&
              idRegexp.hasMatch(_controller.text
                      .substring(start + 1, _controller.selection.start) ??
                  "")) {
            _mentionQuery.add(_controller.text
                .substring(start + 1, _controller.selection.start));
          } else {
            _mentionQuery.add("-");
          }
        } catch (e) {
          _mentionQuery.add("-");
        }
      } else if (_controller.text.isEmpty) {
        _mentionQuery.add("-");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editableMessage != null &&
        (_currentEditMessageId == 0 ||
            _currentEditMessageId != widget.editableMessage.id)) {
      _currentEditMessageId = widget.editableMessage.id;
      _controller.text = getEditableMessageContent();
    }

    I18N i18n = I18N.of(context);
    dx = min(MediaQuery.of(context).size.width / 2, 150.0);
    return Column(
      children: <Widget>[
        StreamBuilder<String>(
            stream: _mentionQuery.stream.distinct(),
            builder: (c, showMention) {
              _mentionData = showMention.data ?? "-";
              if (showMention.hasData)
                return ShowMentionList(
                  query: _mentionData,
                  onSelected: (s) {
                    onSelected(s);
                  },
                  roomUid: widget.currentRoom.uid,
                  mentionSelectedIndex: mentionSelectedIndex,
                );
              return SizedBox.shrink();
            }),
        StreamBuilder(
            stream: _botCommandQuery.stream.distinct(),
            builder: (c, show) {
              return BotCommands(
                botUid: widget.currentRoom.uid.asUid(),
                query: show.data ?? "-",
                onCommandClick: (String command) {
                  _controller.text = "/" + command;
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));
                  _botCommandQuery.add("-");
                },
                botCommandSelectedIndex: botCommandSelectedIndex,
              );
            }),
        Container(
          color: ExtraTheme.of(context).inputBoxBackground,
          child: Stack(
            // overflow: Overflow.visible,
            children: <Widget>[
              StreamBuilder(
                  stream: _showSendIcon.stream,
                  builder: (c, sh) {
                    if (sh.hasData &&
                        !sh.data &&
                        !widget.waitingForForward &&
                        !isDesktop()) {
                      return RecordAudioAnimation(
                        rightPadding: x,
                        size: size,
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
              Row(
                children: <Widget>[
                  !startAudioRecorder
                      ? Expanded(
                          child: Row(
                            children: <Widget>[
                              StreamBuilder<bool>(
                                  stream: backSubject.stream,
                                  builder: (c, back) {
                                    return IconButton(
                                      icon: Icon(
                                        back.hasData && back.data
                                            ? Icons.keyboard
                                            : Icons.mood,
                                        color: ExtraTheme.of(context).textField,
                                      ),
                                      onPressed: () {
                                        if (back.data) {
                                          backSubject.add(false);
                                          FocusScope.of(context).unfocus();
                                        } else if (!back.data) {
                                          FocusScope.of(context).unfocus();
                                          Timer(Duration(milliseconds: 50), () {
                                            backSubject.add(true);
                                          });
                                        }
                                      },
                                    );
                                  }),
                              Flexible(
                                child: RawKeyboardListener(
                                  focusNode: keyboardRawFocusNode,
                                  onKey: handleKeyPress,
                                  child: TextField(
                                    focusNode: InputMessage.myFocusNode,
                                    autofocus: widget.replyMessageId > 0 ||
                                        isDesktop(),
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 8),
                                      border: InputBorder.none,
                                      hintText: i18n.get("message"),
                                    ),
                                    autocorrect: true,
                                    textInputAction: TextInputAction.newline,
                                    minLines: 1,
                                    maxLines: 15,
                                    textAlign: _controller.text.isNotEmpty &&
                                            _controller.text.isPersian()
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    textDirection:
                                        _controller.text.isNotEmpty &&
                                                _controller.text.isPersian()
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                    onTap: () => backSubject.add(false),
                                    onChanged: (str) {
                                      _textSelection = _controller.selection;
                                      if (str != null && str.length > 0)
                                        isTypingActivitySubject
                                            .add(ActivityType.TYPING);
                                      else
                                        noActivitySubject
                                            .add(ActivityType.NO_ACTIVITY);
                                    },
                                  ),
                                ),
                              ),
                              if (currentRoom.uid.asUid().category ==
                                  Categories.BOT)
                                StreamBuilder<bool>(
                                    stream: _showSendIcon.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && !snapshot.data)
                                        return IconButton(
                                          icon: Icon(
                                            Icons.workspaces_outline,
                                          ),
                                          onPressed: () => _botCommandQuery.add(
                                              _botCommandQuery.value == "-"
                                                  ? ""
                                                  : "-"),
                                        );
                                      else
                                        return SizedBox.shrink();
                                    }),
                              StreamBuilder(
                                  stream: _showSendIcon.stream,
                                  builder: (c, sh) {
                                    if (sh.hasData &&
                                        !sh.data &&
                                        !widget.waitingForForward) {
                                      return IconButton(
                                          icon: Icon(
                                            Icons.attach_file,
                                            color: ExtraTheme.of(context)
                                                .textField,
                                          ),
                                          onPressed: () {
                                            backSubject.add(false);
                                            showButtonSheet();
                                          });
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  }),
                              StreamBuilder(
                                  stream: _showSendIcon.stream,
                                  builder: (c, sh) {
                                    if ((sh.hasData && sh.data) ||
                                        widget.waitingForForward) {
                                      return IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          color: Colors.blue,
                                        ),
                                        onPressed: _controller.text != null &&
                                                _controller.text.isEmpty &&
                                                (widget.waitingForForward ==
                                                        null ||
                                                    widget.waitingForForward ==
                                                        false)
                                            ? () async {}
                                            : () {
                                                sendMessage();
                                              },
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  })
                            ],
                          ),
                        )
                      : RecordAudioSlideWidget(
                          opacity: opacity(),
                          time: time,
                          running: startAudioRecorder,
                          streamTime: recordSubject,
                        ),
                  StreamBuilder(
                      stream: _showSendIcon.stream,
                      builder: (c, sm) {
                        if (sm.hasData &&
                            !sm.data &&
                            !widget.waitingForForward &&
                            !isDesktop()) {
                          return GestureDetector(
                              onTapDown: (_) async {
                                recordAudioPermission = await checkPermission
                                    .checkAudioRecorderPermission();
                              },
                              onLongPressMoveUpdate: (tg) {
                                if (tg.offsetFromOrigin.dx > -dx && started) {
                                  setState(() {
                                    x = -tg.offsetFromOrigin.dx;
                                    startAudioRecorder = true;
                                  });
                                } else {
                                  if (started) {
                                    started = false;
                                    if (_tickTimer != null) _tickTimer.cancel();
                                    Vibration.vibrate(duration: 200);
                                    setState(() {
                                      startAudioRecorder = false;
                                      _soundRecorder.closeAudioSession();
                                      _soundRecorder.stopRecorder();
                                      x = 0;
                                      size = 1;
                                    });
                                  }
                                }
                              },
                              onLongPressStart: (dw) async {
                                if (recordAudioPermission) {
                                  var s =
                                      await getApplicationDocumentsDirectory();
                                  path = s.path +
                                      "/Deliver/${DateTime.now().millisecondsSinceEpoch}.m4a";
                                  recordSubject.add(DateTime.now());
                                  setTime();
                                  sendRecordActivity();
                                  Vibration.vibrate(duration: 200);
                                  await _soundRecorder.openAudioSession();
                                  _soundRecorder.startRecorder(
                                    toFile: path,
                                    sampleRate: 128000,
                                    numChannels: 2,
                                    bitRate: 128000,
                                    audioSource: AudioSource.defaultSource,
                                  );
                                  setState(() {
                                    startAudioRecorder = true;
                                    size = 2;
                                    started = true;
                                    time = DateTime.now();
                                  });
                                }
                              },
                              onLongPressEnd: (s) async {
                                if (_tickTimer != null) _tickTimer.cancel();

                                await _soundRecorder.stopRecorder();
                                _soundRecorder.closeAudioSession();
                                recordAudioTimer.cancel();
                                noActivitySubject.add(ActivityType.NO_ACTIVITY);
                                setState(() {
                                  startAudioRecorder = false;
                                  x = 0;
                                  size = 1;
                                });
                                if (started) {
                                  try {
                                    messageRepo.sendFileMessage(
                                        widget.currentRoom.uid.asUid(), path);
                                  } catch (e) {}
                                }
                              },
                              child: Opacity(
                                opacity: 0,
                                child: Material(
                                  // button color
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ));
                        } else {
                          return SizedBox(
                            height: 50,
                          );
                        }
                      })
                ],
              ),
            ],
          ),
        ),
        StreamBuilder(
            stream: backSubject.stream,
            builder: (context, back) {
              if (back.hasData && back.data) {
                return Container(
                    height: 270.0,
                    child: EmojiKeyboard(
                      onTap: (emoji) {
                        _controller.text = _controller.text + emoji.toString();
                      },
                      // onStickerTap: (Sticker sticker) {
                      //   messageRepo.sendStickerMessage(
                      //       room: widget.currentRoom.uid.asUid(),
                      //       sticker: sticker);
                      //   widget.scrollToLastSentMessage();
                      // },
                    ));
              } else {
                return SizedBox.shrink();
              }
            }),
      ],
    );
  }

  void onSelected(s) {
    int start = _textSelection.base.offset;
    String block_1 = _controller.text.substring(0, start);
    String block_2 = _controller.text.substring(start, _controller.text.length);
    _controller.text = block_1 + s + " " + block_2;
    _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length));
    _mentionQuery.add("-");
  }

  handleKeyPress(event) async {
    if (event is RawKeyUpEvent) {
      if (!_uxService.sendByEnter &&
          event.isShiftPressed &&
          (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
        sendMessage();
      } else if (_uxService.sendByEnter &&
          !event.isShiftPressed &&
          (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
        sendMessage();
      }
    }
    _rawKeyboardService.handleCopyPastKeyPress(_controller, event);
    _rawKeyboardService.escapeHandeling(
        replyMessageId: widget.replyMessageId,
        resetRoomPageDetails: widget.resetRoomPageDetails,
        event: event);
    setState(() {
      _rawKeyboardService.navigateInMentions(_mentionData, scrollDownInMentions,
          event, mentionSelectedIndex, scrollUpInMentions);
    });
    setState(() {
      _rawKeyboardService.navigateInBotCommand(
          event, scrollDownInBotCommand, scrollUpInBotCommand);
    });
  }

  scrollUpInBotCommand() {
    if (botCommandSelectedIndex < 0) {
      _botRepo.getBotInfo(widget.currentRoom.uid.asUid()).then((value) => {
            botCommandSelectedIndex = value.commands.length - 1,
          });
    } else {
      botCommandSelectedIndex--;
    }
  }

  scrollDownInBotCommand() {
    _botRepo.getBotInfo(widget.currentRoom.uid.asUid()).then((value) => {
          if (botCommandSelectedIndex >= value.commands.length)
            botCommandSelectedIndex = 0
          else
            botCommandSelectedIndex++,
        });
  }

  scrollUpInMentions() {
    if (mentionSelectedIndex <= 0) {
      _mucRepo
          .getFilteredMember(currentRoom.uid, query: _mentionData)
          .then((value) => {
                mentionSelectedIndex = value.length - 1,
              });
    } else {
      mentionSelectedIndex--;
    }
  }

  void sendMessage() {
    noActivitySubject.add(ActivityType.NO_ACTIVITY);
    if (widget.waitingForForward == true) {
      widget.sendForwardMessage();
    }

    var text = _controller.text.trim();

    if (text.isNotEmpty && text != null) {
      if (text.isNotEmpty) if (widget.replyMessageId != null) {
        messageRepo.sendTextMessage(
          currentRoom.uid.asUid(),
          text,
          replyId: widget.replyMessageId,
        );
        if (widget.replyMessageId != -1) widget.resetRoomPageDetails();
      } else if (widget.editableMessage != null) {
        messageRepo.editMessage(currentRoom.uid.asUid(),widget.editableMessage,_controller.text);
      } else {
        messageRepo.sendTextMessage(currentRoom.uid.asUid(), text);
      }

      _controller.clear();

      _mentionQuery.add("-");
    }
    widget.scrollToLastSentMessage();
  }

  void sendRecordActivity() {
    recordAudioTimer = Timer(Duration(seconds: 2), () {
      isTypingActivitySubject.add(ActivityType.RECORDING_VOICE);
      sendRecordActivity();
    });
  }

  opacity() => x < 0.0 ? 1.0 : (dx - x) / dx;

  _attachFileInWindowsMode() async {
    final typeGroup = XTypeGroup(label: 'images');
    final result = await openFiles(acceptedTypeGroups: [typeGroup]);
    showCaptionDialog(result: result, icons: Icons.file_upload);
  }

  void setTime() {
    _tickTimer = Timer(Duration(milliseconds: 500), () {
      recordSubject.add(DateTime.now());
      setTime();
    });
  }

  showCaptionDialog({IconData icons, String type, List<XFile> result}) async {
    if (result.length <= 0) return;
    captionTextController.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return ShowCaptionDialog(
            paths: result.map((e) => e.path).toList(),
            type: result.first.path.split(".").last,
            currentRoom: currentRoom.uid.asUid(),
          );
        });
  }

  scrollDownInMentions() {
    _mucRepo
        .getFilteredMember(currentRoom.uid, query: _mentionData)
        .then((value) => {
              if (mentionSelectedIndex >= value.length)
                {mentionSelectedIndex = 0}
              else
                {mentionSelectedIndex++}
            });
  }

  String getEditableMessageContent() {
    String text = "";
    // ignore: missing_enum_constant_in_switch
    switch (widget.editableMessage.type) {
      case MessageType.TEXT:
        text = widget.editableMessage.json.toText().text;
        break;
      case MessageType.FILE:
        text = widget.editableMessage.json.toFile().caption;
    }
    return text + " ";
  }
}
