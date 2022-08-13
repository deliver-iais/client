import 'dart:async';

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
import 'package:deliver/screen/room/messageWidgets/input_message_text_controller.dart';
import 'package:deliver/screen/room/messageWidgets/max_lenght_text_input_formatter.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/widgets/bot_commands.dart';
import 'package:deliver/screen/room/widgets/emoji_keybord.dart';
import 'package:deliver/screen/room/widgets/record_audio_animation.dart';
import 'package:deliver/screen/room/widgets/record_audio_slide_widget.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/screen/room/widgets/show_mention_list.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/methods/keyboard.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/attach_location.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import '../../navigation_center/widgets/feature_discovery_description_widget.dart';

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
  final InputMessageTextController textController;
  final Function(int dir, bool, bool) handleScrollToMessage;
  final Function() deleteSelectedMessage;

  const InputMessage({
    super.key,
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
  });

  @override
  InputMessageWidgetState createState() => InputMessageWidgetState();
}

class InputMessageWidgetState extends State<InputMessage> {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _uxService = GetIt.I.get<UxService>();
  static final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();
  static final _logger = GetIt.I.get<Logger>();
  static final checkPermission = GetIt.I.get<CheckPermissionsService>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _botRepo = GetIt.I.get<BotRepo>();
  static final _audioService = GetIt.I.get<AudioService>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _featureFlags = GetIt.I.get<FeatureFlags>();

  late Room currentRoom;
  final BehaviorSubject<bool> _showEmojiKeyboard =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _showSendIcon = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> _mentionQuery = BehaviorSubject.seeded(null);
  final BehaviorSubject<String> _botCommandQuery = BehaviorSubject.seeded("-");
  TextEditingController captionTextController = TextEditingController();
  late TextSelectionControls selectionControls;
  bool isMentionSelected = false;
  late FocusNode keyboardRawFocusNode;
  Subject<ActivityType> isTypingActivitySubject = BehaviorSubject();
  Subject<ActivityType> noActivitySubject = BehaviorSubject();
  BehaviorSubject<TextDirection> textDirection =
      BehaviorSubject.seeded(TextDirection.ltr);
  late String _botCommandData;
  int mentionSelectedIndex = 0;
  int botCommandSelectedIndex = 0;
  bool _shouldSynthesize = true;

