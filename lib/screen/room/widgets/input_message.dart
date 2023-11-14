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
import 'package:deliver/screen/room/messageWidgets/custom_context_menu/custom_context_menue.dart';
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
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
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
  final Function(
    int dir, {
    required bool ctrlIsPressed,
    required bool hasPermission,
  }) handleScrollToMessage;
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
  final BehaviorSubject<double?> _keyboardBottomOffsetStream =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<String> _botCommandQuery = BehaviorSubject.seeded("-");
  TextEditingController captionTextController = TextEditingController();
  bool isMentionSelected = false;
  late FocusNode keyboardRawFocusNode;
  Subject<ActivityType> isTypingActivitySubject = BehaviorSubject();
  Subject<ActivityType> noActivitySubject = BehaviorSubject();
  final keyboardVisibilityController = KeyboardVisibilityController();
  StreamSubscription<bool>? _keyboardVisibilityControllerStream;
  late String _botCommandData;
  final BehaviorSubject<int> _mentionSelectedIndex = BehaviorSubject.seeded(0);
  final BehaviorSubject<int> _botCommandSelectedIndex =
      BehaviorSubject.seeded(0);
  final _inputTextKey = GlobalKey();

  final botCommandRegexp = RegExp(r"(\w)*");
  final idRegexp = RegExp(r"^[a-zA-Z](\w){0,19}$");
  OverlayEntry? _desktopEmojiKeyboardOverlayEntry;
  final _desktopEmojiKeyboardFocusNode = FocusNode();

  bool get _isRecordingInCurrentRoom =>
      _audioService.recordingRoom.isSameEntity(widget.currentRoom.uid);

  void _attachFile() {
    if (isDesktopNativeOrWeb) {
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
            currentRoomUid: currentRoom.uid,
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
    if (isDesktopDevice) {
      widget.focusNode.onKey = (node, evt) {
        return handleKeyPress(evt);
      };
    }
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
    } else {
      _keyboardVisibilityControllerStream =
          keyboardVisibilityController.onChange.listen((visible) {
        setKeyBoardSizeInMemoryIfNeeded(context);
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
    widget.textController.text = currentRoom.draft;
    isTypingActivitySubject
        .throttle((_) => TimerStream(true, const Duration(seconds: 10)))
        .listen((activityType) {
      _messageRepo.sendActivity(widget.currentRoom.uid, activityType);
    });
    noActivitySubject.listen((event) {
      _messageRepo.sendActivity(widget.currentRoom.uid, event);
    });
    _audioService.recordingDuration.listen((value) {
      if (value.compareTo(Duration.zero) > 0 &&
          _audioService.recordingRoom.isSameEntity(widget.currentRoom.uid)) {
        isTypingActivitySubject.add(ActivityType.RECORDING_VOICE);
      }
    });

    _showSendIcon.add(currentRoom.draft.isNotEmpty);
    widget.textController.addListener(() {
      _showSendIcon.add(widget.textController.text.isNotEmpty);
      if (currentRoom.uid.category == Categories.BOT &&
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

      if (currentRoom.uid.category == Categories.GROUP &&
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
    super.initState();
  }

  @override
  void dispose() {
    _keyboardVisibilityControllerStream?.cancel();
    if (widget.editableMessage == null) {
      _roomRepo.updateRoomDraft(currentRoom.uid, widget.textController.text);
    }
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
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: WillPopScope(
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
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StreamBuilder<String?>(
                stream: _mentionQuery.distinct(),
                builder: (c, showMention) {
                  if (showMention.hasData && showMention.data != null) {
                    return ShowMentionList(
                      query: showMention.data!,
                      onIdClick: onMentionSelected,
                      onNameClick: ({required name, required node}) =>
                          onMentionSelected(
                        _markDownName(name: name, node: node),
                      ),
                      roomUid: widget.currentRoom.uid,
                      mentionSelectedIndex: _mentionSelectedIndex,
                    );
                  }
                  _mentionSelectedIndex.add(0);
                  return const SizedBox.shrink();
                },
              ),
              StreamBuilder<String>(
                stream: _botCommandQuery.distinct(),
                builder: (c, show) {
                  _botCommandData = show.data ?? "-";
                  if (_botCommandData == "-") {
                    _botCommandSelectedIndex.add(0);
                  }
                  return BotCommands(
                    botUid: widget.currentRoom.uid,
                    query: _botCommandData,
                    onCommandClick: (command) {
                      onCommandSelected(command);
                    },
                    botCommandSelectedIndex: _botCommandSelectedIndex,
                  );
                },
              ),
              InputSuggestionsWidget(
                inputSuggestions: _lsatMessageHasMarkUp()
                    ? widget.currentRoom.lastMessage!.markup!
                        .toMessageMarkup()
                        .inputSuggestions
                    : [],
                textController: widget.textController,
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.dividerColor.withOpacity(0.7),
                      blurRadius: 2.0,
                      offset: const Offset(0.0, 0.75),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      StreamBuilder<bool>(
                        stream: _audioService.recorderIsRecording,
                        builder: (ctx, snapshot) {
                          final isRecording = snapshot.data ?? false;
                          return Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                if (!isRecording) buildEmojiKeyboardActions(),
                                if (!isRecording) buildTextInput(theme),
                                if (!isRecording) buildDefaultActions(),
                                if (isRecording && _isRecordingInCurrentRoom)
                                  const RecordAudioSlideWidget(),
                                if (isRecording && !_isRecordingInCurrentRoom)
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
                      // TODO(bitbeter): Recorder(library) need change for web from returning blob to return Uri
                      if (!isWeb)
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
                                      widget.currentRoom.uid,
                                      File(
                                        res,
                                        res,
                                        isVoice: true,
                                      ),
                                      replyToId: _replyMessageId,
                                    ),
                                  );
                                  if (_replyMessageId > 0) {
                                    widget.resetRoomPageDetails!();
                                  }
                                }
                              },
                              roomUid: widget.currentRoom.uid,
                            );
                          },
                        )
                    ],
                  ),
                ),
              ),
              if (hasVirtualKeyboardCapability ||
                  widget.currentRoom.replyKeyboardMarkup != null)
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
                        onSearchEmoji: ({required hasFocus}) {
                          if (hasFocus) {
                            _keyboardStatus
                                .add(KeyboardStatus.EMOJI_KEYBOARD_SEARCH);
                          } else if (widget.focusNode.hasFocus) {
                            _keyboardStatus
                                .add(KeyboardStatus.DEFAULT_KEYBOARD);
                          }
                        },
                        keyboardStatus: back.data!,
                        onTap: (emoji) {
                          _onEmojiSelected(emoji);
                        },
                      );
                    } else if (back.data == KeyboardStatus.REPLY_KEYBOARD) {
                      return ReplyKeyboardMarkupWidget(
                        replyKeyboardMarkup: widget
                            .currentRoom.replyKeyboardMarkup!
                            .toReplyKeyboardMarkup(),
                        closeReplyKeyboard: () =>
                            _keyboardStatus.add(KeyboardStatus.OFF),
                        roomUid: widget.currentRoom.uid.asString(),
                        textController: widget.textController,
                      );
                    }

                    return StreamBuilder<double?>(
                      stream: _keyboardBottomOffsetStream.stream
                          .distinct()
                          .debounceTime(AnimationSettings.actualNormal),
                      builder: (context, snapshot) {
                        return AnimatedContainer(
                          duration: AnimationSettings.normal,
                          curve: Curves.easeInOut,
                          height: riseKeyboard
                              ? searchKeyboard
                                  ? getKeyboardSize(snapshot.data) + 100
                                  : getKeyboardSize(snapshot.data)
                              : 0,
                          child: child,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onEmojiSelected(String emoji) {
    if (widget.textController.text.isNotEmpty) {
      final start = widget.textController.selection.baseOffset;
      final block_1 = widget.textController.text.substring(0, start);
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

  double getKeyboardSize(double? size) {
    final keyBoardSizeFromShredDao = getKeyboardSizeFromSharedDao(context);
    if (keyBoardSizeFromShredDao != 0) {
      return keyBoardSizeFromShredDao;
    }
    final mq = MediaQuery.of(context);
    if (_keyboardStatus.value == KeyboardStatus.DEFAULT_KEYBOARD) {
      final bottomOffset = mq.viewInsets.bottom + mq.padding.bottom;
      if (bottomOffset != 0 &&
          _keyboardBottomOffsetStream.value != bottomOffset) {
        _keyboardBottomOffsetStream.add(bottomOffset);
      }
      if (size != null) {
        return size;
      } else if (bottomOffset != 0) {
        return bottomOffset;
      }
    }
    final keyboardSizeFromMemory = getKeyboardSizeFromMemory(context);
    if (keyboardSizeFromMemory == 0) {
      if (mq.orientation == Orientation.landscape) {
        return KEYBOARD_DEFAULT_SIZE_LANDSCAPE;
      } else {
        return KEYBOARD_DEFAULT_SIZE_PORTRAIT;
      }
    }
    return keyboardSizeFromMemory;
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
    widget.focusNode.requestFocus();
  }

  void _showDesktopEmojiKeyboardOverlay() {
    _desktopEmojiKeyboardOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: p12,
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
                  onSearchEmoji: ({required hasFocus}) {
                    if (hasFocus) {
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
    Overlay.of(context).insert(_desktopEmojiKeyboardOverlayEntry!);
  }

  StreamBuilder<bool> buildDefaultActions() {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      stream: _showSendIcon,
      builder: (context, snapshot) {
        final showSendButton =
            (snapshot.data ?? false) || widget.waitingForForward;

        final showCommandsButton =
            !showSendButton && currentRoom.uid.category == Categories.BOT;

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
            if ((isWindowsNative) &&
                !showSendButton &&
                !widget.waitingForForward)
              IconButton(
                icon: Icon(
                  isMacOSDevice
                      ? CupertinoIcons.location
                      : Icons.location_on_outlined,
                ),
                onPressed: () => AttachLocation(
                  context,
                  currentRoom.uid,
                ).attachLocationInWindows(),
              ),
            if (!showSendButton &&
                !widget.waitingForForward &&
                !(settings.localNetworkMessenger.value &&
                    widget.currentRoom.uid.isMuc()))
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
                  color: theme.colorScheme.primary,
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
              needEndingSpace: true,
              textFieldKey: _inputTextKey,
              contextMenuBuilder: (context, editableTextState) {
                return CustomContextMenu(
                  editableTextState: editableTextState,
                  buildContext: context,
                  textController: widget.textController,
                  roomUid: currentRoom.uid,
                ).getCustomTextSelectionController();
              },
              focusNode: widget.focusNode,
              autofocus: (snapshot.data?.id ?? 0) > 0 || isDesktopDevice,
              controller: widget.textController,
              decoration: InputDecoration(
                isCollapsed: true,
                // TODO(bitbeter): باز باید بررسی بشه که چیه ماجرای این کد و به صورت کلی حل بشه و نه با شرط دسکتاپ بودن
                contentPadding: EdgeInsetsDirectional.only(
                  top: 9,
                  bottom: isDesktopNativeOrWeb ? 9 : 16,
                ),
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
                hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.4)),
              ),
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: isMobileNative ? 10 : 15,
              maxLength: INPUT_MESSAGE_TEXT_FIELD_MAX_LENGTH,
              inputFormatters: [
                MaxLinesTextInputFormatter(
                  INPUT_MESSAGE_TEXT_FIELD_MAX_LINE,
                )
                //max line of text field
              ],
              style: theme.textTheme.bodyMedium,
              onChanged: (str) {
                setKeyBoardSizeInSharedDaoStorageIfNeeded(context);
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

  void onMentionSelected(String mention) {
    final start = widget.textController.selection.baseOffset;
    var block_1 = widget.textController.text.substring(0, start);
    final indexOf = block_1.lastIndexOf("@");
    block_1 = block_1.substring(0, indexOf);
    final block_2 = widget.textController.text
        .substring(start, widget.textController.text.length);
    widget.textController.text = "$block_1$mention $block_2";
    widget.textController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: widget.textController.text.length - block_2.length,
      ),
    );
    _mentionQuery.add(null);
    isMentionSelected = true;
    if (isDesktopDevice) {
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
    if (((!settings.sendByEnter.value && event.isShiftPressed) ||
            (settings.sendByEnter.value && !event.isShiftPressed)) &&
        isEnterClicked(event)) {
      if (widget.currentRoom.uid.isGroup() &&
          _mentionSelectedIndex.value >= 0 &&
          _mentionQuery.value != null) {
        addMentionByEnter();
      } else if (widget.currentRoom.uid.isBot() &&
          _botCommandSelectedIndex.value >= 0 &&
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
      currentRoom.uid,
    );
    if (widget.currentRoom.uid.isGroup()) {
      return _rawKeyboardService.navigateInMentions(
        _mentionQuery.value,
        scrollDownInMentions,
        event,
        scrollUpInMentions,
      );
    }
    if (widget.currentRoom.uid.isBot()) {
      return _rawKeyboardService.navigateInBotCommand(
        event,
        _scrollDownInBotCommand,
        _scrollUpInBotCommand,
        _botCommandData,
      );
    }

    return KeyEventResult.ignored;
  }

  Future<void> _handleCV(RawKeyEvent event) async {
    unawaited(
      _rawKeyboardService.controlVHandle(
        widget.textController,
        context,
        widget.currentRoom.uid,
      ),
    );
  }

  KeyEventResult _handleArrow(RawKeyEvent event) {
    if (event.physicalKey == PhysicalKeyboardKey.arrowUp &&
        widget.textController.selection.baseOffset <= 0) {
      widget.handleScrollToMessage(
        -1,
        ctrlIsPressed: event.isControlPressed,
        hasPermission: true,
      );
    } else if (event.physicalKey == PhysicalKeyboardKey.arrowDown &&
        (widget.textController.selection.baseOffset ==
                widget.textController.text.length ||
            widget.textController.selection.baseOffset < 0)) {
      widget.handleScrollToMessage(
        1,
        ctrlIsPressed: event.isControlPressed,
        hasPermission: true,
      );
    }
    return KeyEventResult.handled;
  }

  Future<void> addBotCommandByEnter() async {
    final value = await _botRepo.getBotInfo(widget.currentRoom.uid);
    if (value != null && value.commands!.isNotEmpty) {
      onCommandSelected(
        value.commands!.keys
            .where((element) => element.contains(_botCommandData))
            .toList()[_botCommandSelectedIndex.value],
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
      final indexedMember = value[_mentionSelectedIndex.value];
      if (indexedMember.username.isNotEmpty) {
        onMentionSelected("@${indexedMember.username}");
      } else if (indexedMember.realName.isNotEmpty) {
        onMentionSelected(
          _markDownName(
            name: indexedMember.realName,
            node: indexedMember.memberUid.node,
          ),
        );
      }
    } else {
      sendMessage();
    }
  }

  String _markDownName({required String name, required String node}) =>
      "[@$name](we://user?id=$node)";

  void _scrollDownInBotCommand() =>
      _botCommandSelectedIndex.add(_botCommandSelectedIndex.value + 1);

  void _scrollUpInBotCommand() {
    _botCommandSelectedIndex.add(max(0, _botCommandSelectedIndex.value - 1));
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

  void sendMessage() {
    if (widget.textController.text.contains("\n") &&
        widget.textController.text.contains("@") &&
        isMentionSelected) {
      isMentionSelected = false;
    }
    if (widget.waitingForForward) {
      widget.sendForwardMessage?.call();
      widget.resetRoomPageDetails!();
    }

    final text = widget.textController.text.trim();

    if (text.isNotEmpty) {
      if (_replyMessageId > 0) {
        _messageRepo.sendTextMessage(
          currentRoom.uid,
          text,
          replyId: _replyMessageId,
        );
        widget.resetRoomPageDetails!();
      } else {
        if (widget.editableMessage != null) {
          _messageRepo.editTextMessage(
            currentRoom.uid,
            widget.editableMessage!,
            text,
          );
        } else {
          _messageRepo.sendTextMessage(currentRoom.uid, text);
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
      if (isLinuxNative) {
        final result = await openFiles();
        for (final file in result) {
          res.add(await xFileToFileModel(file));
        }
      } else {
        final result = await FilePicker.platform
            .pickFiles(allowMultiple: true, lockParentWindow: true);

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
    if (files.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return ShowCaptionDialog(
          resetRoomPageDetails: widget.resetRoomPageDetails,
          replyMessageId: _replyMessageId,
          files: files,
          currentRoom: currentRoom.uid,
        );
      },
    );
  }

  void scrollDownInMentions() =>
      _mentionSelectedIndex.add(_mentionSelectedIndex.value + 1);

  void scrollUpInMentions() {
    _mentionSelectedIndex.add(max(0, _mentionSelectedIndex.value - 1));
  }

  String getEditableMessageContent() {
    var text = "";
    switch (widget.editableMessage!.type) {
      case MessageType.TEXT:
        text = widget.editableMessage!.json.toText().text;
        break;
      case MessageType.FILE:
        text = widget.editableMessage!.json.toFile().caption;
        break;
      case MessageType.STICKER:
      case MessageType.LOCATION:
      case MessageType.LIVE_LOCATION:
      case MessageType.POLL:
      case MessageType.FORM:
      case MessageType.PERSISTENT_EVENT:
      case MessageType.NOT_SET:
      case MessageType.BUTTONS:
      case MessageType.SHARE_UID:
      case MessageType.FORM_RESULT:
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
      case MessageType.CALL:
      case MessageType.CALL_LOG:
      case MessageType.TABLE:
      case MessageType.TRANSACTION:
      case MessageType.PAYMENT_INFORMATION:
    }
    return "$text ";
  }

  void moveCursorToEnd() {
    widget.textController.selection = TextSelection.collapsed(
      offset: widget.textController.text.length,
    );
  }

  bool _lsatMessageHasMarkUp() =>
      widget.currentRoom.lastMessage != null &&
      widget.currentRoom.lastMessage!.markup != null &&
      widget.currentRoom.lastMessage!.markup!.isNotEmpty;

  bool _hasMarkUpPlaceHolder() =>
      _lsatMessageHasMarkUp() &&
      (widget.currentRoom.lastMessage?.markup
              ?.toMessageMarkup()
              .hasInputFieldPlaceholder() ??
          false);
}
