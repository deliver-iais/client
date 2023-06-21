import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/search_message_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchMessagesScreen extends StatefulWidget {
  final void Function(String)? onChange;
  final void Function()? onTap;
  final void Function()? onCancel;
  final double? animationValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Uid uid;

  const SearchMessagesScreen({
    super.key,
    this.onChange,
    this.onCancel,
    this.controller,
    this.onTap,
    this.animationValue,
    this.focusNode,
    required this.uid,
  });

  @override
  SearchMessagesScreenState createState() => SearchMessagesScreenState();
}

class SearchMessagesScreenState extends State<SearchMessagesScreen> {
  late SearchMessageService searchMessageService;
  final TextEditingController _localController = TextEditingController();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  final BehaviorSubject<bool?> _hasText = BehaviorSubject.seeded(null);
  final BehaviorSubject<String?> _text = BehaviorSubject.seeded(null);
  final _localFocusNode = FocusNode(canRequestFocus: false);
  final _keyboardVisibilityController = KeyboardVisibilityController();
  final StreamController<int> _streamController = StreamController<int>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _searchMessageService = GetIt.I.get<SearchMessageService>();
  static final _i18n = GetIt.I.get<I18N>();

  void _clearTextEditingController() {
    widget.controller?.clear();
    _localController.clear();
  }

  @override
  void dispose() {
    _localController.dispose();
    _streamController.close();
    super.dispose();
  }

  FocusNode _getFocusNode() {
    return widget.focusNode ?? _localFocusNode;
  }

  @override
  void initState() {
    // searchMessageService = SearchMessageService(
    //   onChange: widget.onChange,
    //   onTap: widget.onTap,
    //   onCancel: widget.onCancel,
    //   animationValue: widget.animationValue,
    //   controller: widget.controller,
    //   focusNode: widget.focusNode,
    // );
    _searchMessageService.isSearchMessageMode.add(true);
    if (hasVirtualKeyboardCapability) {
      _keyboardVisibilityController.onChange.listen((event) {
        if (!event) {
          _getFocusNode().unfocus();
        }
      });
    }
    (widget.controller ?? _localController).addListener(() {
      if ((widget.controller ?? _localController).text.isNotEmpty) {
        _hasText.add(true);
      } else if (_hasText.value ?? false) {
        _hasText.add(false);
      }
    });
    super.initState();
  }

  double get _height => widget.animationValue != null
      ? (40 - (widget.animationValue! / 3.5))
      : 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildSearchBar(),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<int>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                return _buildMessageList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[300],
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textDirection: _i18n.defaultTextDirection,
            _i18n.get("search_messages_in"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _buildMemberWidget(widget.uid),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[300],
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textDirection: _i18n.defaultTextDirection,
            _i18n.get("search_for_messages"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<String?>(
            stream: _text,
            builder: (context, text) {
              if (text.hasData && text.data!.isNotEmpty) {
                return FutureBuilder<List<Message>>(
                  future: _searchMessageService.searchMessagesResult(
                    widget.uid,
                    text.data!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final message = _searchMessageService
                              .extractText(snapshot.data![index]);
                          return Container(
                            child: _buildResultWidget(
                              snapshot.data![index],
                              message,
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        )
      ],
    );
  }

  Widget buildSearchBar() {
    return SizedBox(
      height: _height,
      child: AutoDirectionTextField(
        focusNode: _localFocusNode,
        controller: widget.controller ?? _localController,
        onChanged: (str) {
          widget.onChange?.call(str);
          _text.add(str);
        },
        onTap: () {
          widget.onTap?.call();
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsetsDirectional.only(top: 1),
          focusedBorder: const OutlineInputBorder(
            borderRadius: mainBorder,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: mainBorder,
            borderSide: BorderSide.none,
          ),
          filled: true,
          isDense: true,
          prefixIcon: const Icon(CupertinoIcons.search),
          suffixIcon: StreamBuilder<bool?>(
            stream: _hasText,
            builder: (c, ht) {
              if (ht.hasData) {
                if (ht.data!) {
                  return _buildZoomInClearIcon();
                } else {
                  return _buildZoomOutClearIcon();
                }
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          hintText: _i18n.get("search"),
        ),
      ),
    );
  }

  Widget _buildMemberWidget(Uid uid) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _routingServices.openProfile(uid.asString());
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatarWidget(uid, 18),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _roomRepo.getName(uid),
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextLoader(
                              text: Text(
                                snapshot.data ?? "".replaceAll('', '\u200B'),
                                style: (Theme.of(context).textTheme.titleSmall)!
                                    .copyWith(height: 1.3),
                                softWrap: false,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () =>
                  {_searchMessageService.isSearchMessageMode.add(false)},
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultWidget(Message msg, String result) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _searchMessageService.foundMessageId.add(msg.id!);
      },
      child: Directionality(
        textDirection: _i18n.defaultTextDirection,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatarWidget(msg.from, 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RoomName(
                            uid: msg.from,
                          ),
                        ),
                        Row(
                          children: _buildDateAndStatusMessage(msg),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: p8,
                    ),
                    _buildLastMessage(msg)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastMessage(Message message) {
    return AsyncLastMessage(
      message: message,
    );
  }

  List<Widget> _buildDateAndStatusMessage(Message message) {
    return [
      if (_authRepo.isCurrentUser(message.from))
        Padding(
          padding: const EdgeInsets.all(p4),
          child: SeenStatus(
            message.roomUid,
            message.packetId,
            messageId: message.id,
          ),
        ),
      Text(
        dateTimeFromNowFormat(
          date(message.time),
          summery: true,
        ),
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 11,
        ),
        textDirection: _i18n.defaultTextDirection,
      ),
    ];
  }

  Widget _buildZoomOutClearIcon() {
    return Spin(
      key: const Key("zoom-out"),
      spins: 1 / 4,
      duration: const Duration(milliseconds: 200),
      child: ZoomOut(
        duration: const Duration(milliseconds: 400),
        child: _buildClearIcon(),
      ),
    );
  }

  Widget _buildZoomInClearIcon() {
    return Spin(
      key: const Key("zoom-in"),
      spins: 1 / 4,
      duration: const Duration(milliseconds: 200),
      child: ZoomIn(
        duration: const Duration(milliseconds: 200),
        child: _buildClearIcon(),
      ),
    );
  }

  Widget _buildClearIcon() {
    return IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        _hasText.add(false);
        _clearTextEditingController();
        _text.add(null);
        _getFocusNode().unfocus();
        widget.onCancel?.call();
      },
    );
  }
}
