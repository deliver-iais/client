import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/forward_preview.dart';
import 'package:deliver/screen/room/messageWidgets/on_edit_message_widget.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver/screen/room/messageWidgets/reply_widgets/reply_preview.dart';
import 'package:deliver/screen/room/pages/pin_message_app_bar.dart';
import 'package:deliver/screen/room/widgets/bot_start_widget.dart';
import 'package:deliver/screen/room/widgets/chat_time.dart';
import 'package:deliver/screen/room/widgets/input_message.dart';
import 'package:deliver/screen/room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver/screen/room/widgets/new_message_input.dart';
import 'package:deliver/screen/room/widgets/recieved_message_box.dart';
import 'package:deliver/screen/room/widgets/sended_message_box.dart';

import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/bot_appbar_title.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/drag_and_drop_widget.dart';
import 'package:deliver/shared/widgets/muc_appbar_title.dart';
import 'package:deliver/shared/widgets/user_appbar_title.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:vibration/vibration.dart';

// ignore: constant_identifier_names
const int PAGE_SIZE = 16;

class RoomPage extends StatefulWidget {
  final String roomId;
  final List<Message>? forwardedMessages;
  final List<String>? inputFilePath;
  final proto.ShareUid? shareUid;

  const RoomPage(
      {Key? key,
      required this.roomId,
      this.forwardedMessages,
      this.inputFilePath,
      this.shareUid})
      : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with CustomPopupMenu {
  final _logger = GetIt.I.get<Logger>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  String? _searchMessagePattern;
  int _lastSeenMessageId = -1;

  int _lastShowedMessageId = -1;
  int _itemCount = 0;
  int _replyMessageId = -1;
  int _lastReceivedMessageId = 0;
  int _currentMessageSearchId = -1;
  List<Message> searchResult = [];

  final List<Message> _pinMessages = [];
  final Map<int, Message> _selectedMessages = {};
  final _messageCache = LruCache<int, Message>(storage: InMemoryStorage(80));

  final _itemPositionsListener = ItemPositionsListener.create();
  final _itemScrollController = ItemScrollController();
  final _scrollPhysics = const ClampingScrollPhysics();

  final BehaviorSubject<Message?> _repliedMessage =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<Message?> _editableMessage =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<Room?> _currentRoom = BehaviorSubject.seeded(null);
  final _searchMode = BehaviorSubject.seeded(false);
  final _lastPinedMessage = BehaviorSubject.seeded(0);
  final _itemCountSubject = BehaviorSubject.seeded(0);
  final _waitingForForwardedMessage = BehaviorSubject.seeded(false);
  final _selectMultiMessageSubject = BehaviorSubject.seeded(false);
  final _positionSubject = BehaviorSubject.seeded(0);
  final _hasPermissionInChannel = BehaviorSubject.seeded(true);
  final _hasPermissionInGroup = BehaviorSubject.seeded(false);
  final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();

  @override
  Widget build(BuildContext context) {
    _currentRoom.add(Room(uid: widget.roomId, firstMessageId: 0));
    return DragDropWidget(
      roomUid: widget.roomId,
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: buildAppbar(),
        body: Stack(
          children: [
            StreamBuilder<Room?>(
                stream: _roomRepo.watchRoom(widget.roomId),
                builder: (context, snapshot) {
                  return Background(id: snapshot.data?.lastMessageId ?? 0);
                }),
            Column(
              children: <Widget>[
                AudioPlayerAppBar(),
                const Divider(),
                pinMessageWidget(),
                Expanded(
                  child: StreamBuilder<List<PendingMessage>>(
                      stream: _messageRepo.watchPendingMessages(widget.roomId),
                      builder: (context, pendingMessagesStream) {
                        List<PendingMessage> pendingMessages =
                            pendingMessagesStream.data ?? [];
                        return StreamBuilder<Room?>(
                            stream: _roomRepo.watchRoom(widget.roomId),
                            builder: (context, currentRoomStream) {
                              if (currentRoomStream.hasData) {
                                _currentRoom.add(currentRoomStream.data);
                                int i =
                                    (_currentRoom.value!.lastMessageId ?? 0) +
                                        pendingMessages.length;
                                _itemCountSubject.add(i);
                                _itemCount = i;
                                if (currentRoomStream.data!.firstMessageId !=
                                    null) {
                                  _itemCount = _itemCount -
                                      currentRoomStream.data!.firstMessageId!;
                                }

                                return PageStorage(
                                    bucket: PageStorage.of(context)!,
                                    key: PageStorageKey(widget.roomId),
                                    child: Stack(
                                      alignment:
                                          AlignmentDirectional.bottomStart,
                                      children: [
                                        buildMessagesListView(pendingMessages),
                                        StreamBuilder<int>(
                                            stream: _positionSubject.stream,
                                            builder: (c, position) {
                                              if (position.hasData &&
                                                  position.data != null &&
                                                  _itemCount -
                                                          (position.data!) >
                                                      4) {
                                                return scrollDownButtonWidget();
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            }),
                                      ],
                                    ));
                              } else {
                                return const SizedBox(
                                  height: 50,
                                );
                              }
                            });
                      }),
                ),
                StreamBuilder(
                    stream: _repliedMessage.stream,
                    builder: (c, rm) {
                      if (rm.hasData && rm.data != null) {
                        return ReplyPreview(
                            message: _repliedMessage.value!,
                            resetRoomPageDetails: _resetRoomPageDetails);
                      }
                      return Container();
                    }),
                StreamBuilder(
                    stream: _editableMessage.stream,
                    builder: (c, em) {
                      if (em.hasData && em.data != null) {
                        return OnEditMessageWidget(
                            message: _editableMessage.value!,
                            resetRoomPageDetails: _resetRoomPageDetails);
                      }
                      return Container();
                    }),
                StreamBuilder<bool>(
                    stream: _waitingForForwardedMessage.stream,
                    builder: (c, wm) {
                      if (wm.hasData && wm.data!) {
                        return ForwardPreview(
                          forwardedMessages: widget.forwardedMessages,
                          shareUid: widget.shareUid,
                          onClick: () {
                            _waitingForForwardedMessage.add(false);
                          },
                        );
                      } else {
                        return Container();
                      }
                    }),
                keyboardWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _logger.wtf(_authRepo.currentUserUid);
    _logger.wtf(widget.roomId);

    if (!isDesktop()) _fireBaseServices.sendFireBaseToken();
    _getLastShowMessageId();
    _getLastSeen();
    _itemPositionsListener.itemPositions.addListener(() {
      if (_itemPositionsListener.itemPositions.value.isNotEmpty) {
        _positionSubject.add(_itemPositionsListener.itemPositions.value
            .map((e) => e.index)
            .reduce(max));
      }
    });

    _itemCountSubject.distinct().listen((event) {
      if (event != 0) {
        if (_itemCount - (_positionSubject.value) < 4) {
          scrollToLast();
        }
      }
    });

    _roomRepo.resetMention(widget.roomId);
    if (isAndroid() || isIOS()) {
      _notificationServices.cancelRoomNotifications(widget.roomId);
    }
    _waitingForForwardedMessage.add(widget.forwardedMessages != null
        ? widget.forwardedMessages!.isNotEmpty
        : widget.shareUid != null);
    sendInputSharedFile();
    // TODO Channel is different from groups and private chats !!!

    _positionSubject
        .map((event) => event + 1 + (_currentRoom.value?.firstMessageId ?? 0))
        .where(
            (idx) => _lastReceivedMessageId < idx && idx > _lastShowedMessageId)
        .map((event) => _lastReceivedMessageId = event)
        .distinct()
        .debounceTime(const Duration(milliseconds: 100))
        .listen((event) async {
      var msg = await _getMessage(
          event, widget.roomId, _currentRoom.value!.lastMessageId!,
          lastUpdatedMessageId: _currentRoom.value!.lastUpdatedMessageId);

      if (msg == null) return;

      if (!_authRepo.isCurrentUser(msg.from)) {
        _messageRepo.sendSeen(event, widget.roomId.asUid());
      }

      _roomRepo.saveMySeen(Seen(uid: widget.roomId, messageId: event));
    });

    if (widget.roomId.asUid().category == Categories.CHANNEL ||
        widget.roomId.asUid().category == Categories.GROUP) {
      fetchMucInfo(widget.roomId.asUid());
    } else if (widget.roomId.asUid().category == Categories.BOT) {
      _botRepo.fetchBotInfo(widget.roomId.asUid());
    }
    if (widget.roomId.asUid().isMuc()) {
      watchPinMessages();
    }
    if (widget.roomId.asUid().isGroup()) {
      checkGroupRole();
    } else if (widget.roomId.asUid().isChannel()) {
      checkChannelRole();
    }

    super.initState();
  }

  Future<Message?> _getMessage(int id, String roomId, int lastMessageId,
      {int? lastUpdatedMessageId}) async {
    var msg = _messageCache.get(id);
    if (msg != null && id != lastUpdatedMessageId) {
      return msg;
    }
    int page = (id / PAGE_SIZE).floor();
    List<Message?> messages = await _messageRepo
        .getPage(page, roomId, id, lastMessageId, pageSize: PAGE_SIZE);
    for (int i = 0; i < messages.length; i = i + 1) {
      _messageCache.set(messages[i]!.id!, messages[i]!);
    }
    return _messageCache.get(id)!;
  }

  void _resetRoomPageDetails() {
    inputMessagePrifix.add("");
    _editableMessage.add(null);
    _repliedMessage.add(null);
    _waitingForForwardedMessage.add(false);
  }

  void _sendForwardMessage() async {
    if (widget.shareUid != null) {
      _messageRepo.sendShareUidMessage(widget.roomId.asUid(), widget.shareUid!);
    } else {
      await _messageRepo.sendForwardedMessage(
          widget.roomId.asUid(), widget.forwardedMessages!);
    }

    _waitingForForwardedMessage.add(false);
    _repliedMessage.add(null);
  }

  void _showCustomMenu(Message message, bool isPersistentEventMessage) {
    this.showMenu(context: context, items: <PopupMenuEntry<OperationOnMessage>>[
      OperationOnMessageEntry(
        message,
        hasPermissionInChannel: _hasPermissionInChannel.value,
        hasPermissionInGroup: _hasPermissionInGroup.value,
        isPinned: _pinMessages.contains(message),
        roomLastMessageId: _currentRoom.value!.lastMessageId!,
        onDelete: () {
          _selectMultiMessageSubject.add(false);
          _selectedMessages.clear();
        },
      )
    ]).then<void>((OperationOnMessage? opr) async {
      if (opr == null) return;
      switch (opr) {
        // ignore: missing_enum_constant_in_switch
        case OperationOnMessage.REPLY:
          onReply(message);
          break;
        case OperationOnMessage.EDIT:
          switch (message.type) {
            // ignore: missing_enum_constant_in_switch
            case MessageType.TEXT:
              inputMessagePrifix.add(message.json!.toText().text);
              _editableMessage.add(message);
              break;
            case MessageType.FILE:
              showCaptionDialog(
                  roomUid: widget.roomId.asUid(),
                  editableMessage: message,
                  files: [],
                  context: context);
              break;
            case MessageType.STICKER:
              // TODO: Handle this case.
              break;
            case MessageType.LOCATION:
              // TODO: Handle this case.
              break;
            case MessageType.LIVE_LOCATION:
              // TODO: Handle this case.
              break;
            case MessageType.POLL:
              // TODO: Handle this case.
              break;
            case MessageType.FORM:
              // TODO: Handle this case.
              break;
            case MessageType.PERSISTENT_EVENT:
              // TODO: Handle this case.
              break;
            case MessageType.NOT_SET:
              // TODO: Handle this case.
              break;
            case MessageType.BUTTONS:
              // TODO: Handle this case.
              break;
            case MessageType.SHARE_UID:
              // TODO: Handle this case.
              break;
            case MessageType.FORM_RESULT:
              // TODO: Handle this case.
              break;
            case MessageType.SHARE_PRIVATE_DATA_REQUEST:
              // TODO: Handle this case.
              break;
            case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
              // TODO: Handle this case.
              break;
            default:
              break;
          }
          break;
        case OperationOnMessage.SAVE_TO_GALLERY:
          var file = message.json!.toFile();
          _fileRepo.saveFileInDownloadDir(
              file.uuid, file.name, ExtStorage.DIRECTORY_PICTURES);
          break;
        case OperationOnMessage.SAVE_TO_MUSIC:
          var file = message.json!.toFile();
          _fileRepo.saveFileInDownloadDir(
              file.uuid, file.name, ExtStorage.DIRECTORY_MUSIC);
          break;
        case OperationOnMessage.RESEND:
          _messageRepo.resendMessage(message);
          break;
        case OperationOnMessage.DELETE_PENDING_MESSAGE:
          _messageRepo.deletePendingMessage(message.packetId);
          break;
        case OperationOnMessage.PIN_MESSAGE:
          var isPin = await _messageRepo.pinMessage(message);
          if (isPin) {
            _pinMessages.add(message);
            _lastPinedMessage.add(_pinMessages.last.id!);
          } else {
            ToastDisplay.showToast(
                toastText: _i18n.get("error_occurred"), tostContext: context);
          }
          break;
        case OperationOnMessage.UN_PIN_MESSAGE:
          var res = await _messageRepo.unpinMessage(message);
          if (res) {
            _pinMessages.remove(message);
            _lastPinedMessage
                .add(_pinMessages.isNotEmpty ? _pinMessages.last.id! : 0);
          }
          break;
        case OperationOnMessage.COPY:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.FORWARD:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.DELETE:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.SHARE:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.SAVE_TO_DOWNLOADS:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.SHOW_IN_FOLDER:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.REPORT:
          // TODO: Handle this case.
          break;
      }
    });
  }

  void onReply(Message message) {
    _repliedMessage.add(message);
    _waitingForForwardedMessage.add(false);
    if (InputMessage.inputMessageFocusNode != null) {
      FocusScope.of(context).requestFocus(InputMessage.inputMessageFocusNode);
    }
  }

  _getLastSeen() async {
    Seen? seen = await _roomRepo.getOthersSeen(widget.roomId);
    if (seen != null && seen.messageId != null) {
      _lastSeenMessageId = seen.messageId!;
    }
  }

  _getLastShowMessageId() async {
    var seen = await _roomRepo.getMySeen(widget.roomId);

    var room = await _roomRepo.getRoom(widget.roomId);

    if (seen != null && seen.messageId != null) {
      _lastShowedMessageId = seen.messageId!;
      if (room!.firstMessageId != null) {
        _lastShowedMessageId = _lastShowedMessageId - room.firstMessageId!;
      }
      if (_authRepo.isCurrentUser(room.lastMessage!.from)) {
        _lastShowedMessageId = -1;
      }
    }
  }

  final _fireBaseServices = GetIt.I.get<FireBaseServices>();

  Future<void> watchPinMessages() async {
    _mucRepo.watchMuc(widget.roomId).listen((muc) {
      if (muc != null && (muc.showPinMessage == null || muc.showPinMessage!)) {
        List<int>? pm = muc.pinMessagesIdList;
        _pinMessages.clear();
        if (pm != null && pm.isNotEmpty) {
          pm.reversed.toList().forEach((element) async {
            try {
              var m = await _getMessage(
                  element, widget.roomId, muc.lastMessageId!,
                  lastUpdatedMessageId:
                      _currentRoom.value!.lastUpdatedMessageId != null
                          ? _currentRoom.value!.lastUpdatedMessageId!
                          : 0);
              _pinMessages.add(m!);
              _pinMessages.sort((a, b) => a.time - b.time);
              _lastPinedMessage.add(_pinMessages.last.id!);
            } catch (e) {
              _logger.e(e);
              _logger.d(element);
            }
          });
        }
      }
    });
  }

  Future<void> checkChannelRole() async {
    var res = await _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(), widget.roomId);
    _hasPermissionInChannel.add(res);
  }

  Future<void> checkGroupRole() async {
    var res = await _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(), widget.roomId);
    _hasPermissionInGroup.add(res);
  }

  Future<void> fetchMucInfo(Uid uid) async {
    var muc = await _mucRepo.fetchMucInfo(widget.roomId.asUid());
    if (muc != null) {
      _roomRepo.updateRoomName(uid, muc.name!);
    }
  }

  Widget keyboardWidget() {
    _rawKeyboardService.openSearchBox = openRoomSearchBox;
    _rawKeyboardService.currentRoom = widget.roomId.asUid();
    return widget.roomId.asUid().category != Categories.CHANNEL
        ? buildNewMessageInput()
        : MuteAndUnMuteRoomWidget(
            roomId: widget.roomId,
            inputMessage: buildNewMessageInput(),
          );
  }

  Widget scrollDownButtonWidget() {
    return Positioned(
        right: 10,
        bottom: 10,
        child: Stack(
          children: [
            FloatingActionButton(
                backgroundColor: Colors.white,
                // mini: true,
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  _scrollToMessage(
                      id: _lastShowedMessageId > 0
                          ? _lastShowedMessageId
                          : _itemCount);
                  _lastShowedMessageId = -1;
                }),
            if (_currentRoom.value!.lastMessage != null &&
                !_authRepo.isCurrentUser(_currentRoom.value!.lastMessage!.from))
              Positioned(
                  top: 0,
                  left: 0,
                  // alignment: Alignment.topLeft,
                  child: UnreadMessageCounterWidget(
                      widget.roomId, _currentRoom.value!.lastMessageId!)),
          ],
        ));
  }

  Widget buildNewMessageInput() {
    if (widget.roomId.asUid().category == Categories.BOT) {
      return StreamBuilder<Room?>(
          stream: _currentRoom.stream,
          builder: (c, s) {
            if (s.hasData &&
                s.data != null &&
                s.data!.uid.asUid().category == Categories.BOT &&
                s.data!.lastMessageId == null) {
              return BotStartWidget(botUid: widget.roomId.asUid());
            } else {
              return NewMessageInput(
                currentRoomId: widget.roomId,
                replyMessageId: _repliedMessage.value?.id ?? 0,
                resetRoomPageDetails: _resetRoomPageDetails,
                waitingForForward: _waitingForForwardedMessage.value,
                sendForwardMessage: _sendForwardMessage,
                scrollToLastSentMessage: scrollToLast,
              );
            }
          });
    } else {
      return StreamBuilder(
          stream:
              MergeStream([_repliedMessage.stream, _editableMessage.stream]),
          builder: (c, data) {
            return NewMessageInput(
              currentRoomId: widget.roomId,
              replyMessageId: _repliedMessage.value != null
                  ? _repliedMessage.value!.id!
                  : 0,
              editableMessage: _editableMessage.value,
              resetRoomPageDetails: _resetRoomPageDetails,
              waitingForForward: _waitingForForwardedMessage.value,
              sendForwardMessage: _sendForwardMessage,
              scrollToLastSentMessage: scrollToLast,
            );
          });
    }
  }

  PreferredSize buildAppbar() {
    TextEditingController controller = TextEditingController();
    BehaviorSubject<bool> checkSearchResult = BehaviorSubject.seeded(false);
    return PreferredSize(
      preferredSize: const Size.fromHeight(54),
      child: AppBar(
        leading: GestureDetector(
          child: StreamBuilder<bool>(
              stream: _searchMode.stream,
              builder: (c, s) {
                if (s.hasData && s.data!) {
                  return IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        searchMessage(controller.text, checkSearchResult);
                      });
                } else {
                  return _routingService.backButtonLeading(
                    context,
                    back: () {
                      // _notificationServices.reset("\t");
                    },
                  );
                }
              }),
        ),
        titleSpacing: 0.0,
        title: StreamBuilder<bool>(
          stream: _searchMode.stream,
          builder: (c, s) {
            if (s.hasData && s.data!) {
              return Row(
                children: [
                  Flexible(
                    child: TextField(
                      minLines: 1,
                      controller: controller,
                      autofocus: true,
                      onTap: () {
                        checkSearchResult.add(false);
                      },
                      onChanged: (s) {
                        checkSearchResult.add(false);
                      },
                      style: TextStyle(color: ExtraTheme.of(context).textField),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (str) async {
                        searchMessage(str, checkSearchResult);
                      },
                      decoration: InputDecoration(
                          hintText: _i18n.get("search"),
                          suffix: StreamBuilder<bool>(
                            stream: checkSearchResult.stream,
                            builder: (c, s) {
                              if (s.hasData && s.data!) {
                                return Text(_i18n.get("not_found"));
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          fillColor: Colors.white),
                    ),
                  ),
                ],
              );
            } else {
              return StreamBuilder<bool>(
                stream: _selectMultiMessageSubject.stream,
                builder: (c, sm) {
                  if (sm.hasData && sm.data!) {
                    return _selectMultiMessageAppBar();
                  } else {
                    if (widget.roomId.isMuc()) {
                      return MucAppbarTitle(mucUid: widget.roomId);
                    } else if (widget.roomId.asUid().category ==
                        Categories.BOT) {
                      return BotAppbarTitle(botUid: widget.roomId.asUid());
                    } else {
                      return UserAppbarTitle(
                        userUid: widget.roomId.asUid(),
                      );
                    }
                  }
                },
              );
            }
          },
        ),
        bottom: const PreferredSize(
          child: Divider(),
          preferredSize: Size.fromHeight(1),
        ),
      ),
    );
  }

  Future searchMessage(String str, BehaviorSubject subject) async {
    if (str.isNotEmpty) {
      subject.add(false);
      _searchMessagePattern = str;
      Map<int, Message> rm = {};
      var res = await _messageRepo.searchMessage(str, widget.roomId);
      for (var element in res) {
        if (element.json!.toText().text.contains(str)) {
          rm[element.id!] = element;
        }
      }
      if (rm.values.isNotEmpty) {
        setState(() {
          searchResult = rm.values.toList();
        });

        //todo
        // currentSearchResultMessage = searchResult.last;
        // _scrollToMessage(id: -1, position: currentSearchResultMessage.id);
      } else {
        subject.add(true);
      }
    }
  }

  Widget buildMessagesListView(List<PendingMessage> pendingMessages) {
    return ScrollablePositionedList.separated(
      itemCount: _itemCount,
      initialScrollIndex: _itemCount > 0
          ? (_lastShowedMessageId != -1)
              ? _lastShowedMessageId
              : _itemCount
          : 0,
      initialAlignment: 0,
      physics: _scrollPhysics,
      reverse: false,
      addSemanticIndexes: false,
      minCacheExtent: 300,
      itemPositionsListener: _itemPositionsListener,
      itemScrollController: _itemScrollController,
      itemBuilder: (context, index) {
        if (index == -1) index = 0;
        if (_currentRoom.value!.firstMessageId != null) {
          index = index + _currentRoom.value!.firstMessageId!;
        }
        bool isPendingMessage = (_currentRoom.value == null ||
                (_currentRoom.value != null &&
                    _currentRoom.value!.lastMessageId == null))
            ? true
            : _itemCount > _currentRoom.value!.lastMessageId! &&
                _itemCount - index <= pendingMessages.length;

        return _buildMessage(
            isPendingMessage, pendingMessages, index, _currentRoom.value);
      },
      separatorBuilder: (context, index) {
        int firstIndex = index;

        if (_currentRoom.value!.firstMessageId != null) {
          index = index + _currentRoom.value!.firstMessageId!;
        }
        if (_currentRoom.value!.firstMessageId != null &&
            index < _currentRoom.value!.firstMessageId!) return Container();
        return Column(
          children: [
            if (_currentRoom.value!.lastMessageId != null &&
                _lastShowedMessageId != -1 &&
                _lastShowedMessageId == firstIndex + 1)
              FutureBuilder<Message?>(
                  future: _messageAt(pendingMessages, index + 1),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        _authRepo.isCurrentUser(snapshot.data!.from)) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      color: Theme.of(context).backgroundColor,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_down,
                              color: Theme.of(context).primaryColor),
                          Text(
                            _i18n.get("unread_messages"),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    );
                  }),
            FutureBuilder<int?>(
              future: _timeAt(pendingMessages, index)!,
              builder: (context, snapshot) =>
                  snapshot.hasData && snapshot.data != null
                      ? ChatTime(currentMessageTime: date(snapshot.data!))
                      : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Future<Message?> _messageAt(List<PendingMessage> pendingMessages, int index) {
    bool isPendingMessage = (_currentRoom.value != null &&
            _currentRoom.value!.lastMessageId == null) ||
        _itemCount > _currentRoom.value!.lastMessageId! &&
            _itemCount - index <= pendingMessages.length;
    return isPendingMessage
        ? Future.value(pendingMessages[_itemCount - index - 1].msg)
        : _getMessage(
            index + 1, widget.roomId, _currentRoom.value!.lastMessageId!,
            lastUpdatedMessageId: _currentRoom.value!.lastUpdatedMessageId);
  }

  Future<int?>? _timeAt(List<PendingMessage> pendingMessages, int index) async {
    if (index < 0) return null;

    final msg = await _messageAt(pendingMessages, index + 1);

    if (index > 0) {
      final prevMsg = await _messageAt(pendingMessages, index);
      if (prevMsg!.json!.isDeletedMessage() || msg!.json!.isDeletedMessage()) {
        return null;
      }

      final d1 = date(prevMsg.time);
      final d2 = date(msg.time);
      if (d1.day != d2.day || d1.month != d2.month || d1.year != d2.year) {
        return msg.time;
      }
    }

    return null;
  }

  _buildMessage(bool isPendingMessage, List<PendingMessage> pendingMessages,
      int index, Room? currentRoom) {
    if (currentRoom!.firstMessageId != null &&
        index < currentRoom.firstMessageId!) {
      return Container(
        height: 20,
      );
    }

    return FutureBuilder<Message?>(
      future: _messageAt(pendingMessages, index),
      builder: (context, ms) {
        if (ms.hasData && ms.data != null) {
          if (index - _currentMessageSearchId > 49) {
            _currentMessageSearchId = -1;
          }

          if (!(ms.data!.from.isSameEntity(_authRepo.currentUserUid))) {}

          if (index == 0) {
            return Column(
              children: [
                ChatTime(currentMessageTime: date(ms.data!.time)),
                _buildMessageBox(
                    ms.data!, context, currentRoom, pendingMessages)
              ],
            );
          } else {
            return _buildMessageBox(
                ms.data!, context, currentRoom, pendingMessages);
          }
        } else if (_currentMessageSearchId == -1) {
          _currentMessageSearchId = index;
          return const SizedBox(width: 50, height: 50, child: Text(""));
        } else {
          return const SizedBox(width: 50, height: 50, child: Text(""));
        }
      },
    );
  }

  Widget _buildMessageBox(Message msg, BuildContext context, Room? currentRoom,
      List<PendingMessage> pendingMessages) {
    return msg.type != MessageType.PERSISTENT_EVENT
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: _selectedMessages.containsKey(msg.id) ||
                    (msg.id != null && msg.id == _replyMessageId)
                ? Theme.of(context).disabledColor
                : Colors.transparent,
            child: _createWidget(msg, currentRoom, pendingMessages),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: msg.json == "{}" ? 0.0 : 4.0),
                child: PersistentEventMessage(
                  message: msg,
                  maxWidth: maxWidthOfMessage(context),
                  onPinMessageClick: (int id) {
                    setState(() {
                      _replyMessageId = id;
                    });
                    _itemScrollController.scrollTo(
                        alignment: .5,
                        curve: Curves.easeOut,
                        opacityAnimationWeights: [20, 20, 60],
                        index: id,
                        duration: const Duration(milliseconds: 1000));
                    Timer(const Duration(seconds: 1), () {
                      setState(() {
                        _replyMessageId = -1;
                      });
                    });
                  },
                ),
              ),
            ],
          );
  }

  Widget _createWidget(
      Message message, Room? currentRoom, List pendingMessages) {
    if (message.json == "{}") return const SizedBox.shrink();
    Widget messageWidget;
    if (_authRepo.isCurrentUser(message.from)) {
      messageWidget = showSentMessage(message);
    } else {
      messageWidget = showReceivedMessage(message);
    }
    var dismissibleWidget = SwipeTo(
        onLeftSwipe: () async {
          _repliedMessage.add(message);
          Vibration.vibrate(duration: 150);
          //return false;
        },
        child: Container(
            width: double.infinity,
            color: Colors.transparent,
            child: messageWidget));

    return GestureDetector(
        onTap: () {
          if (_selectMultiMessageSubject.stream.value) {
            _addForwardMessage(message);
          } else if (!isDesktop()) {
            FocusScope.of(context).unfocus();
            _showCustomMenu(message, false);
          }
        },
        onSecondaryTap: !isDesktop()
            ? null
            : () {
                if (!_selectMultiMessageSubject.stream.value) {
                  _showCustomMenu(message, false);
                }
              },
        onDoubleTap: !isDesktop() ? null : () => onReply(message),
        onLongPress: () {
          if (!_selectMultiMessageSubject.stream.value) {
            _selectMultiMessageSubject.add(true);
          }
          _addForwardMessage(message);
        },
        onTapDown: storePosition,
        onSecondaryTapDown: storePosition,
        child: isDesktop()
            ? messageWidget
            : !widget.roomId.asUid().isChannel()
                ? dismissibleWidget
                : StreamBuilder<bool>(
                    stream: _hasPermissionInChannel.stream,
                    builder: (c, hp) {
                      if (hp.hasData && hp.data!) {
                        return dismissibleWidget;
                      } else {
                        return messageWidget;
                      }
                    },
                  ));
  }

  _addForwardMessage(Message message) {
    _selectedMessages.containsKey(message.id)
        ? _selectedMessages.remove(message.id)
        : _selectedMessages[message.id!] = message;
    if (_selectedMessages.values.isEmpty) {
      _selectMultiMessageSubject.add(false);
    }
    setState(() {});
  }

  sendInputSharedFile() async {
    if (widget.inputFilePath != null) {
      for (String path in widget.inputFilePath!) {
        _messageRepo.sendFileMessage(
            widget.roomId.asUid(), File(path, path.split(".").last));
      }
    }
  }

  _scrollToMessage({required int id}) {
    _itemScrollController.scrollTo(
      index: id,
      duration: const Duration(microseconds: 1),
      alignment: .5,
      curve: Curves.easeOut,
      opacityAnimationWeights: [20, 20, 60],
    );
    if (id != -1) {
      setState(() {
        _replyMessageId = id;
      });
    }
    if (_replyMessageId != -1) {
      Timer(const Duration(seconds: 3), () {
        setState(() {
          _replyMessageId = -1;
        });
      });
    }
  }

  Widget _selectMultiMessageAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: _i18n.get("cancel"),
          child: Badge(
            animationType: BadgeAnimationType.fade,
            badgeColor: Theme.of(context).primaryColor,
            badgeContent: Text(_selectedMessages.length.toString()),
            animationDuration: const Duration(milliseconds: 125),
            child: IconButton(
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _selectMultiMessageSubject.add(false);
                  _selectedMessages.clear();
                }),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: _i18n.get("forward"),
          child: Badge(
            animationType: BadgeAnimationType.fade,
            badgeColor: Theme.of(context).primaryColor,
            badgeContent: Text(_selectedMessages.length.toString()),
            animationDuration: const Duration(milliseconds: 125),
            child: IconButton(
                color: Theme.of(context).primaryColor,
                icon: const Icon(
                  Icons.arrow_forward,
                  size: 30,
                ),
                onPressed: () {
                  _routingService.openSelectForwardMessage(context,
                      forwardedMessages: _selectedMessages.values.toList());
                  _selectedMessages.clear();
                }),
          ),
        ),
        Tooltip(
          message: _i18n.get("delete"),
          child: Badge(
            animationType: BadgeAnimationType.fade,
            badgeColor: Theme.of(context).primaryColor,
            badgeContent: Text(_selectedMessages.length.toString()),
            animationDuration: const Duration(milliseconds: 125),
            child: IconButton(
                color: Theme.of(context).primaryColor,
                icon: const Icon(
                  Icons.delete,
                  size: 30,
                ),
                onPressed: () {
                  showDeleteMsgDialog(
                      _selectedMessages.values.toList(), context, () {
                    _selectMultiMessageSubject.add(false);
                    _selectedMessages.clear();
                  }, _currentRoom.value!.lastMessageId);
                  _selectedMessages.clear();
                }),
          ),
        )
      ],
    );
  }