  final botCommandRegexp = RegExp(r"(\w)*");
  final idRegexp = RegExp(r"^[a-zA-Z]([a-zA-Z0-9_]){0,19}$");

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
      _messageRepo.sendActivity(widget.currentRoom.uid.asUid(), activityType);
    });
    noActivitySubject.listen((event) {
      _messageRepo.sendActivity(widget.currentRoom.uid.asUid(), event);
    });
    _audioService.recordingDuration.listen((value) {
      if (value.compareTo(Duration.zero) > 0 &&
          _audioService.recordingRoom == widget.currentRoom.uid) {
        isTypingActivitySubject.add(ActivityType.RECORDING_VOICE);
      }
    });

    _showSendIcon
        .add(currentRoom.draft != null && currentRoom.draft!.isNotEmpty);
    widget.textController.addListener(() {
      _showSendIcon.add(widget.textController.text.isNotEmpty);
      if (widget.textController.text.isNotEmpty) {
        textDirection.add(getDirection(widget.textController.text));
      }

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
      } else {
        _botCommandQuery.add("-");
      }

      if (currentRoom.uid.asUid().category == Categories.GROUP &&
          widget.textController.selection.start > 0) {
        final str = widget.textController.text;
        final start =
            str.lastIndexOf("@", widget.textController.selection.start);

        if (start == -1) {
          _mentionQuery.add(null);
        }

        try {
          if (widget.textController.text.isNotEmpty &&
              widget.textController.text[start] == "@" &&
              (start == 0 || widget.textController.text[start - 1] == " ") &&
              widget.textController.selection.start ==
                  widget.textController.selection.end &&
              (idRegexp.hasMatch(
                    widget.textController.text.substring(
                      start + 1,
                      widget.textController.selection.start,
                    ),
                  ) ||
                  widget.textController.text
                      .substring(
                        start + 1,
                        widget.textController.selection.start,
                      )
                      .isEmpty)) {
            _mentionQuery.add(
              widget.textController.text
                  .substring(start + 1, widget.textController.selection.start),
            );
          } else {
            _mentionQuery.add(null);
          }
        } catch (e) {
          _mentionQuery.add(null);
        }
      } else if (widget.textController.text.isEmpty) {
        _mentionQuery.add(null);
      }
    });
    selectionControls = CustomTextSelectionController(
      buildContext: context,
      textController: widget.textController,
      captionController: captionTextController,
      roomUid: currentRoom.uid.asUid(),
      enableMarkDown: enableMarkdown,
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
    return WillPopScope(
      onWillPop: () async {
        if (_showEmojiKeyboard.value) {
          _showEmojiKeyboard.add(false);
          return false;
        } else {
          return true;
        }
      },
      child: IconTheme(
        data: IconThemeData(opacity: 0.6, color: theme.iconTheme.color),
        child: Column(
          children: <Widget>[
            StreamBuilder<String?>(
              stream: _mentionQuery.distinct(),
              builder: (c, showMention) {
                if (showMention.hasData && showMention.data != null) {
                  return ShowMentionList(
                    query: showMention.data!,
                    onSelected: (s) {
                      onMentionSelected(s);
                    },
                    roomUid: widget.currentRoom.uid,
                    mentionSelectedIndex: mentionSelectedIndex,
                  );
                }
                mentionSelectedIndex = 0;
                return const SizedBox.shrink();
              },
            ),
            StreamBuilder<String>(
              stream: _botCommandQuery.distinct(),
              builder: (c, show) {
                _botCommandData = show.data ?? "-";
                if (_botCommandData == "-") {
                  botCommandSelectedIndex = 0;
                }
                return BotCommands(
                  botUid: widget.currentRoom.uid.asUid(),
                  query: _botCommandData,
                  onCommandClick: (command) {
                    onCommandSelected(command);
                  },
                  botCommandSelectedIndex: botCommandSelectedIndex,
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  StreamBuilder<bool>(
                    stream: _audioService.recorderIsRecording,
                    builder: (ctx, snapshot) {
                      final isRecording = snapshot.data ?? false;
                      final isRecordingInCurrentRoom =
                          _audioService.recordingRoom == widget.currentRoom.uid;

                      return Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            if (!isRecording) buildEmojiKeyboardActions(),
                            if (!isRecording) buildTextInput(theme),
                            if (!isRecording) buildDefaultActions(),
                            if (isRecording && isRecordingInCurrentRoom)
                              const RecordAudioSlideWidget(),
                            if (isRecording && !isRecordingInCurrentRoom)
                              Expanded(
                                child: IconButton(
                                  icon: SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () => _routingService.openRoom(
                                        _audioService.recordingRoom,
                                      ),
                                      // color: theme.colorScheme.primary,
                                      child: Text(
                                        _i18n.get("go_to_recording_room"),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                  StreamBuilder<bool>(
                    stream: _showSendIcon,
                    builder: (c, sm) {
                      if (!sm.hasData ||
                          sm.data! ||
                          widget.waitingForForward ||
                          !_audioService.recorderIsAvailable()) {
                        return const SizedBox();
                      }

                      return RecordAudioAnimation(
                        onComplete: (res) {
                          if (res != null) {
                            unawaited(
                              _messageRepo.sendFileMessage(
                                widget.currentRoom.uid.asUid(),
                                File(res, res),
                              ),
                            );
                          }
                        },
                        roomUid: widget.currentRoom.uid.asUid(),
                      );
                    },
                  )
                ],
              ),
            ),
            StreamBuilder<bool>(
              stream: _showEmojiKeyboard,
              builder: (context, back) {
                final showEmojiKeyboard = back.data ?? false;

                return AnimatedContainer(
                  duration: SLOW_ANIMATION_DURATION,
                  curve: Curves.easeInOut,
                  height: showEmojiKeyboard ? 270.0 : 0,
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
                        widget.textController.text = block_1 + emoji + block_2;
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
              },
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<bool> buildEmojiKeyboardActions() {
    return StreamBuilder<bool>(
      stream: _showEmojiKeyboard,
      builder: (context, snapshot) {
        final showEmojiKeyboard = snapshot.data ?? false;
        return IconButton(
          icon: Icon(
            showEmojiKeyboard
                ? CupertinoIcons.keyboard_chevron_compact_down
                : CupertinoIcons.smiley,
          ),
          onPressed: () {
            if (showEmojiKeyboard) {
              _showEmojiKeyboard.add(false);
              widget.focusNode.requestFocus();
            } else if (!showEmojiKeyboard) {
              if (isDesktop) {
                _showEmojiKeyboard.add(true);
              } else {
                FocusScope.of(context).unfocus();
                Timer(
                    const Duration(
                      milliseconds: 200,
                    ), () {
                  _showEmojiKeyboard.add(true);
                });
              }
            }
          },
        );
      },
    );
  }

  StreamBuilder<bool> buildDefaultActions() {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      stream: _showSendIcon,
      builder: (context, snapshot) {
        final showSendButton =
            (snapshot.data ?? false) || widget.waitingForForward;

        final showCommandsButton = !showSendButton &&
            currentRoom.uid.asUid().category == Categories.BOT;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showCommandsButton)
              IconButton(
                icon: const Icon(
                  CupertinoIcons.slash_circle,
                ),
                onPressed: () => {
                  widget.focusNode.requestFocus(),
                  _botCommandQuery.add(
                    _botCommandQuery.value == "-" ? "" : "-",
                  ),
                },
              ),
            if ((isWindows || isMacOS) &&
                !showSendButton &&
                !widget.waitingForForward)
              IconButton(
                icon: const Icon(
                  CupertinoIcons.location,
                ),
                onPressed: () => AttachLocation(
                  context,
                  currentRoom.uid.asUid(),
                ).attachLocationInWindows(),
              ),
            if (!showSendButton && !widget.waitingForForward)
              IconButton(
                icon: const Icon(
                  CupertinoIcons.paperclip,
                ),
                onPressed: () {
                  _showEmojiKeyboard.add(false);

                  showButtonSheet();
                },
              ),
            if (showSendButton && !widget.waitingForForward)
              DescribedFeatureOverlay(
                featureId: _featureFlags
                            .hasVoiceCallPermission(widget.currentRoom.uid) ||
                        FeatureDiscovery.currentFeatureIdOf(context) ==
                            FEATURE_5
                    ? FEATURE_5
                    : FEATURE_4,
                useCustomPosition: true,
                contentLocation: ContentLocation.above,
                tapTarget: const FaIcon(
                  FontAwesomeIcons.markdown,
                ),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                targetColor: theme.colorScheme.tertiary,
                title: Text(
                  _i18n.get("markdown_feature_discovery_title"),
                  textDirection: _i18n.defaultTextDirection,
                  style: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                overflowMode: OverflowMode.extendBackground,
                description: FeatureDiscoveryDescriptionWidget(
                  description: _i18n.get("markdown_feature_description"),
                  descriptionStyle: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.markdown,
                    size: 18,
                    color: !_shouldSynthesize ? ACTIVE_COLOR : null,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.textController.isMarkDownEnable =
                          _shouldSynthesize;
                      _shouldSynthesize = !_shouldSynthesize;
                    });
                  },
                ),
              ),
            if (showSendButton || widget.waitingForForward)
              IconButton(
                icon: const Icon(
                  CupertinoIcons.paperplane_fill,
                  color: Colors.blue,
                ),
                onPressed: widget.textController.text.isEmpty &&
                        !widget.waitingForForward
                    ? () async {}
                    : () {
                        sendMessage();
                      },
              )
          ],
        );
      },
    );
  }

  Flexible buildTextInput(ThemeData theme) {
    return Flexible(
      child: StreamBuilder<Message?>(
        stream: widget.replyMessageIdStream,
        builder: (context, snapshot) {
          return RawKeyboardListener(
            focusNode: keyboardRawFocusNode,
            onKey: handleKey,
            child: StreamBuilder<TextDirection>(
              stream: textDirection.distinct(),
              builder: (c, sn) {
                final textDir = sn.data ?? TextDirection.ltr;
                return TextField(
                  selectionControls: selectionControls,
                  focusNode: widget.focusNode,
                  autofocus: (snapshot.data?.id ?? 0) > 0 || isDesktop,
                  controller: widget.textController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(top: 12, bottom: 12),
                    border: InputBorder.none,
                    counterText: "",
                    hintText: _i18n.get("write_a_message"),
                    hintTextDirection: _i18n.defaultTextDirection,
                    hintStyle: theme.textTheme.bodyMedium,
                  ),
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: isAndroid ? 10 : 15,
                  maxLength: INPUT_MESSAGE_TEXT_FIELD_MAX_LENGTH,
                  inputFormatters: [
                    MaxLinesTextInputFormatter(
                      INPUT_MESSAGE_TEXT_FIELD_MAX_LINE,
                    )
                    //max line of text field
                  ],
                  textDirection: textDir,
                  style: theme.textTheme.bodyMedium,
                  onTap: () {
                    if (!isDesktop) _showEmojiKeyboard.add(false);
                  },
                  onChanged: (str) {
                    if (str.isNotEmpty) {
                      isTypingActivitySubject.add(
                        ActivityType.TYPING,
                      );
                    } else {
                      noActivitySubject.add(
                        ActivityType.NO_ACTIVITY,
                      );
                    }
                  },
                );
              },
            ),
          );
        },
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
    widget.textController.text = "$block_1${s ?? ""} $block_2";
    widget.textController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: widget.textController.text.length - block_2.length,
      ),
    );
    _mentionQuery.add(null);
    isMentionSelected = true;
    if (isDesktop) {
      widget.focusNode.requestFocus();
    }
  }

  void onCommandSelected(String command) {
    widget.textController.text = "/$command";
    widget.textController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.textController.text.length),
    );
    _botCommandQuery.add("-");
  }

  void handleKey(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (widget.editableMessage == null) {
        Future.delayed(const Duration(milliseconds: 100), () {}).then((_) {
          if (widget.editableMessage != null) {
            moveCursorToEnd();
          }
        });
      }
    }
  }

  KeyEventResult handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        {PhysicalKeyboardKey.arrowUp, PhysicalKeyboardKey.arrowDown}
            .contains(event.physicalKey)) {
      if (_mentionQuery.value == null && _botCommandQuery.value == "-") {
        _handleArrow(event);
      }
    }
    if (event is RawKeyUpEvent &&
        event.physicalKey == PhysicalKeyboardKey.delete) {
      widget.deleteSelectedMessage();
    }
    if (((!_uxService.sendByEnter && event.isShiftPressed) ||
            (_uxService.sendByEnter && !event.isShiftPressed)) &&
        isEnterClicked(event)) {
      if (widget.currentRoom.uid.isGroup() &&
          mentionSelectedIndex >= 0 &&
          _mentionQuery.value != null) {
        addMentionByEnter();
      } else if (widget.currentRoom.uid.isBot() &&
          botCommandSelectedIndex >= 0 &&
          _botCommandQuery.value != "-") {
        addBotCommandByEnter();
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
          _mentionQuery.value,
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
          _botCommandData,
        );
      });
    }

    return KeyEventResult.ignored;
  }

  Future<void> _handleCV(RawKeyEvent event) async {
    unawaited(
      _rawKeyboardService.controlVHandle(
        widget.textController,
        context,
        widget.currentRoom.uid.asUid(),
      ),
    );
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
    Future.delayed(const Duration(), () {}).then((_) {
      moveCursorToEnd();
    });
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

  Future<void> addBotCommandByEnter() async {
    final value = await _botRepo.getBotInfo(widget.currentRoom.uid.asUid());
    if (value != null && value.commands!.isNotEmpty) {
      onCommandSelected(
        value.commands!.keys
            .where((element) => element.contains(_botCommandData))
            .toList()[botCommandSelectedIndex],
      );
    } else {
      sendMessage();
    }
  }

  Future<void> addMentionByEnter() async {
    final value = await _mucRepo.getFilteredMember(
      widget.currentRoom.uid,
      query: _mentionQuery.value,
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
      _mucRepo
          .getFilteredMember(currentRoom.uid, query: _mentionQuery.value)
          .then(
            (value) => {
              mentionSelectedIndex = value.length,
            },
          );
    } else {
      mentionSelectedIndex--;
    }
    Future.delayed(const Duration(), () {
      moveCursorToEnd();
    });
  }

  void sendMessage() {
    if (widget.textController.text.contains("\n") &&
        widget.textController.text.contains("@") &&
        isMentionSelected) {
      isMentionSelected = false;
    }
    if (widget.waitingForForward == true) {
      widget.sendForwardMessage?.call();
      widget.resetRoomPageDetails!();
    }

    final text = _shouldSynthesize
        ? synthesize(widget.textController.text.trim())
        : widget.textController.text.trim();

    if (text.isNotEmpty) {
      if (_replyMessageId > 0) {
        _messageRepo.sendTextMessage(
          currentRoom.uid.asUid(),
          text,
          replyId: _replyMessageId,
        );
        widget.resetRoomPageDetails!();
      } else {
        if (widget.editableMessage != null) {
          _messageRepo.editTextMessage(
            currentRoom.uid.asUid(),
            widget.editableMessage!,
            text,
          );
        } else {
          _messageRepo.sendTextMessage(currentRoom.uid.asUid(), text);
        }
      }

      widget.textController.clear();

      _mentionQuery.add(null);
    }
    if (widget.editableMessage != null) {
      widget.resetRoomPageDetails!();
    } else {
      widget.scrollToLastSentMessage();
    }
  }

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
    _mucRepo
        .getFilteredMember(currentRoom.uid, query: _mentionQuery.value)
        .then(
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
    return "$text ";
  }

  void moveCursorToEnd() {
    widget.textController.selection = TextSelection.collapsed(
      offset: widget.textController.text.length,
    );
  }

  void enableMarkdown() {
    if (_shouldSynthesize) {
      setState(() {
        _shouldSynthesize = false;
        widget.textController.isMarkDownEnable = true;
      });
    }
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
