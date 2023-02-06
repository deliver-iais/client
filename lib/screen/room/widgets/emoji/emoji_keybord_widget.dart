import 'dart:math';

import 'package:deliver/box/dao/emoji_skin_tone_dao.dart';
import 'package:deliver/box/dao/recent_emoji_dao.dart';
import 'package:deliver/box/recent_emoji.dart';
import 'package:deliver/fonts/emoji_font.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/room/widgets/emoji/footer/search_bar_footer.dart';
import 'package:deliver/screen/room/widgets/emoji/header/emoji_selection_header.dart';
import 'package:deliver/screen/room/widgets/emoji/skin_tone_overlay/skin_tone_overlay.dart';
import 'package:deliver/screen/room/widgets/input_message.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class EmojiKeyboardWidget extends StatefulWidget {
  final void Function(String) onTap;
  final void Function(bool) onSearchEmoji;
  final VoidCallback? onSkinToneOverlay;
  final VoidCallback onEmojiDeleted;
  final KeyboardStatus keyboardStatus;

  const EmojiKeyboardWidget({
    super.key,
    required this.onTap,
    required this.onSearchEmoji,
    required this.keyboardStatus,
    this.onSkinToneOverlay,
    required this.onEmojiDeleted,
  });

  @override
  EmojiKeyboardWidgetState createState() => EmojiKeyboardWidgetState();
}

