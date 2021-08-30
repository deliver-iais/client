import 'dart:async';
import 'dart:math';

import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/room/widgets/bot_commandsWidget.dart';
import 'package:deliver_flutter/screen/room/widgets/emojiKeybord.dart';
import 'package:deliver_flutter/screen/room/widgets/recordAudioAnimation.dart';
import 'package:deliver_flutter/screen/room/widgets/recordAudioslideWidget.dart';
import 'package:deliver_flutter/screen/room/widgets/share_box.dart';
import 'package:deliver_flutter/screen/room/widgets/showMentionList.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/methods/platform.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';

class InputMessage extends StatefulWidget {
  final Room currentRoom;
  final int replyMessageId;
  final Function resetRoomPageDetails;
  final bool waitingForForward;
  final Function sendForwardMessage;
  final Function showMentionList;
  final Function scrollToLastSentMessage;

  @override
  _InputMessageWidget createState() => _InputMessageWidget();

  InputMessage(
      {@required this.currentRoom,
      this.replyMessageId,
      this.resetRoomPageDetails,
      this.waitingForForward = false,
      this.sendForwardMessage,
      this.showMentionList,
      this.scrollToLastSentMessage});
}

class _InputMessageWidget extends State<InputMessage> {
  MessageRepo messageRepo = GetIt.I.get<MessageRepo>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _uxService = GetIt.I.get<UxService>();

  var checkPermission = GetIt.I.get<CheckPermissionsService>();
  TextEditingController controller;
  Room currentRoom;
  bool showEmoji = false;
  bool autofocus = false;
  double x = 0.0;
  double size = 1;
  bool started = false;
  DateTime time = DateTime.now();
  BehaviorSubject<DateTime> recordSubject =
      BehaviorSubject.seeded(DateTime.now());

  double dx = 150.0;
  bool recordAudioPermission = false;
  FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  BehaviorSubject<bool> _showBotCommands = BehaviorSubject.seeded(false);
  String query;
  Timer recordAudioTimer;
  BehaviorSubject<bool> _showSendIcon = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _showMentionList = BehaviorSubject.seeded(false);
  String path;
  Timer _ticktickTimer;
  TextEditingController caption = TextEditingController();
  bool startAudioRecorder = false;

  FocusNode myFocusNode;
  FocusNode keyboardRawFocusNode;

  Subject<ActivityType> isTypingActivitySubject = BehaviorSubject();
  Subject<ActivityType> noActivitySubject = BehaviorSubject();

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
    myFocusNode = FocusNode();
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
    controller = TextEditingController(
        text: currentRoom.draft != null ? currentRoom.draft : "");
    _showSendIcon
        .add(currentRoom.draft != null && currentRoom.draft.isNotEmpty);
    controller.addListener(() {
      if (controller.text.isNotEmpty && controller.text.length > 0)
        _showSendIcon.add(true);
      else
        _showSendIcon.add(false);

      _roomRepo.updateRoomDraft(currentRoom.uid, controller.text ?? "");
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    dx = min(MediaQuery.of(context).size.width / 2, 150.0);
    return Column(
      children: <Widget>[
        StreamBuilder(
            stream: _showMentionList.stream,
            builder: (c, showMention) {
              if (showMention.hasData && showMention.data)
                return ShowMentionList(
                  query: query,
                  onSelected: (s) {
                    controller.text = "${controller.text}$s ";
                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length));
                    _showMentionList.add(false);
                  },
                  roomUid: widget.currentRoom.uid,
                );
              else
                return SizedBox.shrink();
            }),
        StreamBuilder(
            stream: _showBotCommands.stream,
            builder: (c, show) {
              if (show.hasData && show.data) {
                return BotCommandsWidget(
                  botUid: widget.currentRoom.uid.asUid(),
                  onCommandClick: (String command) {
                    controller.text = "/" + command;
                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length));
                    _showBotCommands.add(false);
                  },
                );
              } else {
                return SizedBox.shrink();
              }
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
                                    onTap: () {
                                      backSubject.add(false);
                                    },
                                    minLines: 1,
                                    style: TextStyle(
                                        fontSize: 19,
                                        height: 1,
                                        color:
                                            ExtraTheme.of(context).textField),
                                    maxLines: 15,
                                    focusNode: myFocusNode,
                                    autofocus: widget.replyMessageId > 0 ||
                                        isDesktop(),
                                    textInputAction: TextInputAction.newline,
                                    controller: controller,
                                    autocorrect: true,
                                    onChanged: (str) {
                                      if (str != null && str.length > 0)
                                        isTypingActivitySubject
                                            .add(ActivityType.TYPING);
                                      else
                                        noActivitySubject
                                            .add(ActivityType.NO_ACTIVITY);
                                      onChange(str);
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 5),
                                      border: InputBorder.none,
                                      hintText: controller.text.isEmpty
                                          ? i18n.get("message")
                                          : "",
                                    ),
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
                                          onPressed: () => _showBotCommands.add(
                                              !_showBotCommands
                                                  .valueWrapper.value),
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
                                        onPressed: controller.text != null &&
                                                controller.text.isEmpty &&
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
                                    if (_ticktickTimer != null)
                                      _ticktickTimer.cancel();
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
                                if (_ticktickTimer != null)
                                  _ticktickTimer.cancel();

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
                        controller.text = controller.text + emoji.toString();
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
  }

