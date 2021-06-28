import 'dart:async';
import 'dart:math';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/screen/app-room/widgets/bot_commandsWidget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/emojiKeybord.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recordAudioAnimation.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recordAudioslideWidget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box.dart';
import 'package:deliver_flutter/screen/app-room/widgets/showMentionList.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';

import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';

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

  var checkPermission = GetIt.I.get<CheckPermissionsService>();
  TextEditingController controller;
  Room currentRoom;
  bool showEmoji = false;
  String messageText = "";
  bool autofocus = false;
  double x = 0.0;
  double size = 1;
  bool started = false;
  DateTime time = DateTime.now();
  BehaviorSubject<DateTime> recordSubject =
      BehaviorSubject.seeded(DateTime.now());

  double DX = 150.0;
  bool recordAudioPermission = false;
  FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  BehaviorSubject<bool> _showBotCommands = BehaviorSubject.seeded(false);
  String query;
  Timer recordAudioTimer;
  BehaviorSubject<bool> _showSendIcon = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _showMentionList = BehaviorSubject.seeded(false);
  String path;
  Timer _ticktickTimer;

  bool startAudioRecorder = false;

  FocusNode myFocusNode;

  Subject<ActivityType> isTypingActivitySubject = BehaviorSubject();
  Subject<ActivityType> NoActivitySubject = BehaviorSubject();

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
                currentRoomId: currentRoom.roomId.uid,
                replyMessageId: widget.replyMessageId,
                resetRoomPageDetails: widget.resetRoomPageDetails,
                scrollToLastSentMessage: widget.scrollToLastSentMessage);
          });
    }
  }

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();

    isTypingActivitySubject
        .throttle((_) => TimerStream(true, Duration(seconds: 10)))
        .listen((activityType) {
      messageRepo.sendActivityMessage(
          widget.currentRoom.roomId.getUid(), activityType);
    });
    NoActivitySubject.listen((event) {
      messageRepo.sendActivityMessage(
          widget.currentRoom.roomId.getUid(), event);
    });
    controller = TextEditingController();
    currentRoom = widget.currentRoom;
    controller.addListener(() {
      if (controller.text.isNotEmpty && controller.text.length > 0)
        _showSendIcon.add(true);
      else
        _showSendIcon.add(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    DX = min(MediaQuery.of(context).size.width / 2, 150.0);
    return Column(
      children: <Widget>[
        StreamBuilder(
            stream: _showMentionList.stream,
            builder: (c, showMention) {
              if (showMention.hasData && showMention.data)
                return ShowMentionList(
                  query: query,
                  onSelected: (s) {
                    controller.text = "${controller.text}${s} ";
                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length));
                    _showMentionList.add(false);
                  },
                  roomUid: widget.currentRoom.roomId,
                );
              else
                return SizedBox.shrink();
            }),
        StreamBuilder(
            stream: _showBotCommands.stream,
            builder: (c, show) {
              if (show.hasData && show.data) {
                return BotCommandsWidget(
                  botUid: widget.currentRoom.roomId.getUid(),
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
                        righPadding: x,
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
                                child: TextField(
                                  onTap: () {
                                    backSubject.add(false);
                                    //     scrollTolast(1);
                                  },
                                  minLines: 1,
                                  style: TextStyle(
                                      fontSize: 19,
                                      height: 1,
                                      color: ExtraTheme.of(context).textField),
                                  maxLines: 15,
                                  autofocus:
                                      widget.replyMessageId > 0 || isDesktop(),
                                  textInputAction: isDesktop()
                                      ? TextInputAction.next
                                      : TextInputAction.newline,
                                  controller: controller,
                                  autocorrect: true,
                                  focusNode: myFocusNode,
                                  onSubmitted: (d) {
                                    if (isDesktop())
                                      FocusScope.of(context)
                                          .requestFocus(myFocusNode);
                                    controller.text?.isEmpty &&
                                            (widget.waitingForForward == null ||
                                                widget.waitingForForward ==
                                                    false)
                                        ? () async {}
                                        : () {
                                            sendMessage();
                                          };
                                  },
                                  onChanged: (str) {
                                    if (str?.length > 0)
                                      isTypingActivitySubject
                                          .add(ActivityType.TYPING);
                                    else
                                      NoActivitySubject.add(
                                          ActivityType.NO_ACTIVITY);
                                    onChange(str);
                                  },
                                  decoration: InputDecoration.collapsed(
                                    hintText: appLocalization
                                        .getTraslateValue("message"),
                                  ),
                                ),
                              ),
                              if (currentRoom.roomId.getUid().category ==
                                  Categories.BOT)
                                StreamBuilder<bool>(
                                    stream: _showSendIcon.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && !snapshot.data)
                                        return GestureDetector(
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: ExtraTheme.of(
                                                                context)
                                                            .textField),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: SizedBox(
                                                      width: 20,
                                                      child: Center(
                                                          child: Text(
                                                        "/",
                                                        style: TextStyle(
                                                          fontSize: 19,
                                                          color: ExtraTheme.of(
                                                                  context)
                                                              .textField,
                                                        ),
                                                      )))),
                                              SizedBox(
                                                width: 15,
                                              )
                                            ],
                                          ),
                                          onTap: () {
                                            _showBotCommands.add(
                                                !_showBotCommands
                                                    .valueWrapper.value);
                                          },
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
                                        widget.waitingForForward ||
                                        isDesktop()) {
                                      return IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          color: Colors.blue,
                                        ),
                                        onPressed: controller.text?.isEmpty &&
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
                          rinning: startAudioRecorder,
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
                                if (tg.offsetFromOrigin.dx > -DX && started) {
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
                                      ;
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
                                NoActivitySubject.add(ActivityType.NO_ACTIVITY);
                                setState(() {
                                  startAudioRecorder = false;
                                  x = 0;
                                  size = 1;
                                });
                                if (started) {
                                  try {
                                    messageRepo.sendFileMessage(
                                        widget.currentRoom.roomId.uid, path);
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
                    child: EmojiKeybord(
                      onTap: (emoji) {
                        controller.text = controller.text + emoji.toString();
                      },
                      onStickerTap: (Sticker sticker) {
                        messageRepo.sendStickerMessage(
                            roomUid: widget.currentRoom.roomId.getUid(),
                            sticker: sticker);
                        widget.scrollToLastSentMessage();
                      },
                    ));
              } else {
                return SizedBox.shrink();
              }
            }),
      ],
    );
  }

  void sendMessage() {
    NoActivitySubject.add(ActivityType.NO_ACTIVITY);
    if (widget.waitingForForward == true) {
      widget.sendForwardMessage();
    }
    if (controller.text.isNotEmpty) {
      if (controller.text.isNotEmpty) if (widget.replyMessageId != null) {
        messageRepo.sendTextMessage(
          currentRoom.roomId.uid,
          controller.text,
          replyId: widget.replyMessageId,
        );
        if (widget.replyMessageId != -1) widget.resetRoomPageDetails();
      } else {
        messageRepo.sendTextMessage(currentRoom.roomId.uid, controller.text);
      }

      controller.clear();
      messageText = "";

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
    if (isDesktop() &&
        str.isNotEmpty &&
        str.lastIndexOf("\n") == str.length - 1) {
      sendMessage();
      return;
    }
    if (currentRoom.roomId.getUid().category == Categories.BOT) {
      if (str.isNotEmpty && str.length == 1 && str.contains("/")) {
        _showBotCommands.add(true);
        return;
      }
    }
    messageText = str;
    if (currentRoom.roomId.getUid().category == Categories.GROUP) {
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
    if (currentRoom.roomId.getUid().category == Categories.BOT) {
      if (str.isNotEmpty && str.length == 1 && str.contains(" \ ")) {
        _showBotCommands.add(true);
      } else {
        _showBotCommands.add(false);
      }
    }
  }

  opacity() => x < 0.0 ? 1.0 : (DX - x) / DX;

  _attachFileInWindowsMode() async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
    final result = await openFiles(acceptedTypeGroups: [typeGroup]);
    messageRepo.sendFileMessageDeprecated(
        currentRoom.roomId.uid, result.map((e) => e.path).toList());
  }

  void scrollTolast(int count) {
    if (count < 3)
      Timer(Duration(milliseconds: count * 100), () {
        widget.scrollToLastSentMessage();
        scrollTolast(count + 1);
      });
  }

  void setTime() {
    _ticktickTimer = Timer(Duration(milliseconds: 500), () {
      recordSubject.add(DateTime.now());
      setTime();
    });
  }
}
