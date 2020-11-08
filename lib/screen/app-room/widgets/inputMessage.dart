import 'dart:io';
import 'dart:math';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/emojiKeybord.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:flutter_timer/flutter_timer.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:random_string/random_string.dart';
import 'package:vibration/vibration.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';

const ANIMATION_DURATION = const Duration(milliseconds: 100);

class InputMessage extends StatefulWidget {
  final Room currentRoom;
  final int replyMessageId;
  final Function resetRoomPageDetails;
  final bool waitingForForward;
  final Function sendForwardMessage;

  @override
  _InputMessageWidget createState() => _InputMessageWidget();

  InputMessage(
      {@required this.currentRoom,
      this.replyMessageId,
      this.resetRoomPageDetails,
      this.waitingForForward,
      this.sendForwardMessage});
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

  bool startAudioRecorder = false;

  var _messageRepo = GetIt.I.get<MessageRepo>();

  AudioRecorder _audioRecorder;

  Widget showButtonSheet() {
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
            );
          });
    }
  }

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
    currentRoom = widget.currentRoom;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    DX = min(MediaQuery.of(context).size.width / 2, 150.0);
    return Column(
      children: <Widget>[
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
                    ? AnimatedPositioned(
                        duration: ANIMATION_DURATION,
                        bottom: (1 - size) * 25,
                        right: x + ((1 - size) * 25),
                        child: ClipOval(
                          child: AnimatedContainer(
                            duration: ANIMATION_DURATION,
                            width: 50 * size,
                            height: 50 * size,
                            color: (1 - size) == 0
                                ? Colors.transparent
                                : Colors.blue,
                            child: Center(
                              child: Icon(
                                Icons.keyboard_voice,
                                size: 14 * (size - 1) +
                                    IconTheme.of(context).size,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                Row(
                  children: <Widget>[
                    !startAudioRecorder
                        ? Expanded(
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    showEmoji ? Icons.keyboard : Icons.mood,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (showEmoji) {
                                        showEmoji = false;
                                        autofocus = true;
                                      } else {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        showEmoji = true;
                                      }
                                    });
                                  },
                                ),
                                Flexible(
                                  child: TextField(
                                    onTap: () {
                                      showEmoji = false;
                                    },
                                    minLines: 1,
                                    maxLines: 15,
                                    autofocus: autofocus,
                                    textInputAction: TextInputAction.send,
                                    controller: controller,
                                    onSubmitted: null,
                                    onChanged: (str) {
                                      setState(() {
                                        messageText = str;
                                      });
                                    },
                                    decoration: InputDecoration.collapsed(
                                        hintText: appLocalization
                                            .getTraslateValue("message")),
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
                                          showEmoji = false;
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
                                                if (widget.waitingForForward ==
                                                    true) {
                                                  widget.sendForwardMessage();
                                                }
                                                if (controller
                                                    .text.isNotEmpty) {
                                                  if (controller.text
                                                      .isNotEmpty) if (widget
                                                          .replyMessageId !=
                                                      null) {
                                                    messageRepo.sendTextMessage(
                                                      currentRoom.roomId.uid,
                                                      controller.text,
                                                      replyId:
                                                          widget.replyMessageId,
                                                    );
                                                    widget
                                                        .resetRoomPageDetails();
                                                  } else {
                                                    messageRepo.sendTextMessage(
                                                      currentRoom.roomId.uid,
                                                      controller.text,
                                                    );
                                                  }

                                                  controller.clear();
                                                  messageText = "";
                                                }
                                              },
                                      ),
                              ],
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Stack(
                                  children: <Widget>[
                                    Opacity(
                                      opacity: 1.0 - opacity(),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Opacity(
                                      opacity: opacity(),
                                      child: Icon(
                                        Icons.fiber_manual_record,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TikTikTimer(
                                height: 20,
                                width: 70,
                                timerTextStyle: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColor),
                                initialDate: time,
                                running: startAudioRecorder,
                                backgroundColor:
                                    ExtraTheme.of(context).secondColor,
                                borderRadius: 0,
                                tracetime: (time) {
                                  print(time.currentSeconds.toString());
                                },
                              ),
                              Opacity(
                                opacity: opacity(),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.chevron_left),
                                    Text(
                                        appLocalization
                                            .getTraslateValue("slideToCancel"),
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                                Vibration.vibrate(duration: 200);
                                setState(() {
                                  startAudioRecorder = true;
                                  size = 2;
                                  started = true;
                                  time = DateTime.now();
                                });
                                _audioRecorder = await AudioRecorder.start(
                                    path: await ExtStorage
                                        .getExternalStoragePublicDirectory(
                                            "${ExtStorage.DIRECTORY_MUSIC}/${randomString(10)}"),
                                    audioOutputFormat: AudioOutputFormat.AAC);
                              }
                            },
                            onLongPressEnd: (s) async {
                              setState(() {
                                startAudioRecorder = false;
                                x = 0;
                                size = 1;
                              });
                              if (started) {
                                try {
                                  Recording recording =
                                      await AudioRecorder.stop();
                                  messageRepo.sendFileMessage(
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
                        : SizedBox.shrink()
                  ],
                ),
              ],
            ),
          ),
        ),
        showEmoji
            ? WillPopScope(
                onWillPop: () {
                  setState(() {
                    showEmoji = false;
                  });
                  return Future.value(false);
                },
                child: Container(
                    height: 220.0,
                    child: EmojiKeybord(
                      onTap: (emoji) {
                        setState(() {
                          controller.text = controller.text + emoji.toString();
                        });
                      },
                    )),
              )
            : SizedBox(),
      ],
    );
  }

  opacity() => x < 0.0 ? 1.0 : (DX - x) / DX;

  _attachFileInWindowsMode() async {
    final result = await showOpenPanel(
      allowsMultipleSelection: true,
    );
    if (result.paths != null) {
      messageRepo.sendFileMessage(currentRoom.roomId.uid, result.paths);
    }
  }
}
