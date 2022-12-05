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
import 'package:deliver/screen/room/messageWidgets/custom_text_selection/custom_text_selection_controller.dart';
import 'package:deliver/screen/room/messageWidgets/input_message_text_controller.dart';
import 'package:deliver/screen/room/messageWidgets/max_lenght_text_input_formatter.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/room/widgets/bot_commands.dart';
import 'package:deliver/screen/room/widgets/emoji/emoji_keybord_widget.dart';
import 'package:deliver/screen/room/widgets/markup/input_suggestions_widget.dart';
import 'package:deliver/screen/room/widgets/markup/reply_keyboard_markup.dart';
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
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/keyboard.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/attach_location.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

enum KeyboardStatus {
  OFF,
  DEFAULT_KEYBOARD,
  EMOJI_KEYBOARD,
  EMOJI_KEYBOARD_SEARCH,
  REPLY_KEYBOARD
}

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

  late Room currentRoom;

  final _keyboardStatus = BehaviorSubject.seeded(KeyboardStatus.OFF);

  final BehaviorSubject<bool> _showSendIcon = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> _mentionQuery = BehaviorSubject.seeded(null);
  final BehaviorSubject<String> _botCommandQuery = BehaviorSubject.seeded("-");
  TextEditingController captionTextController = TextEditingController();
  late TextSelectionControls selectionControls;
  bool isMentionSelected = false;
  late FocusNode keyboardRawFocusNode;
  Subject<ActivityType> isTypingActivitySubject = BehaviorSubject();
  Subject<ActivityType> noActivitySubject = BehaviorSubject();
  final keyboardVisibilityController = KeyboardVisibilityController();
  late String _botCommandData;
  int mentionSelectedIndex = 0;
  int botCommandSelectedIndex = 0;
  final _inputTextKey = GlobalKey();

  final botCommandRegexp = RegExp(r"(\w)*");
  final idRegexp = RegExp(r"^[a-zA-Z](\w){0,19}$");
  OverlayEntry? _desktopEmojiKeyboardOverlayEntry;
  final _desktopEmojiKeyboardFocusNode = FocusNode();

  void _attachFile() {
    if (isWeb || isDesktop) {
      _attachFileInDesktopMode();
    } else {
      FocusScope.of(context).unfocus();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ShareBox(
            currentRoomUid: currentRoom.uid.asUid(),
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

    _keyboardStatus.add(
      widget.currentRoom.replyKeyboardMarkup != null
          ? KeyboardStatus.REPLY_KEYBOARD
          : KeyboardStatus.OFF,
    );
    if (!hasVirtualKeyboardCapability) {
      _desktopEmojiKeyboardFocusNode.addListener(() {
        if (_desktopEmojiKeyboardFocusNode.hasFocus) {
          _showDesktopEmojiKeyboardOverlay();
        } else {
          _hideDesktopEmojiKeyboardOverlay();
        }
      });
    }
    if (!isDesktop) {
      keyboardVisibilityController.onChange.listen((visible) {
        if (visible) {
          if (_keyboardStatus.value != KeyboardStatus.EMOJI_KEYBOARD_SEARCH) {
            _keyboardStatus.add(KeyboardStatus.DEFAULT_KEYBOARD);
          }
        } else if (_keyboardStatus.valueOrNull ==
            KeyboardStatus.DEFAULT_KEYBOARD) {
          _keyboardStatus.add(KeyboardStatus.OFF);
        }
      });
    }

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
              (start == 0 ||
                  widget.textController.text[start - 1] == " " ||
                  widget.textController.text[start - 1] == "\n") &&
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
      roomUid: currentRoom.uid.asUid(),
    ).getCustomTextSelectionController();
    super.initState();
  }

  @override
  void dispose() {
    _roomRepo.updateRoomDraft(currentRoom.uid, widget.textController.text);
    widget.textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InputMessage oldWidget) {
    if (!keyboardVisibilityController.isVisible &&
        _keyboardStatus.valueOrNull == KeyboardStatus.DEFAULT_KEYBOARD) {
      _keyboardStatus.add(KeyboardStatus.OFF);
    }
    super.didUpdateWidget(oldWidget);
  }

  int get _replyMessageId => widget.replyMessageIdStream.value?.id ?? 0;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomOffset = mq.viewInsets.bottom + mq.padding.bottom;
    if (isAndroid) {
      setKeyBoardSize(bottomOffset, mq);
    }
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (_keyboardStatus.valueOrNull != KeyboardStatus.OFF) {
          if (_keyboardStatus.value == KeyboardStatus.EMOJI_KEYBOARD_SEARCH) {
            _keyboardStatus.add(KeyboardStatus.EMOJI_KEYBOARD);
          } else {
            _keyboardStatus.add(KeyboardStatus.OFF);
          }
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
            InputSuggestionsWidget(
              inputSuggestions: widget.currentRoom.lastMessage?.markup
                      ?.toMessageMarkup()
                      .inputSuggestions ??
                  [],
              textController: widget.textController,
            ),
            Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 4.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    StreamBuilder<bool>(
                      stream: _audioService.recorderIsRecording,
                      builder: (ctx, snapshot) {
                        final isRecording = snapshot.data ?? false;
                        final isRecordingInCurrentRoom =
                            _audioService.recordingRoom ==
                                widget.currentRoom.uid;

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
                                        onPressed: () =>
                                            _routingService.openRoom(
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
                                  replyToId: _replyMessageId,
                                ),
                              );
                              if (_replyMessageId > 0) {
                                widget.resetRoomPageDetails!();
                              }
                            }
                          },
                          roomUid: widget.currentRoom.uid.asUid(),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            if (hasVirtualKeyboardCapability)
              StreamBuilder<KeyboardStatus>(
                stream: _keyboardStatus,
                builder: (context, back) {
                  final riseKeyboard =
                      (back.data ?? KeyboardStatus.OFF) != KeyboardStatus.OFF;
                  final searchKeyboard = (back.data ?? KeyboardStatus.OFF) ==
                      KeyboardStatus.EMOJI_KEYBOARD_SEARCH;
                  Widget child = Container(
                    color: theme.colorScheme.onInverseSurface,
                  );

                  if (back.data == KeyboardStatus.EMOJI_KEYBOARD ||
                      back.data == KeyboardStatus.EMOJI_KEYBOARD_SEARCH) {
                    child = EmojiKeyboardWidget(
                      onEmojiDeleted: _onEmojiDeleted,
                      onSearchEmoji: (isSearchFocused) {
                        if (isSearchFocused) {
                          _keyboardStatus
                              .add(KeyboardStatus.EMOJI_KEYBOARD_SEARCH);
                        } else if (widget.focusNode.hasFocus) {
                          _keyboardStatus.add(KeyboardStatus.DEFAULT_KEYBOARD);
                        }
                      },
                      keyboardStatus: back.data!,
                      onTap: (emoji) {
                        _onEmojiSelected(emoji);
                      },
                    );
                  } else if (back.data == KeyboardStatus.REPLY_KEYBOARD) {
                    ReplyKeyboardMarkupWidget(
                      replyKeyboardMarkup: widget
                          .currentRoom.replyKeyboardMarkup!
                          .toReplyKeyboardMarkup(),
                      closeReplyKeyboard: () =>
                          _keyboardStatus.add(KeyboardStatus.OFF),
                      roomUid: widget.currentRoom.uid,
                      textController: widget.textController,
                    );
                  }

                  return AnimatedContainer(
                    duration: ANIMATION_DURATION,
                    curve: Curves.easeInOut,
                    height: riseKeyboard
                        ? searchKeyboard
                            ? getKeyboardSize() + 100
                            : getKeyboardSize()
                        : 0,
                    child: child,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _onEmojiSelected(String emoji) {
    if (widget.textController.text.isNotEmpty) {
      final start = widget.textController.selection.baseOffset;
      var block_1 = widget.textController.text.substring(0, start);
      block_1 = block_1.substring(0, start);
      final block_2 = widget.textController.text.substring(
        start,
        widget.textController.text.length,
      );
      widget.textController.text = block_1 + emoji + block_2;
      widget.textController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: widget.textController.text.length - block_2.length,
        ),
      );
    } else {
      widget.textController.text = widget.textController.text + emoji;
      widget.textController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: widget.textController.text.length,
        ),
      );
    }
  }

  double getKeyboardSize() {
    final mq = MediaQuery.of(context);
    if (mq.orientation == Orientation.landscape) {
      return _uxService.getKeyBoardSizeLandscape() ?? 200;
    } else {
      return _uxService.getKeyBoardSizePortrait() ?? 254;
    }
  }

  void setKeyBoardSize(double bottomOffset, MediaQueryData mq) {
    if (bottomOffset > 0) {
      if (mq.orientation == Orientation.portrait) {
        _uxService.setKeyBoardSizePortrait(bottomOffset);
      } else {
        _uxService.setKeyBoardSizeLandScape(bottomOffset);
      }
    }
  }

  Widget buildEmojiKeyboardActions() {
    return StreamBuilder<KeyboardStatus>(
      stream: _keyboardStatus,
      builder: (context, snapshot) {
        if (hasVirtualKeyboardCapability) {
          final emojiKeyboardIsOn = !((snapshot.data ?? KeyboardStatus.OFF) !=
                  KeyboardStatus.EMOJI_KEYBOARD &&
              (snapshot.data ?? KeyboardStatus.OFF) !=
                  KeyboardStatus.EMOJI_KEYBOARD_SEARCH);
          return IconButton(
            icon: Icon(
              emojiKeyboardIsOn
                  ? CupertinoIcons.keyboard_chevron_compact_down
                  : CupertinoIcons.smiley,
            ),
            onPressed: () {
              if (emojiKeyboardIsOn) {
                widget.focusNode.requestFocus();
                _keyboardStatus.add(KeyboardStatus.DEFAULT_KEYBOARD);
              } else {
                FocusScope.of(context).unfocus();
                _keyboardStatus.add(KeyboardStatus.EMOJI_KEYBOARD);
              }
            },
          );
        } else {
          return MouseRegion(
            onHover: (val) {
              _desktopEmojiKeyboardFocusNode.requestFocus();
            },
            onExit: (val) {
              _desktopEmojiKeyboardFocusNode.unfocus();
            },
            child: IconButton(
              focusNode: _desktopEmojiKeyboardFocusNode,
              onPressed: () {},
              hoverColor: Colors.transparent,
              icon: const Icon(
                CupertinoIcons.smiley,
              ),
            ),
          );
        }
      },
    );
  }

  void _hideDesktopEmojiKeyboardOverlay() {
    _desktopEmojiKeyboardOverlayEntry?.remove();
  }

  void _showDesktopEmojiKeyboardOverlay() {
    _desktopEmojiKeyboardOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 20,
          bottom: 40,
          child: MouseRegion(
            onHover: (val) {
              _desktopEmojiKeyboardFocusNode.requestFocus();
            },
            onExit: (val) {
              _desktopEmojiKeyboardFocusNode.unfocus();
            },
            child: SizedBox(
              width: DESKTOP_EMOJI_OVERLAY_WIDTH,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Material(
                color: Colors.white.withOpacity(0.0),
                child: EmojiKeyboardWidget(
                  onEmojiDeleted: _onEmojiDeleted,
                  onSkinToneOverlay: () {
                    _desktopEmojiKeyboardFocusNode.requestFocus();
                  },
                  onTap: (emoji) => _onEmojiSelected(emoji),
                  onSearchEmoji: (isSearchFocused) {
                    if (isSearchFocused) {
                      _desktopEmojiKeyboardFocusNode.requestFocus();
                      _keyboardStatus.add(KeyboardStatus.EMOJI_KEYBOARD_SEARCH);
                    }
                  },
                  keyboardStatus: KeyboardStatus.EMOJI_KEYBOARD_SEARCH,
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context)!.insert(_desktopEmojiKeyboardOverlayEntry!);
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
            if (!widget.waitingForForward &&
                widget.currentRoom.replyKeyboardMarkup != null)
              StreamBuilder<KeyboardStatus>(
                stream: _keyboardStatus,
                builder: (context, snapshot) {
                  final replyKeyboardIsOn =
                      !((snapshot.data ?? KeyboardStatus.OFF) !=
                          KeyboardStatus.REPLY_KEYBOARD);

                  return IconButton(
                    icon: Icon(
                      replyKeyboardIsOn
                          ? CupertinoIcons.chevron_down_square
                          : CupertinoIcons.square_grid_2x2,
                    ),
                    onPressed: () {
                      if (replyKeyboardIsOn) {
                        widget.focusNode.requestFocus();
                        if (hasVirtualKeyboardCapability) {
                          _keyboardStatus.add(KeyboardStatus.DEFAULT_KEYBOARD);
                        } else {
                          _keyboardStatus.add(KeyboardStatus.OFF);
                        }
                      } else {
                        if (hasVirtualKeyboardCapability) {
                          FocusScope.of(context).unfocus();
                        }
                        _keyboardStatus.add(KeyboardStatus.REPLY_KEYBOARD);
                      }
                    },
                  );
                },
              ),
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
            if ((isWindows) && !showSendButton && !widget.waitingForForward)
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
                  _keyboardStatus.add(KeyboardStatus.OFF);

                  _attachFile();
                },
              ),
            if (showSendButton || widget.waitingForForward)
              IconButton(
                icon: Icon(
                  CupertinoIcons.paperplane_fill,
                  color: theme.primaryColor,
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
            child: AutoDirectionTextField(
              textFieldKey: _inputTextKey,
              selectionControls: selectionControls,
              focusNode: widget.focusNode,
              autofocus: (snapshot.data?.id ?? 0) > 0 || isDesktop,
              controller: widget.textController,
              decoration: InputDecoration(
                isCollapsed: true,
                // TODO(bitbeter): باز باید بررسی بشه که چیه ماجرای این کد و به صورت کلی حل بشه و نه با شرط دسکتاپ بودن
                contentPadding:
                    EdgeInsets.only(top: 9, bottom: isDesktop ? 9 : 16),
                border: InputBorder.none,
                counterText: "",
                hintText: _hasMarkUpPlaceHolder()
                    ? widget.currentRoom.lastMessage!.markup!
                        .toMessageMarkup()
                        .inputFieldPlaceholder
                    : _i18n.get("write_a_message"),
                hintTextDirection: _hasMarkUpPlaceHolder()
                    ? _i18n.getDirection(
                        widget.currentRoom.lastMessage!.markup!
                            .toMessageMarkup()
                            .inputFieldPlaceholder,
                      )
                    : _i18n.defaultTextDirection,
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
              style: theme.textTheme.bodyMedium,
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

  void _updateTextEditingValue(TextEditingValue value) {
    if (_inputTextKey.currentState != null) {
      (_inputTextKey.currentState!
              as TextSelectionGestureDetectorBuilderDelegate)
          .editableTextKey
          .currentState
          ?.userUpdateTextEditingValue(value, SelectionChangedCause.keyboard);
    }
  }

  void _onEmojiDeleted() {
    if (widget.textController.selection.base.offset < 0) {
      return;
    }

    final selection = widget.textController.value.selection;
    final text = widget.textController.value.text;
    final newTextBeforeCursor =
        selection.textBefore(text).characters.skipLast(1).toString();
    _updateTextEditingValue(
      TextEditingValue(
        text: newTextBeforeCursor + selection.textAfter(text),
        selection: TextSelection.fromPosition(
          TextPosition(offset: newTextBeforeCursor.length),
        ),
      ),
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

    final text = widget.textController.text.trim();

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

  Future<void> _attachFileInDesktopMode() async {
    try {
      final res = <File>[];
      if (isLinux) {
        final result = await openFiles();
        for (final file in result) {
          res.add(await xFileToFileModel(file));
        }
      } else {
        final result = await FilePicker.platform.pickFiles(allowMultiple: true);

        res.addAll(
          (result?.files ?? []).map(filePickerPlatformFileToFileModel),
        );
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

  bool _hasMarkUpPlaceHolder() =>
      widget.currentRoom.lastMessage?.markup
          ?.toMessageMarkup()
          .hasInputFieldPlaceholder() ??
      false;
}