  void sendMessage() {
    noActivitySubject.add(ActivityType.NO_ACTIVITY);
    if (widget.waitingForForward == true) {
      widget.sendForwardMessage();
    }

    var text = controller.text.trim();

    if (text.isNotEmpty && text != null) {
      if (text.isNotEmpty) if (widget.replyMessageId != null) {
        messageRepo.sendTextMessage(
          currentRoom.uid.asUid(),
          text,
          replyId: widget.replyMessageId,
        );
        if (widget.replyMessageId != -1) widget.resetRoomPageDetails();
      } else {
        messageRepo.sendTextMessage(currentRoom.uid.asUid(), text);
      }

      controller.clear();

      _showMentionList.add(false);
    }
    widget.scrollToLastSentMessage();
  }

  void sendRecordActivity() {
    recordAudioTimer = Timer(Duration(seconds: 2), () {
      isTypingActivitySubject.add(ActivityType.RECORDING_VOICE);
      sendRecordActivity();
    });
  }

  void onChange(String str) {
    if (currentRoom.uid.asUid().category == Categories.BOT) {
      if (str.isNotEmpty && str.length == 1 && str.contains("/")) {
        _showBotCommands.add(true);
        return;
      }
    }
    if (currentRoom.uid.asUid().category == Categories.GROUP) {
      if (str.isEmpty) {
        _showMentionList.add(false);
        return;
      }
      try {
        query = "";
        int i = str.lastIndexOf("@");
        if (i == -1) {
          _showMentionList.add(false);
        }
        if ((i != 0 && str[i - 1] != " ") && str[i - 1] != "\n") {
          return;
        }
        if (i != -1 && !str.contains(" ", i)) {
          query = str.substring(i + 1, str.length);
          _showMentionList.add(true);
        } else {
          _showMentionList.add(false);
        }
      } catch (e) {}
    }
    if (currentRoom.uid.asUid().category == Categories.BOT) {
      if (str.isNotEmpty && str.length == 1 && str.contains(" \ ")) {
        _showBotCommands.add(true);
      } else {
        _showBotCommands.add(false);
      }
    }
  }

  opacity() => x < 0.0 ? 1.0 : (dx - x) / dx;

  _attachFileInWindowsMode() async {
    final typeGroup = XTypeGroup(label: 'images');
    final result = await openFiles(acceptedTypeGroups: [typeGroup]);
    showMyDialog(result: result, icons: Icons.file_upload);
  }

  void setTime() {
    _ticktickTimer = Timer(Duration(milliseconds: 500), () {
      recordSubject.add(DateTime.now());
      setTime();
    });
  }

  showMyDialog({IconData icons, String type, List<XFile> result}) async {
    String name = await _roomRepo.getName(currentRoom.uid.asUid());
    showDialog(
        context: context,
        builder: (context) {
          return Container(
              child: Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Stack(children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.55,
                    padding: EdgeInsets.only(
                        left: 20, top: 40, right: 20, bottom: 20),
                    margin: EdgeInsets.only(top: 45),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Theme.of(context).dialogBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Selected Files ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "send ${result.map((e) => e.path).toList().length} file to ${name}",
                          style: TextStyle(
                              fontSize: 16,
                              color: ExtraTheme.of(context).fileSharingDetails),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Add a caption",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                            controller: caption,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              labelText: 'Caption',
                              border: OutlineInputBorder(),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            messageRepo.sendMultipleFilesMessages(
                                currentRoom.uid.asUid(),
                                result.map((e) => e.path).toList(),
                                caption: caption.text.toString());
                          },
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlueAccent,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                      child: Text(
                                    "Send",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  )))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TextButton(
                                child: Text("Cancel",
                                    style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 18))),
                          ),
                        ),
                      ],
                    )),
                Positioned(
                  left: 20,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 45,
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        child: Container(
                          color: Colors.blue,
                          width: 60,
                          height: 60,
                          child: Icon(
                            icons,
                            color: Colors.white,
                            size: 30,
                          ),
                        )),
                  ),
                ),
              ]),
            ),
          ));
        });
  }
}
