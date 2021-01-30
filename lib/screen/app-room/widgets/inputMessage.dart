import 'dart:async';
import 'dart:math';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/screen/app-room/widgets/bot_commandsWidget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/emojiKeybord.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recordAudioAnimation.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recordAudioslideWidget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box.dart';
import 'package:deliver_flutter/screen/app-room/widgets/showMentionList.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pbenum.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:flutter_timer/flutter_timer.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

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
      this.waitingForForward,
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
  double DX = 150.0;
  bool recordAudioPermission = false;
  String query;
  Timer recordAudioTimer;

  bool _showMentionList = false;

  bool startAudioRecorder = false;

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
  }

  @override
  Widget build(BuildContext context) {
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    AppLocalization appLocalization = AppLocalization.of(context);
    DX = min(MediaQuery.of(context).size.width / 2, 150.0);
    return Column(
      children: <Widget>[
        if (_showMentionList &&
            widget.currentRoom.roomId.getUid().category == Categories.GROUP)
          ShowMentionList(
            query: query,
            onSelected: (s) {
              controller.text = "${controller.text}${s} ";
              setState(() {
                _showMentionList = false;
              });
            },
            roomUid: widget.currentRoom.roomId,
          ),
        IconTheme(
          data: IconThemeData(color: Theme.of(context).accentColor),
          child: Container(
            color: ExtraTheme.of(context).secondColor,
            child: Stack(
              // overflow: Overflow.visible,
              children: <Widget>[
                controller.text.isEmpty &&
                        (widget.waitingForForward == null ||
                            widget.waitingForForward == false)
                    ? RecordAudioAnimation(
                        righPadding: x,
                        size: size,
                      )
                    : SizedBox.shrink(),
                Row(
                  children: <Widget>[
                    !startAudioRecorder
                        ? Expanded(
                            child: Row(
                              children: <Widget>[
                                if (currentRoom.roomId.getUid().category !=
                                    Categories.BOT)
                                  StreamBuilder<bool>(
                                      stream: backSubject.stream,
                                      builder: (c, back) {
                                        return IconButton(
                                          icon: Icon(
                                            back.hasData && back.data
                                                ? Icons.keyboard
                                                : Icons.mood,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            if (back.data) {
                                              backSubject.add(false);
                                              setState(() {
                                                FocusScope.of(context)
                                                    .unfocus();
                                              });
                                            } else if (!back.data) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              Timer(Duration(milliseconds: 50),
                                                  () {
                                                backSubject.add(true);
                                              });
                                            }
                                          },
                                        );
                                      }),
                                if (currentRoom.roomId.getUid().category ==
                                    Categories.BOT)
                                  GestureDetector(
                                    child: Text(
                                      " \ ",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onTap: () {
                                      BotCommandsWidget(
                                        botUid:
                                            widget.currentRoom.roomId.getUid(),
                                        onCommandClick: (String command) {
                                          messageRepo.sendTextMessage(
                                              widget.currentRoom.roomId
                                                  .getUid(),
                                              command);
                                        },
                                      );
                                    },
                                  ),
                                Container(
                                  child: Flexible(
                                    child: SizedBox(
                                        child: TextField(
                                      onTap: () {
                                        backSubject.add(false);
                                      },
                                      minLines: 1,
                                      maxLines: 15,
                                      autofocus: false,
                                      textInputAction: TextInputAction.newline,
                                      controller: controller,
                                      onSubmitted: null,
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
                                              .getTraslateValue("message")),
                                    )),
                                  ),
                                ),
                                controller.text?.isEmpty &&
                                        (widget.waitingForForward == null ||
                                            widget.waitingForForward == false)
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.attach_file,
                                          color: IconTheme.of(context).color,
                                        ),
                                        onPressed: () {
                                          backSubject.add(false);
                                          showButtonSheet();
                                        })
                                    : SizedBox(),
                                controller.text.isEmpty &&
                                        (widget.waitingForForward == null ||
                                            widget.waitingForForward == false)
                                    ? SizedBox.shrink()
                                    : IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        color: Colors.white,
                                        onPressed: controller.text?.isEmpty &&
                                                (widget.waitingForForward ==
                                                        null ||
                                                    widget.waitingForForward ==
                                                        false)
                                            ? () async {}
                                            : () {
                                                sendMessage();
                                              },
                                      ),
                              ],
                            ),
                          )
                        : RecordAudioSlideWidget(
                            opacity: opacity(),
                            time: time,
                            rinning: startAudioRecorder),
                    controller.text.isEmpty &&
                            (widget.waitingForForward == null ||
                                widget.waitingForForward == false)
                        ? GestureDetector(
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
                                  Vibration.vibrate(duration: 100);
                                  setState(() {
                                    startAudioRecorder = false;
                                    x = 0;
                                    size = 1;
                                  });
                                }
                              }
                            },
                            onLongPressStart: (dw) async {
                              if (recordAudioPermission) {
                                sendRecordActivity();
                                Vibration.vibrate(duration: 200);
                                setState(() {
                                  startAudioRecorder = true;
                                  size = 2;
                                  started = true;
                                  time = DateTime.now();
                                });

                                await AudioRecorder.start(
                                    path: await ExtStorage
                                        .getExternalStoragePublicDirectory(
                                            "${ExtStorage.DIRECTORY_MUSIC}/${randomString(10)}"),
                                    audioOutputFormat: AudioOutputFormat.AAC);
                              }
                            },
                            onLongPressEnd: (s) async {
                              recordAudioTimer.cancel();
                              NoActivitySubject.add(ActivityType.NO_ACTIVITY);
                              setState(() {
                                startAudioRecorder = false;
                                x = 0;
                                size = 1;
                              });
                              if (started) {
                                try {
                                  Recording recording =
                                      await AudioRecorder.stop();
                                  messageRepo.sendFileMessageDeprecated(
                                      widget.currentRoom.roomId.uid,
                                      [recording.path]);
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
                            ))
                        : SizedBox(
                            height: 50,
                          ),
                  ],
                ),
              ],
            ),
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
                        setState(() {
                          controller.text = controller.text + emoji.toString();
                        });
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
    isTypingActivitySubject.add(ActivityType.NO_ACTIVITY);
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

      _showMentionList = false;
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
    messageText = str;
    if (str.isEmpty) {
      _showMentionList = false;
      setState(() {});
      return;
    }
    try {
      query = "";
      int i = str.lastIndexOf("@");
      if (i != 0 && str[i - 1] != " ") {
        return;
      }
      if (i != -1 && !str.contains(" ", i)) {
        query = str.substring(i + 1, str.length);
        _showMentionList = true;
      } else {
        _showMentionList = false;
      }
    } catch (e) {}
    setState(() {});
  }

  opacity() => x < 0.0 ? 1.0 : (DX - x) / DX;

  _attachFileInWindowsMode() async {
    final result = await showOpenPanel(
      allowsMultipleSelection: true,
    );
    if (result.paths != null) {
      messageRepo.sendFileMessageDeprecated(
          currentRoom.roomId.uid, result.paths);
    }
  }
}