  onBotCommandClick(String command) {
    _messageRepo.sendTextMessage(widget.roomId.asUid(), command);
  }

  Widget showSentMessage(Message message) {
    var messageWidget = SentMessageBox(
      message: message,
      isSeen: message.id != null && message.id! <= _lastSeenMessageId,
      pattern: _searchMessagePattern,
      scrollToMessage: (int id) {
        _scrollToMessage(id: id);
      },
      omUsernameClick: onUsernameClick,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[messageWidget],
    );
  }

  Widget showReceivedMessage(Message message) {
    var messageWidget = ReceivedMessageBox(
      message: message,
      pattern: _searchMessagePattern,
      onBotCommandClick: onBotCommandClick,
      scrollToMessage: (int id) => _scrollToMessage(id: id),
      onUsernameClick: onUsernameClick,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.roomId.asUid().category == Categories.GROUP)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                child: CircleAvatarWidget(message.from.asUid(), 18),
              ),
              onTap: () {
                _routingService.openRoom(message.from, context: context);
              },
            ),
          ),
        messageWidget
      ],
    );
  }

  scrollToLast() {
    _itemScrollController.scrollTo(
        alignment: 0,
        curve: Curves.easeOut,
        opacityAnimationWeights: [20, 20, 60],
        index: _itemCount - 1,
        duration: const Duration(milliseconds: 1000));
  }

  onUsernameClick(String username) async {
    if (username.contains("_bot")) {
      String roomId = "4:${username.substring(1)}";
      _routingService.openRoom(roomId, context: context);
    } else {
      String roomId = await _roomRepo.getUidById(username);
      _routingService.openRoom(roomId, context: context);
    }
  }

  Widget pinMessageWidget() {
    return PinMessageAppBar(
        lastPinedMessage: _lastPinedMessage,
        pinMessages: _pinMessages,
        onTap: () {
          setState(() => _replyMessageId = _lastPinedMessage.value);
          _itemScrollController.scrollTo(
              index: _lastPinedMessage.value,
              alignment: 0.5,
              duration: const Duration(microseconds: 1));
          if (_pinMessages.length > 1) {
            _lastPinedMessage.add(_pinMessages[max(
                    _pinMessages.indexWhere(
                            (e) => e.id == _lastPinedMessage.value) -
                        1,
                    0)]
                .id!);
          }
        },
        onCancel: () {
          _lastPinedMessage.add(0);
          _mucRepo.updateMuc(Muc(uid: widget.roomId)
              .copyWith(uid: widget.roomId, showPinMessage: false));
        });
  }

  openRoomSearchBox() {
    _searchMode.add(true);
  }
}
