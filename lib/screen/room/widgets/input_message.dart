import 'dart:async';
import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/widgets/bot_commands.dart';
import 'package:deliver/screen/room/widgets/emoji_keybord.dart';
import 'package:deliver/screen/room/widgets/record_audio_animation.dart';
import 'package:deliver/screen/room/widgets/record_audio_slide_widget.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/show_mention_list.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

class InputMessage extends StatefulWidget {
  final Room currentRoom;
  final int replyMessageId;
  final Function? resetRoomPageDetails;
  final bool waitingForForward;
  final Function? sendForwardMessage;
  final Function? showMentionList;
  final Function scrollToLastSentMessage;
  final Message? editableMessage;
  final FocusNode focusNode;
  final TextEditingController textController;

  @override
  _InputMessageWidget createState() => _InputMessageWidget();

  const InputMessage({
    Key? key,
    required this.currentRoom,
    required this.scrollToLastSentMessage,
    required this.focusNode,
    required this.textController,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
    this.waitingForForward = false,
    this.sendForwardMessage,
    this.editableMessage,
    this.showMentionList,
  }) : super(key: key);
}

class _InputMessageWidget extends State<InputMessage> {
  MessageRepo messageRepo = GetIt.I.get<MessageRepo>();
  I18N i18n = GetIt.I.get<I18N>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _uxService = GetIt.I.get<UxService>();
  final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();
  final _logger = GetIt.I.get<Logger>();
  final checkPermission = GetIt.I.get<CheckPermissionsService>();
  late Room currentRoom;
  bool autofocus = false;
  double x = 0.0;
  double size = 1;
  bool started = false;
  DateTime time = DateTime.now();
  BehaviorSubject<DateTime> recordSubject =
      BehaviorSubject.seeded(DateTime.now());

  double dx = 150.0;
  bool recordAudioPermission = false;
  late String mentionQuery;
  late Timer recordAudioTimer;
  final BehaviorSubject<bool> _backSubject = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _showSendIcon = BehaviorSubject.seeded(false);
  final BehaviorSubject<String> _mentionQuery = BehaviorSubject.seeded("-");
  final BehaviorSubject<String> _botCommandQuery = BehaviorSubject.seeded("-");
  late Timer _tickTimer;
  TextEditingController captionTextController = TextEditingController();
  bool isMentionSelected = false;

  bool startAudioRecorder = false;

  late FocusNode keyboardRawFocusNode;

  Subject<ActivityType> isTypingActivitySubject = BehaviorSubject();
  Subject<ActivityType> noActivitySubject = BehaviorSubject();
  late String _mentionData;
  late String _botCommandData;
  int mentionSelectedIndex = 0;
  int botCommandSelectedIndex = 0;
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  var record = Record();

  final ValueNotifier<TextDirection> _textDir =
      ValueNotifier(TextDirection.ltr);

  var botCommandRegexp = RegExp(r"([a-zA-Z0-9_])*");
  var idRegexp = RegExp(r"([a-zA-Z0-9_])*");

