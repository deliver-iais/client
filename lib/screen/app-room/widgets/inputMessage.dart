import 'dart:io';
import 'dart:math';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/screen/app-room/widgets/emojiKeybord.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box.dart';
import 'package:deliver_flutter/services/uploadFileServices.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:flutter_timer/flutter_timer.dart';
import 'package:get_it/get_it.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:random_string/random_string.dart';
import 'package:vibration/vibration.dart';
import 'package:ext_storage/ext_storage.dart';

const ANIMATION_DURATION = const Duration(milliseconds: 100);

class InputMessage extends StatefulWidget {
  final Room currentRoom;

  @override
  _InputMessageWidget createState() => _InputMessageWidget();

  InputMessage({@required this.currentRoom});
}

class _InputMessageWidget extends State<InputMessage> {
  var messageDao = GetIt.I.get<MessageDao>();
  var roomDao = GetIt.I.get<RoomDao>();

  var uploadFile = GetIt.I.get<UploadFileServices>();
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

  bool startAudioRecorder = false;

  AudioRecorder _audioRecorder;

  Widget showButtonSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ShareBox();
        });
  }

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
    currentRoom = widget.currentRoom;
  }

  @override
  Widget build(BuildContext context) {
    DX = min(MediaQuery.of(context).size.width / 2, 150.0);
    return Column(
      children: <Widget>[
        IconTheme(
          data: IconThemeData(color: Theme.of(context).accentColor),
          child: Container(
            color: ExtraTheme.of(context).secondColor,
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                controller.text.isEmpty
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
                                        hintText: " message"),
                                  ),
                                ),
                                controller.text?.isEmpty
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
                                controller.text.isEmpty
                                    ? SizedBox.shrink()
                                    : IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        color: Colors.white,
                                        onPressed: controller.text?.isEmpty
                                            ? () async {}
                                            : () {
                                                if (controller
                                                    .text.isNotEmpty) {
                                                  final newMessage = Message(
                                                      roomId:
                                                          currentRoom.roomId,
                                                      id: currentRoom
                                                              .lastMessage +
                                                          1,
                                                      time: DateTime.now(),
                                                      from: "users:john",
                                                      to: "users:jain",
                                                      edited: false,
                                                      encrypted: false,
                                                      type: MessageType.text,
                                                      content: controller.text,
                                                      seen: false);
                                                  messageDao.insertMessage(
                                                      newMessage);
                                                  currentRoom =
                                                      currentRoom.copyWith(
                                                          lastMessage: currentRoom
                                                                  .lastMessage +
                                                              1);
                                                  roomDao
                                                      .updateRoom(currentRoom);
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
                                    Text("Slide to cancel",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    controller.text.isEmpty
                        ? GestureDetector(
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
                              bool per = await checkPermission();
                              if (per) {
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
                              } else {
                                grantPermission();
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
                                  uploadFile.uploadFile(recording.path);
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
                            )
                    )
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

  Future checkPermission() async {
    try {
      return (await PermissionsPlugin.checkPermissions([
            Permission.RECORD_AUDIO,
          ]))[Permission.RECORD_AUDIO] ==
          PermissionState.GRANTED;
    } catch (e) {
      return false;
    }
  }

  grantPermission() {
    PermissionsPlugin.requestPermissions([Permission.RECORD_AUDIO]);
  }

  opacity() => x < 0.0 ? 1.0 : (DX - x) / DX;
}
