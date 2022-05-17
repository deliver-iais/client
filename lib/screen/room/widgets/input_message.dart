import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/custom_text_selection_controller.dart';
import 'package:deliver/screen/room/messageWidgets/max_lenght_text_input_formatter.dart';
import 'package:deliver/screen/room/widgets/bot_commands.dart';
import 'package:deliver/screen/room/widgets/emoji_keybord.dart';
import 'package:deliver/screen/room/widgets/record_audio_animation.dart';
import 'package:deliver/screen/room/widgets/record_audio_slide_widget.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/screen/room/widgets/show_mention_list.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/methods/keyboard.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';

class InputMessage extends StatefulWidget {
  final Room currentRoom;
  final BehaviorSubject<Message?> replyMessageIdStream;
  final void Function()? resetRoomPageDetails;
  final bool waitingForForward;
  final void Function()? sendForwardMessage;
  final void Function()? showMentionList;
  final void Function() scrollToLastSentMessage;
  final Message? editableMessage;
  final FocusNode focusNode;
  final TextEditingController textController;
  final Function(int dir, bool, bool) handleScrollToMessage;
  final Function() deleteSelectedMessage;

  @override
  _InputMessageWidget createState() => _InputMessageWidget();

  const InputMessage({
    Key? key,
    required this.currentRoom,
    required this.scrollToLastSentMessage,
    required this.focusNode,
    required this.deleteSelectedMessage,
    required this.handleScrollToMessage,
    required this.textController,
    required this.replyMessageIdStream,
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
  DateTime _time = clock.now();
  BehaviorSubject<DateTime> recordSubject =
      BehaviorSubject.seeded(clock.now());

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
  late TextSelectionControls selectionControls;
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
  final record = Record();

  final ValueNotifier<TextDirection> _textDir =
      ValueNotifier(TextDirection.ltr);

  final botCommandRegexp = RegExp(r"([a-zA-Z0-9_])*");
  final idRegexp = RegExp(r"([a-zA-Z0-9_])*");

  void showButtonSheet() {
    if (isWeb || isDesktop) {
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
            replyMessageId: _replyMessageId,
            resetRoomPageDetails: widget.resetRoomPageDetails!,
            scrollToLastSentMessage: widget.scrollToLastSentMessage,
          );
        },
      );
    }
  }

  @override
  void initState() {
    widget.focusNode.onKey = (node, evt) {
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
          botCommandRegexp.hasMatch(
            widget.textController.text
                .substring(0 + 1, widget.textController.selection.start),
          )) {
        _botCommandQuery.add(
          widget.textController.text
              .substring(0 + 1, widget.textController.selection.start),
        );
      } else if (widget.textController.text.isEmpty) {
        _botCommandQuery.add("-");
      }

      if (currentRoom.uid.asUid().category == Categories.GROUP &&
          widget.textController.selection.start > 0) {
        mentionQuery = "-";
        final str = widget.textController.text;
        final start =
            str.lastIndexOf("@", widget.textController.selection.start);

        if (start == -1) {
          _mentionQuery.add("-");
        }

        try {
          if (widget.textController.text.isNotEmpty &&
              widget.textController.text[start] == "@" &&
              (start == 0 || widget.textController.text[start - 1] == " ") &&
              widget.textController.selection.start ==
                  widget.textController.selection.end &&
              idRegexp.hasMatch(
                widget.textController.text.substring(
                  start + 1,
                  widget.textController.selection.start,
                ),
              )) {
            _mentionQuery.add(
              widget.textController.text
                  .substring(start + 1, widget.textController.selection.start),
            );
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
    selectionControls = CustomTextSelectionController(
      buildContext: context,
      textController: widget.textController,
      captionController: captionTextController,
      roomUid: currentRoom.uid.asUid(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _roomRepo.updateRoomDraft(currentRoom.uid, widget.textController.text);
    widget.textController.dispose();
    super.dispose();
  }

  int get _replyMessageId => widget.replyMessageIdStream.value?.id ?? 0;

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
      child: IconTheme(
        data: IconThemeData(opacity: 0.6, color: theme.iconTheme.color),
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
              },
            ),
            StreamBuilder<String>(
              stream: _botCommandQuery.stream.distinct(),
              builder: (c, show) {
                _botCommandData = show.data ?? "-";
                return BotCommands(
                  botUid: widget.currentRoom.uid.asUid(),
                  query: _botCommandData,
                  onCommandClick: (command) {
                    onCommandClick(command);
                  },
                  botCommandSelectedIndex: botCommandSelectedIndex,
                );
              },
            ),
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
                          !isDesktop) {
                        return RecordAudioAnimation(
                          rightPadding: x,
                          size: size,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  Row(
                    children: <Widget>[
                      if (!startAudioRecorder)
                        Expanded(
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
                                        Timer(const Duration(milliseconds: 200),
                                            () {
                                          _backSubject.add(true);
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                              Flexible(
                                child: StreamBuilder<Message?>(
                                  stream: widget.replyMessageIdStream.stream,
                                  builder: (context, snapshot) {
                                    return RawKeyboardListener(
                                      focusNode: keyboardRawFocusNode,
                                      child:
                                          ValueListenableBuilder<TextDirection>(
                                        valueListenable: _textDir,
                                        builder: (context, textDirection, child) =>
                                            TextField(
                                          selectionControls: isDesktop
                                              ? selectionControls
                                              : null,
                                          focusNode: widget.focusNode,
                                          autofocus:
                                              (snapshot.data?.id ?? 0) > 0 ||
                                                  isDesktop,
                                          controller: widget.textController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            border: InputBorder.none,
                                            counterText: "",
                                            hintText: i18n.get("message"),
                                          ),
                                          textInputAction:
                                              TextInputAction.newline,
                                          minLines: 1,
                                          maxLines: 15,
                                          maxLength:
                                              INPUT_MESSAGE_TEXT_FIELD_MAX_LENGTH,
                                          inputFormatters: [
                                            MaxLinesTextInputFormatter(
                                              INPUT_MESSAGE_TEXT_FIELD_MAX_LINE,
                                            )
                                            //max line of text field
                                          ],
                                          textDirection: textDirection,
                                          style: theme.textTheme.subtitle1,
                                          onTap: () => _backSubject.add(false),
                                          onChanged: (str) {
                                            if (str.isNotEmpty) {
                                              final dir = getDirection(str);
                                              if (dir != textDirection) {
                                                _textDir.value = dir;
                                              }
                                            }
                                            if (str.isNotEmpty) {
                                              isTypingActivitySubject
                                                  .add(ActivityType.TYPING);
                                            } else {
                                              noActivitySubject.add(
                                                ActivityType.NO_ACTIVITY,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (currentRoom.uid.asUid().category ==
                                  Categories.BOT)
                                StreamBuilder<bool>(
                                  stream: _showSendIcon.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && !snapshot.data!) {
                                      return IconButton(
                                        iconSize: 28,
                                        icon: const Icon(
                                          CupertinoIcons.slash_circle,
                                        ),
                                        onPressed: () => _botCommandQuery.add(
                                          _botCommandQuery.value == "-"
                                              ? ""
                                              : "-",
                                        ),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
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
                                      },
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
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
                                      onPressed:
                                          widget.textController.text.isEmpty &&
                                                  !widget.waitingForForward
                                              ? () async {}
                                              : () {
                                                  sendMessage();
                                                },
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              )
                            ],
                          ),
                        )
                      else
                        RecordAudioSlideWidget(
                          opacity: opacity(),
                          time: _time,
                          running: startAudioRecorder,
                          streamTime: recordSubject,
                        ),
                      StreamBuilder<bool>(
                        stream: _showSendIcon.stream,
                        builder: (c, sm) {
                          if (sm.hasData &&
                              !sm.data! &&
                              !widget.waitingForForward &&
                              !isDesktop) {
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
                                  final s =
                                      await getApplicationDocumentsDirectory();
                                  final path = s.path +
                                      "/Deliver/${clock.now().millisecondsSinceEpoch}.m4a";
                                  recordSubject.add(clock.now());
                                  setTime();
                                  sendRecordActivity();
                                  Vibration.vibrate(duration: 200).ignore();
                                  // Start recording
                                  await record.start(
                                    path: path,
                                    samplingRate: 16000, // by default
                                  );
                                  setState(() {
                                    startAudioRecorder = true;
                                    size = 2;
                                    started = true;
                                    _time = clock.now();
                                  });
                                }
                              },
                              onLongPressEnd: (s) async {
                                _tickTimer.cancel();
                                final res = await record.stop();

                                // _soundRecorder.closeAudioSession();
                                recordAudioTimer.cancel();
                                setState(() {
                                  startAudioRecorder = false;
                                  x = 0;
                                  size = 1;
                                });
                                if (started) {
                                  try {
                                    unawaited(
                                      messageRepo.sendFileMessage(
                                        widget.currentRoom.uid.asUid(),
                                        File(res!, res),
                                      ),
                                    );
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
                              ),
                            );
                          } else {
                            return const SizedBox(height: 50);
                          }
                        },
                      )
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
                          final start =
                              widget.textController.selection.baseOffset;
                          var block_1 =
                              widget.textController.text.substring(0, start);
                          block_1 = block_1.substring(0, start);
                          final block_2 = widget.textController.text.substring(
                            start,
                            widget.textController.text.length,
                          );
                          widget.textController.text =
                              block_1 + emoji + block_2;
                          widget.textController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                              offset: widget.textController.text.length -
                                  block_2.length,
                            ),
                          );
                        } else {
                          widget.textController.text =
                              widget.textController.text + emoji;
                          widget.textController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                              offset: widget.textController.text.length,
                            ),
                          );
                        }
                        if (isDesktop) {
                          widget.focusNode.requestFocus();
                        }
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void onMentionSelected(String? s) {
    final start = widget.textController.selection.baseOffset;

    var block_1 = widget.textController.text.substring(0, start);
    final indexOf = block_1.lastIndexOf("@");
    block_1 = block_1.substring(0, indexOf + 1);
    final block_2 = widget.textController.text
        .substring(start, widget.textController.text.length);
    widget.textController.text = block_1 + (s ?? "") + " " + block_2;
    widget.textController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: widget.textController.text.length - block_2.length,
      ),
    );
    _mentionQuery.add("-");
    isMentionSelected = true;
    if (isDesktop) {
      widget.focusNode.requestFocus();
    }
  }

  void onCommandClick(String command) {
    widget.textController.text = "/" + command;
    widget.textController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.textController.text.length),
    );
    _botCommandQuery.add("-");
  }

  KeyEventResult handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        {PhysicalKeyboardKey.arrowUp, PhysicalKeyboardKey.arrowDown}
            .contains(event.physicalKey)) {
      _handleArrow(event);
    }
    if (event is RawKeyUpEvent &&
        event.physicalKey == PhysicalKeyboardKey.delete) {
      widget.deleteSelectedMessage();
    }
    if (!_uxService.sendByEnter &&
        event.isShiftPressed &&
        isEnterClicked(event)) {
      if (widget.currentRoom.uid.isGroup() &&
          mentionSelectedIndex >= 0 &&
          _mentionData != "_") {
        sendMentionByEnter();
      } else {
        sendMessage();
      }
      return KeyEventResult.handled;
    } else if (_uxService.sendByEnter &&
        !event.isShiftPressed &&
        isEnterClicked(event)) {
      if (widget.currentRoom.uid.isGroup() &&
          mentionSelectedIndex >= 0 &&
          _mentionData != "_") {
        sendMentionByEnter();
      } else {
        sendMessage();
      }
      return KeyEventResult.handled;
    }
    if (isMetaAndKeyPressed(event, PhysicalKeyboardKey.keyV)) {
      _handleCV(event);
      return KeyEventResult.handled;
    }

    _rawKeyboardService.handleCopyPastKeyPress(
      widget.textController,
      event,
      context,
      currentRoom.uid.asUid(),
    );
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
        _rawKeyboardService.navigateInBotCommand(
          event,
          scrollDownInBotCommand,
          scrollUpInBotCommand,
          sendBotCommandByEnter,
          _botCommandData,
        );
      });
    }

    return KeyEventResult.ignored;
  }

  Future<void> _handleCV(RawKeyEvent event) async {
    final files = await Pasteboard.files();
    if (files.isEmpty) {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      widget.textController.text = widget.textController.text + data!.text!.replaceAll("\r", "");
      widget.textController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.textController.text.length),
      );
    } else {
      unawaited(
        // ignore: use_build_context_synchronously
        _rawKeyboardService.controlVHandle(
          widget.textController,
          context,
          widget.currentRoom.uid.asUid(),
        ),
      );
    }
  }

  KeyEventResult _handleArrow(RawKeyEvent event) {
    if (event.physicalKey == PhysicalKeyboardKey.arrowUp &&
        widget.textController.selection.baseOffset <= 0) {
      widget.handleScrollToMessage(-1, event.isControlPressed, true);
    } else if (event.physicalKey == PhysicalKeyboardKey.arrowDown &&
        (widget.textController.selection.baseOffset ==
                widget.textController.text.length ||
            widget.textController.selection.baseOffset < 0)) {
      widget.handleScrollToMessage(1, event.isControlPressed, true);
    }
    return KeyEventResult.handled;
  }

  void scrollUpInBotCommand() {
    var length = 0;
    if (botCommandSelectedIndex <= 0) {
      _botRepo.getBotInfo(widget.currentRoom.uid.asUid()).then(
            (value) => {
              if (value != null)
                value.commands!.forEach((key, value) {
                  if (key.contains(_botCommandData)) length++;
                }),
              botCommandSelectedIndex = length - 1,
            },
          );
    } else {
      botCommandSelectedIndex--;
    }
  }

  void sendBotCommandByEnter() {
    _botRepo.getBotInfo(widget.currentRoom.uid.asUid()).then(
          (value) => {
            if (value != null)
              onCommandClick(
                value.commands!.keys.toList()[botCommandSelectedIndex],
              )
          },
        );
  }

  Future<void> sendMentionByEnter() async {
    final value = await _mucRepo.getFilteredMember(
      widget.currentRoom.uid,
      query: _mentionData,
    );
    if (value.isNotEmpty) {
      onMentionSelected(value[mentionSelectedIndex]!.id);
    } else {
      sendMessage();
    }
  }

  void scrollDownInBotCommand() {
    var length = 0;
    _botRepo.getBotInfo(widget.currentRoom.uid.asUid()).then(
          (value) => {
            if (value != null)
              value.commands!.forEach((key, value) {
                if (key.contains(_botCommandData)) length++;
              }),
            if (botCommandSelectedIndex >= length)
              botCommandSelectedIndex = 0
            else
              botCommandSelectedIndex++,
          },
        );
  }

  void scrollUpInMentions() {
    if (mentionSelectedIndex <= 0) {
      _mucRepo.getFilteredMember(currentRoom.uid, query: _mentionData).then(
            (value) => {
              mentionSelectedIndex = value.length - 1,
            },
          );
    } else {
      mentionSelectedIndex--;
    }
  }

  void sendMessage() {
    if (widget.textController.text.contains("\n") &&
        widget.textController.text.contains("@") &&
        isMentionSelected) {
      isMentionSelected = false;
    }
    if (widget.waitingForForward == true) {
      widget.sendForwardMessage?.call();
    }

    final text = widget.textController.text.trim();

    if (text.isNotEmpty) {
      if (_replyMessageId > 0) {
        messageRepo.sendTextMessage(
          currentRoom.uid.asUid(),
          text,
          replyId: _replyMessageId,
        );
        widget.resetRoomPageDetails!();
      } else {
        if (widget.editableMessage != null) {
          messageRepo.editTextMessage(
            currentRoom.uid.asUid(),
            widget.editableMessage!,
            widget.textController.text,
          );
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

  double opacity() => x < 0.0 ? 1.0 : (dx - x) / dx;

  Future<void> _attachFileInWindowsMode() async {
    try {
      final res = <File>[];
      if (isLinux) {
        final result = await openFiles();
        for (final file in result) {
          res.add(
            File(
              file.path,
              file.name,
              extension: file.mimeType,
              size: await file.length(),
            ),
          );
        }
      } else {
        final result = await FilePicker.platform.pickFiles(allowMultiple: true);
        for (final file in result!.files) {
          res.add(
            File(
              isWeb
                  ? Uri.dataFromBytes(file.bytes!.toList()).toString()
                  : file.path!,
              file.name,
              size: file.size,
              extension: file.extension,
            ),
          );
        }
      }

      showCaptionDialog(files: res, icons: CupertinoIcons.cloud_upload);
    } catch (e) {
      _logger.d(e.toString());
    }
  }

  void setTime() {
    _tickTimer = Timer(const Duration(milliseconds: 500), () {
      recordSubject.add(clock.now());
      setTime();
    });
  }

  void showCaptionDialog({
    IconData? icons,
    String? type,
    required List<File> files,
  }) {
    if (files.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return ShowCaptionDialog(
          resetRoomPageDetails: widget.resetRoomPageDetails,
          replyMessageId: _replyMessageId,
          files: files,
          type:
              isWeb ? files.first.extension : files.first.path.split(".").last,
          currentRoom: currentRoom.uid.asUid(),
        );
      },
    );
  }

  void scrollDownInMentions() {
    _mucRepo.getFilteredMember(currentRoom.uid, query: _mentionData).then(
          (value) => {
            if (mentionSelectedIndex >= value.length)
              {mentionSelectedIndex = 0}
            else
              {mentionSelectedIndex++}
          },
        );
  }

  String getEditableMessageContent() {
    var text = "";
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