  void showButtonSheet() {
    if (kIsWeb || isDesktop()) {
      _attachFileInWindowsMode();
    } else {
      FocusScope.of(context).unfocus();
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return ShareBox(
                currentRoomId: currentRoom.uid.asUid(),
                replyMessageId: widget.replyMessageId,
                resetRoomPageDetails: widget.resetRoomPageDetails!,
                scrollToLastSentMessage: widget.scrollToLastSentMessage);
          });
    }
  }

  @override
  void initState() {
    widget.focusNode.onKey = (FocusNode node, RawKeyEvent evt) {
      return handleKeyPress(evt);
    };

    keyboardRawFocusNode = FocusNode(canRequestFocus: false);

    currentRoom = widget.currentRoom;
    widget.textController.text = (currentRoom.draft ?? "");

    isTypingActivitySubject
        .throttle((_) => TimerStream(true, const Duration(seconds: 10)))
        .listen((activityType) {
      messageRepo.sendActivity(widget.currentRoom.uid.asUid(), activityType);
    });
    noActivitySubject.listen((event) {
      messageRepo.sendActivity(widget.currentRoom.uid.asUid(), event);
    });

    _showSendIcon
        .add(currentRoom.draft != null && currentRoom.draft!.isNotEmpty);
    widget.textController.addListener(() {
      _showSendIcon.add(widget.textController.text.isNotEmpty);
      if (currentRoom.uid.asUid().category == Categories.BOT &&
          widget.textController.text.isNotEmpty &&
          widget.textController.text[0] == "/" &&
          widget.textController.selection.start ==
              widget.textController.selection.end &&
          widget.textController.selection.start >= 1 &&
          botCommandRegexp.hasMatch(widget.textController.text
              .substring(0 + 1, widget.textController.selection.start))) {
        _botCommandQuery.add(widget.textController.text
            .substring(0 + 1, widget.textController.selection.start));
      } else if (widget.textController.text.isEmpty) {
        _botCommandQuery.add("-");
      }

      if (currentRoom.uid.asUid().category == Categories.GROUP &&
          widget.textController.selection.start > 0) {
        mentionQuery = "-";
        final str = widget.textController.text;
        int start = str.lastIndexOf("@", widget.textController.selection.start);

        if (start == -1) {
          _mentionQuery.add("-");
        }

        try {
          if (widget.textController.text.isNotEmpty &&
              widget.textController.text[start] == "@" &&
              widget.textController.selection.start ==
                  widget.textController.selection.end &&
              idRegexp.hasMatch(widget.textController.text.substring(
                  start + 1, widget.textController.selection.start))) {
            _mentionQuery.add(widget.textController.text
                .substring(start + 1, widget.textController.selection.start));
          } else {
            _mentionQuery.add("-");
          }
        } catch (e) {
          _mentionQuery.add("-");
        }
      } else if (widget.textController.text.isEmpty) {
        _mentionQuery.add("-");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _roomRepo.updateRoomDraft(currentRoom.uid, widget.textController.text);
    widget.textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    dx = min(MediaQuery.of(context).size.width / 2, 150.0);
    return WillPopScope(
      onWillPop: () async {
        if (_backSubject.value) {
          _backSubject.add(false);
          return false;
        } else {
          return true;
        }
      },
      child: Column(
        children: <Widget>[
          StreamBuilder<String>(
              stream: _mentionQuery.stream.distinct(),
              builder: (c, showMention) {
                _mentionData = showMention.data ?? "-";
                if (showMention.hasData) {
                  return ShowMentionList(
                    query: _mentionData,
                    onSelected: (s) {
                      onMentionSelected(s);
                    },
                    roomUid: widget.currentRoom.uid,
                    mentionSelectedIndex: mentionSelectedIndex,
                  );
                }
                return const SizedBox.shrink();
              }),
          StreamBuilder<String>(
              stream: _botCommandQuery.stream.distinct(),
              builder: (c, show) {
                _botCommandData = show.data ?? "-";
                return BotCommands(
                  botUid: widget.currentRoom.uid.asUid(),
                  query: _botCommandData,
                  onCommandClick: (String command) {
                    onCommandClick(command);
                  },
                  botCommandSelectedIndex: botCommandSelectedIndex,
                );
              }),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
            ),
            child: Stack(
              // overflow: Overflow.visible,
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: _showSendIcon.stream,
                    builder: (c, sh) {
                      if (sh.hasData &&
                          !sh.data! &&
                          !widget.waitingForForward &&
                          !isDesktop()) {
                        return RecordAudioAnimation(
                          rightPadding: x,
                          size: size,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                Row(
                  children: <Widget>[
                    !startAudioRecorder
                        ? Expanded(
                            child: Row(
                              children: <Widget>[
                                StreamBuilder<bool>(
                                    stream: _backSubject.stream,
                                    builder: (context, snapshot) {
                                      return IconButton(
                                        iconSize: _backSubject.value ? 24 : 28,
                                        icon: Icon(
                                          _backSubject.value
                                              ? CupertinoIcons
                                                  .keyboard_chevron_compact_down
                                              : CupertinoIcons.smiley,
                                        ),
                                        onPressed: () {
                                          if (_backSubject.value) {
                                            _backSubject.add(false);
                                            widget.focusNode.requestFocus();
                                          } else if (!_backSubject.value) {
                                            FocusScope.of(context).unfocus();
                                            Timer(
                                                const Duration(
                                                    milliseconds: 200), () {
                                              _backSubject.add(true);
                                            });
                                          }
                                        },
                                      );
                                    }),
                                Flexible(
                                  child: RawKeyboardListener(
                                    focusNode: keyboardRawFocusNode,
                                    child:
                                        ValueListenableBuilder<TextDirection>(
                                      valueListenable: _textDir,
                                      builder: (context, value, child) =>
                                          TextField(
                                        focusNode: widget.focusNode,
                                        autofocus: widget.replyMessageId > 0 ||
                                            isDesktop(),
                                        controller: widget.textController,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 12),
                                          border: InputBorder.none,
                                          hintText: i18n.get("message"),
                                        ),
                                        autocorrect: true,
                                        textInputAction:
                                            TextInputAction.newline,
                                        minLines: 1,
                                        maxLines: 15,
                                        textDirection: value,
                                        style: theme.textTheme.subtitle1,
                                        onTap: () => _backSubject.add(false),
                                        onChanged: (str) {
                                          if (str.trim().length < 2) {
                                            final dir = getDirection(str);
                                            if (dir != value) {
                                              _textDir.value = dir;
                                            }
                                          }
                                          if (str.isNotEmpty) {
                                            isTypingActivitySubject
                                                .add(ActivityType.TYPING);
                                          } else {
                                            noActivitySubject
                                                .add(ActivityType.NO_ACTIVITY);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (currentRoom.uid.asUid().category ==
                                    Categories.BOT)
                                  StreamBuilder<bool>(
                                      stream: _showSendIcon.stream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            !snapshot.data!) {
                                          return IconButton(
                                            iconSize: 28,
                                            icon: const Icon(
                                              CupertinoIcons.slash_circle,
                                            ),
                                            onPressed: () => _botCommandQuery
                                                .add(_botCommandQuery.value ==
                                                        "-"
                                                    ? ""
                                                    : "-"),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      }),
                                StreamBuilder<bool>(
                                    stream: _showSendIcon.stream,
                                    builder: (c, sh) {
                                      if (sh.hasData &&
                                          !sh.data! &&
                                          !widget.waitingForForward) {
                                        return IconButton(
                                            icon: const Icon(
                                              CupertinoIcons.paperclip,
                                            ),
                                            onPressed: () {
                                              _backSubject.add(false);
                                              showButtonSheet();
                                            });
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }),
                                StreamBuilder<bool>(
                                    stream: _showSendIcon.stream,
                                    builder: (c, sh) {
                                      if ((sh.hasData && sh.data!) ||
                                          widget.waitingForForward) {
                                        return IconButton(
                                          icon: const Icon(
                                            CupertinoIcons.paperplane_fill,
                                            color: Colors.blue,
                                          ),
                                          onPressed: widget.textController.text
                                                      .isEmpty &&
                                                  !widget.waitingForForward
                                              ? () async {}
                                              : () {
                                                  sendMessage();
                                                },
                                        );
                                      } else {
                                        return const SizedBox.shrink();
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
                    StreamBuilder<bool>(
                        stream: _showSendIcon.stream,
                        builder: (c, sm) {
                          if (sm.hasData &&
                              !sm.data! &&
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
                                      _tickTimer.cancel();
                                      Vibration.vibrate(duration: 200);
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
                                    var s =
                                        await getApplicationDocumentsDirectory();
                                    String path = s.path +
                                        "/Deliver/${DateTime.now().millisecondsSinceEpoch}.m4a";
                                    recordSubject.add(DateTime.now());
                                    setTime();
                                    sendRecordActivity();
                                    Vibration.vibrate(duration: 200);
                                    // Start recording
                                    await record.start(
                                      path: path,
                                      encoder: AudioEncoder.AAC, // by default
                                      bitRate: 128000, // by default
                                      samplingRate: 16000, // by default
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
                                  _tickTimer.cancel();
                                  var res = await record.stop();

                                  // _soundRecorder.closeAudioSession();
                                  recordAudioTimer.cancel();
                                  noActivitySubject
                                      .add(ActivityType.NO_ACTIVITY);
                                  setState(() {
                                    startAudioRecorder = false;
                                    x = 0;
                                    size = 1;
                                  });
                                  if (started) {
                                    try {
                                      messageRepo.sendFileMessage(
                                          widget.currentRoom.uid.asUid(),
                                          File(res!, res));
                                    } catch (_) {}
                                  }
                                },
                                child: const Opacity(
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
                            return const SizedBox(height: 50);
                          }
                        })
                  ],
                ),
              ],
            ),
          ),
          StreamBuilder<bool>(
              stream: _backSubject.stream,
              builder: (context, back) {
                if (back.hasData && back.data!) {
                  return SizedBox(
                      height: 270.0,
                      child: EmojiKeyboard(
                        onTap: (emoji) {
                          if (widget.textController.text.isNotEmpty) {
                            int start =
                                widget.textController.selection.baseOffset;
                            String block_1 =
                                widget.textController.text.substring(0, start);
                            block_1 = block_1.substring(0, start);
                            String block_2 = widget.textController.text
                                .substring(
                                    start, widget.textController.text.length);
                            widget.textController.text =
                                block_1 + emoji + block_2;
                            widget.textController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: widget.textController.text.length -
                                        block_2.length));
                          } else {
                            widget.textController.text =
                                widget.textController.text + emoji;
                            widget.textController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: widget.textController.text.length));
                          }
                          if (isDesktop()) {
                            widget.focusNode.requestFocus();
                          }
                        },
                      ));
                } else {
                  return const SizedBox.shrink();
                }
              }),
        ],
      ),
    );
  }

  void onMentionSelected(s) {
    int start = widget.textController.selection.baseOffset;

    String block_1 = widget.textController.text.substring(0, start);
    int indexOf = block_1.lastIndexOf("@");
    block_1 = block_1.substring(0, indexOf + 1);
    String block_2 = widget.textController.text
        .substring(start, widget.textController.text.length);
    widget.textController.text = block_1 + s + " " + block_2;
    widget.textController.selection = TextSelection.fromPosition(TextPosition(
        offset: widget.textController.text.length - block_2.length));
    _mentionQuery.add("-");
    isMentionSelected = true;
    if (isDesktop()) {
      widget.focusNode.requestFocus();
    }
  }

  onCommandClick(String command) {
    widget.textController.text = "/" + command;
    widget.textController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.textController.text.length));
    _botCommandQuery.add("-");
  }

  KeyEventResult handleKeyPress(event) {
    if (event is RawKeyEvent) {
      if (!_uxService.sendByEnter &&
          event.isShiftPressed &&
          (event.physicalKey == PhysicalKeyboardKey.enter ||
              event.physicalKey == PhysicalKeyboardKey.numpadEnter)) {
        if (event is RawKeyDownEvent) {
          if (widget.currentRoom.uid.isGroup() &&
              mentionSelectedIndex >= 0 &&
              _mentionData != "_") {
            sendMentionByEnter();
          } else {
            sendMessage();
          }
        }
        return KeyEventResult.handled;
      } else if (_uxService.sendByEnter &&
          !event.isShiftPressed &&
          (event.physicalKey == PhysicalKeyboardKey.enter ||
              event.physicalKey == PhysicalKeyboardKey.numpadEnter)) {
        if (event is RawKeyDownEvent) {
          if (widget.currentRoom.uid.isGroup() &&
              mentionSelectedIndex >= 0 &&
              _mentionData != "_") {
            sendMentionByEnter();
          } else {
            sendMessage();
          }
        }
        return KeyEventResult.handled;
      }
    }
    _rawKeyboardService.handleCopyPastKeyPress(widget.textController, event);
    if (widget.currentRoom.uid.asUid().isGroup()) {
      setState(() {
        _rawKeyboardService.navigateInMentions(
          _mentionData,
          scrollDownInMentions,
          event,
          mentionSelectedIndex,
          scrollUpInMentions,
        );
      });
    }
    if (widget.currentRoom.uid.asUid().isBot()) {
      setState(() {
        _rawKeyboardService.navigateInBotCommand(event, scrollDownInBotCommand,
            scrollUpInBotCommand, sendBotCommandByEnter, _botCommandData);
      });
    }

    return KeyEventResult.ignored;
  }

  scrollUpInBotCommand() {
    int length = 0;
    if (botCommandSelectedIndex <= 0) {
      _botRepo.getBotInfo(widget.currentRoom.uid.asUid()).then((value) => {
            if (value != null)
              value.commands!.forEach((key, value) {
                if (key.contains(_botCommandData)) length++;
              }),
            botCommandSelectedIndex = length - 1,
          });
    } else {
      botCommandSelectedIndex--;
    }
  }

  sendBotCommandByEnter() async {
    _botRepo.getBotInfo(widget.currentRoom.uid.asUid()).then((value) => {
          if (value != null)
            onCommandClick(
                value.commands!.keys.toList()[botCommandSelectedIndex])
        });
  }

  sendMentionByEnter() async {
    var value = await _mucRepo.getFilteredMember(widget.currentRoom.uid,
        query: _mentionData);
    if (value.isNotEmpty) {
      onMentionSelected(value[mentionSelectedIndex]!.id!);
    } else {
      sendMessage();
    }
  }

  scrollDownInBotCommand() {
    int length = 0;
    _botRepo.getBotInfo(widget.currentRoom.uid.asUid()).then((value) => {
          if (value != null)
            value.commands!.forEach((key, value) {
              if (key.contains(_botCommandData)) length++;
            }),
          if (botCommandSelectedIndex >= length)
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
    if (widget.textController.text.contains("\n") &&
        widget.textController.text.contains("@") &&
        isMentionSelected) {
      isMentionSelected = false;
    } else {
      noActivitySubject.add(ActivityType.NO_ACTIVITY);
    }
    if (widget.waitingForForward == true) {
      widget.sendForwardMessage!()!;
    }

    var text = widget.textController.text.trim();

    if (text.isNotEmpty) {
      if (widget.replyMessageId > 0) {
        messageRepo.sendTextMessage(
          currentRoom.uid.asUid(),
          text,
          replyId: widget.replyMessageId,
        );
        widget.resetRoomPageDetails!();
      } else {
        if (widget.editableMessage != null) {
          messageRepo.editTextMessage(
              currentRoom.uid.asUid(),
              widget.editableMessage!,
              widget.textController.text,
              currentRoom.lastMessageId);
          widget.resetRoomPageDetails!();
        } else {
          messageRepo.sendTextMessage(currentRoom.uid.asUid(), text);
        }
      }

      widget.textController.clear();

      _mentionQuery.add("-");
    }
    widget.scrollToLastSentMessage();
  }

  void sendRecordActivity() {
    recordAudioTimer = Timer(const Duration(seconds: 2), () {
      isTypingActivitySubject.add(ActivityType.RECORDING_VOICE);
      sendRecordActivity();
    });
  }

  opacity() => x < 0.0 ? 1.0 : (dx - x) / dx;

  _attachFileInWindowsMode() async {
    try {
      List<File> res = [];
      if (isLinux()) {
        final result = await openFiles();
        for (var file in result) {
          res.add(File(file.path, file.name, extension: file.mimeType));
        }
      } else {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(allowMultiple: true);
        for (var file in result!.files) {
          res.add(File(
              kIsWeb
                  ? Uri.dataFromBytes(file.bytes!.toList()).toString()
                  : file.path!,
              file.name,
              size: file.size,
              extension: file.extension));
        }
      }

      showCaptionDialog(files: res, icons: CupertinoIcons.cloud_upload);
    } catch (e) {
      _logger.d(e.toString());
    }
  }

  void setTime() {
    _tickTimer = Timer(const Duration(milliseconds: 500), () {
      recordSubject.add(DateTime.now());
      setTime();
    });
  }

  showCaptionDialog(
      {IconData? icons, String? type, required List<File> files}) async {
    if (files.isEmpty) return;

    showDialog(
        context: context,
        builder: (context) {
          return ShowCaptionDialog(
            resetRoomPageDetails: widget.resetRoomPageDetails,
            replyMessageId: widget.replyMessageId,
            files: files,
            type: kIsWeb
                ? files.first.extension
                : files.first.path.split(".").last,
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
    switch (widget.editableMessage!.type) {
      case MessageType.TEXT:
        text = widget.editableMessage!.json.toText().text;
        break;
      case MessageType.FILE:
        text = widget.editableMessage!.json.toFile().caption;
    }
    return text + " ";
  }
}

TextDirection getDirection(String v) {
  final string = v.trim();
  if (string.isEmpty) return TextDirection.ltr;
  if (string.isPersian()) {
    return TextDirection.rtl;
  }
  return TextDirection.ltr;
}