class EmojiKeyboardWidgetState extends State<EmojiKeyboardWidget>
    with CustomPopupMenu {
  static final _featureFlags = GetIt.I.get<FeatureFlags>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _recentEmojisDao = GetIt.I.get<RecentEmojiDao>();
  static final _emojiSkinToneDao = GetIt.I.get<EmojiSkinToneDao>();

  final _scrollController = ScrollController(
    initialScrollOffset: hasVirtualKeyboardCapability ? 55 : 0,
  );
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final _selectedEmojiGroup = BehaviorSubject<EmojiGroup?>.seeded(null);
  final BehaviorSubject<bool> _searchBoxHasText = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _hideHeaderAndFooter =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _pinHeader = BehaviorSubject.seeded(true);
  final BehaviorSubject<List<Emoji>?> _searchEmojiResult =
      BehaviorSubject.seeded(null);

  final _headersKeyList = List.generate(
    EmojiGroup.values.length,
    (i) => GlobalKey(debugLabel: EmojiGroup.values[i].toString()),
  );
  OverlayEntry? _skinToneOverlay;
  bool _isSearchModeEnable = false;

  @override
  void initState() {
    _recentEmojisDao.getAll().then((value) {
      if (value.isNotEmpty) {
        _selectedEmojiGroup.add(EmojiGroup.recentEmoji);
      } else {
        _selectedEmojiGroup.add(EmojiGroup.smileysEmotion);
      }
    });
    _emojiSkinToneDao.getAll().then(
          (value) => {
            if (value.isNotEmpty)
              {
                for (var element in value)
                  {Emoji.updateSkinTone(element.char, element.tone)}
              }
          },
        );
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        if (!_searchBoxHasText.value) {
          setState(() {
            _isSearchModeEnable = true;
          });
          _searchBoxHasText.add(true);
        }
      } else {
        if (_searchBoxHasText.value) {
          setState(() {
            _isSearchModeEnable = false;
          });
          _searchBoxHasText.add(false);
        }
      }
    });
    _scrollController.addListener(() {
      _closeSkinToneOverlay();
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _pinHeader.add(false);
        if (!_hideHeaderAndFooter.value) {
          _hideHeaderAndFooter.add(true);
        }
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        _pinHeader.add(false);
        if (_hideHeaderAndFooter.value) {
          _hideHeaderAndFooter.add(false);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _closeSkinToneOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.keyboardStatus == KeyboardStatus.EMOJI_KEYBOARD &&
        _searchFocusNode.hasFocus) {
      _scrollController.jumpTo(55);
      _searchFocusNode.unfocus();
    }
    final theme = Theme.of(context);

    return FutureBuilder<List<RecentEmoji>>(
      future: _recentEmojisDao.getAll(),
      builder: (context, recentEmoji) {
        if (recentEmoji.hasData && recentEmoji.data != null) {
          Emoji.addRecentEmojis(recentEmoji.data!);
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification) {
              _onScrollEnded(context);
            }
            return true;
          },
          child: GestureDetector(
            onTap: () => _closeSkinToneOverlay(),
            child: Container(
              decoration: BoxDecoration(
                boxShadow:
                    hasVirtualKeyboardCapability ? null : DEFAULT_BOX_SHADOWS,
                color: theme.colorScheme.onInverseSurface,
                borderRadius:
                    hasVirtualKeyboardCapability ? null : tertiaryBorder,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollController,
                      shrinkWrap: true,
                      slivers: <Widget>[
                        //selection header
                        if (hasVirtualKeyboardCapability &&
                            widget.keyboardStatus ==
                                KeyboardStatus.EMOJI_KEYBOARD)
                          StreamBuilder<bool>(
                            stream: _pinHeader,
                            builder: (context, snapshot) {
                              return _buildSelectionHeaderWidget(
                                pinHeader: snapshot.data ?? true,
                              );
                            },
                          ),
                        if (!hasVirtualKeyboardCapability)
                          _buildSelectionHeaderWidget(),

                        //todo(chitsaz) fix overlay problem with text field and add search box
                        //search box
                        if (hasVirtualKeyboardCapability)
                          _buildEmojiSearchBox(theme),

                        //emoji grid
                        if (_isSearchModeEnable)
                          StreamBuilder<List<Emoji>?>(
                            stream: _searchEmojiResult,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                if (snapshot.data!.isNotEmpty) {
                                  return _buildEmojiGrid(
                                    snapshot.data!.toList(),
                                  );
                                } else {
                                  return SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: 50,
                                      child: Center(
                                        child: Text(_i18n.get("no_results")),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                return const SliverToBoxAdapter(
                                  child: SizedBox.shrink(),
                                );
                              }
                            },
                          )
                        else
                          ..._buildEmojiList()
                      ],
                    ),
                  ),

                  //footer

                  if (widget.keyboardStatus == KeyboardStatus.EMOJI_KEYBOARD &&
                      hasVirtualKeyboardCapability)
                    StreamBuilder<bool>(
                      stream: _hideHeaderAndFooter,
                      builder: (context, snapshot) {
                        return _buildFooter(
                          hideHeader: snapshot.data ?? false,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter({bool hideHeader = false}) {
    return AnimatedContainer(
      duration: VERY_SLOW_ANIMATION_DURATION,
      height: hideHeader ? 0 : 30,
      child: SearchBarFooter(
        onEmojiDeleted: widget.onEmojiDeleted,
        onSearchIconTap: () {
          widget.onSearchEmoji(true);
          _scrollController.jumpTo(
            0,
          );
          Future.delayed(
            const Duration(milliseconds: 500),
            () {},
          ).then((_) {
            _searchFocusNode.requestFocus();
          });
        },
      ),
    );
  }

  Widget _buildSelectionHeaderWidget({bool pinHeader = true}) {
    return EmojiSelectionHeader(
      pinHeader: pinHeader,
      selectedEmojiGroup: _selectedEmojiGroup,
      onEmojiGroupHeaderTap: (index) {
        _closeSkinToneOverlay();
        _selectedEmojiGroup.add(EmojiGroup.values[index]);
        _pinHeader.add(true);
        Scrollable.ensureVisible(
          _headersKeyList[index].currentContext!,
          duration: SUPER_SLOW_ANIMATION_DURATION,
          curve: Curves.fastOutSlowIn,
        );
      },
    );
  }

  Widget _buildEmojiSearchBox(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        color: theme.colorScheme.onInverseSurface,
        child: Focus(
          onFocusChange: (hasFocus) {
            widget.onSearchEmoji(hasFocus);
          },
          child: Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 25.0,
                left: 25,
                top: 15,
                bottom: 8,
              ),
              child: AutoDirectionTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (text) async {
                  if (text.isNotEmpty) {
                    _searchEmojiResult.add(Emoji.search(text).toList());
                  }
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: _i18n.get("search"),
                  contentPadding: const EdgeInsets.only(top: 15),
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
                    stream: _searchBoxHasText,
                    builder: (c, ht) {
                      if (ht.hasData && ht.data!) {
                        return IconButton(
                          icon: const Icon(
                            CupertinoIcons.xmark,
                          ),
                          onPressed: () {
                            _searchController.text = '';
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onScrollEnded(BuildContext context) {
    final columns = Emoji.getColumnsCount(context);
    var offset = 0.0;
    var selectedGroup = Emoji.recent().isNotEmpty
        ? EmojiGroup.recentEmoji
        : EmojiGroup.smileysEmotion;
    for (final group in EmojiGroup.values) {
      offset = offset +
          (45) * (((Emoji.byGroup(group).length / columns).ceil())) +
          (group.index >= 1 ? 40 : 0);
      if (_scrollController.offset >=
          offset + (hasVirtualKeyboardCapability ? 60 : 0)) {
        selectedGroup = EmojiGroup.values[min(group.index + 1, 9)];
      }
    }
    _selectedEmojiGroup.add(selectedGroup);
  }

  List<RenderObjectWidget> _buildEmojiList() {
    final emojiList = <RenderObjectWidget>[];

    for (final emojiGroup in EmojiGroup.values) {
      final emoji = Emoji.byGroup(emojiGroup);
      if (emoji.isNotEmpty) {
        emojiList.addAll(_buildGroupEmojiList(emojiGroup, emoji));
      }
    }
    return emojiList;
  }

  List<RenderObjectWidget> _buildGroupEmojiList(
    EmojiGroup emojiGroup,
    Iterable<Emoji> emojiList,
  ) {
    final header = Emoji.convertEmojiGroupToHeader(emojiGroup);
    return [
      SliverToBoxAdapter(
        key: _headersKeyList[emojiGroup.index],
        child: SizedBox(
          height: header.isNotEmpty ? 40 : 0,
          child: Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: Text(
                header,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
      _buildEmojiGrid(emojiList.toList())
    ];
  }

  void _onLongTap(int index, Emoji emoji) {
    _closeSkinToneOverlay();
    if (emoji.emojiGroup == EmojiGroup.recentEmoji) {
      _showClearRecentEmojiDialog();
    } else if (emoji.modifiable) {
      _skinToneOverlay = SkinToneOverlay.getSkinToneOverlay(
        index,
        emoji,
        context,
        _scrollController.offset,
        _onEmojiSelected,
        widget.onSkinToneOverlay,
        hideHeaderAndFooter: _hideHeaderAndFooter.value,
      );
      if (_skinToneOverlay != null) {
        Overlay.of(context)?.insert(_skinToneOverlay!);
      }
    }
  }

  void _showClearRecentEmojiDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: _i18n.defaultTextDirection,
        child: AlertDialog(
          title: Text(
            _i18n.get("clear_recent_emoji"),
          ),
          content: Text(
            _i18n.get("sure_clear_recent_emoji"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(_i18n.get("cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(_i18n.get("clear_all")),
              onPressed: () {
                _recentEmojisDao.deleteAll();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverGrid _buildEmojiGrid(List<Emoji> emojiList) {
    return SliverGrid(
      delegate:
          SliverChildBuilderDelegate(childCount: emojiList.length, (c, index) {
        return Material(
          color: Colors.white.withOpacity(0.0),
          child: GestureDetector(
            onSecondaryTap: () {
              _onLongTap(index, emojiList.elementAt(index));
            },
            child: InkWell(
              borderRadius: tertiaryBorder,
              onTap: () {
                _onEmojiSelected(emojiList.elementAt(index).toString());
                _recentEmojisDao
                    .addRecentEmoji(emojiList.elementAt(index).toString());
              },
              onLongPress: () {
                vibrate(duration: 30);
                _onLongTap(index, emojiList.elementAt(index));
              },
              onTapDown: storePosition,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      emojiList.elementAt(index).toString(),
                      style: EmojiFont.notoColorEmojiCompat(fontSize: 25),
                    ),
                  ),
                  if (_featureFlags.showDeveloperDetails)
                    if (isAnimatedEmoji(emojiList.elementAt(index).toString()))
                      Center(
                        child: Container(
                          color: ACTIVE_COLOR,
                          height: 10,
                          width: 10,
                        ),
                      )
                ],
              ),
            ),
          ),
        );
      }),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Emoji.getColumnsCount(context),
      ),
    );
  }

  void _onEmojiSelected(String emoji) {
    vibrate(duration: 30);
    widget.onTap(emoji);
    _closeSkinToneOverlay();
  }

  void _closeSkinToneOverlay() {
    _skinToneOverlay?.remove();
    _skinToneOverlay = null;
  }
}
