import 'package:deliver/fonts/emoji_font.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/room/widgets/emoji/persistent_emoji_header.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class EmojiKeyboardWidget extends StatefulWidget {
  final void Function(String) onTap;
  final void Function(bool) onEmojiSearch;
  final Function? onStickerTap;

  const EmojiKeyboardWidget({
    super.key,
    required this.onTap,
    this.onStickerTap,
    required this.onEmojiSearch,
  });

  @override
  EmojiKeyboardWidgetState createState() => EmojiKeyboardWidgetState();
}

class EmojiKeyboardWidgetState extends State<EmojiKeyboardWidget>
    with CustomPopupMenu {
  static final _featureFlags = GetIt.I.get<FeatureFlags>();
  static final _i18n = GetIt.I.get<I18N>();

  final _scrollController = ScrollController(initialScrollOffset: 50);
  OverlayEntry? _overlay;
  final _selectedEmojiGroup =
      BehaviorSubject<EmojiGroup>.seeded(EmojiGroup.smileysEmotion);
  final _headersKeyList = List.generate(
    EmojiGroup.values.length,
    (i) => GlobalKey(debugLabel: EmojiGroup.values[i].toString()),
  );
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final BehaviorSubject<bool> _hasText = BehaviorSubject.seeded(false);

  @override
  void initState() {
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        _hasText.add(true);
      } else {
        _hasText.add(false);
      }
    });
    _scrollController.addListener(() {
      _closeSkinToneOverlay();
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
    final theme = Theme.of(context);

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
          color: theme.colorScheme.onInverseSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: PersistentEmojiHeader(
                        widget: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onInverseSurface,
                            border: Border(
                              bottom: BorderSide(color: theme.dividerColor),
                            ),
                          ),
                          child: DefaultTextStyle(
                            style: const TextStyle(fontSize: 20),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: EmojiGroup.values.length,
                                itemBuilder: (c, index) {
                                  return buildTabBarContainer(
                                      theme, EmojiGroup.values[index], () {
                                    Scrollable.ensureVisible(
                                      _headersKeyList[index].currentContext!,
                                      duration: SUPER_SLOW_ANIMATION_DURATION,
                                      curve: Curves.fastOutSlowIn,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          widget.onEmojiSearch(hasFocus);
                          // setState(() {
                          //   _isSearchFocused = hasFocus;
                          // });
                        },
                        child: Directionality(
                          textDirection: _i18n.defaultTextDirection,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 25.0,
                              left: 25,
                              top: 15,
                            ),
                            child: SizedBox(
                              height: 35,
                              child: AutoDirectionTextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: (text) async {},
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: _i18n.get("search"),
                                  contentPadding:
                                      const EdgeInsets.only(top: 15),
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
                                      if (ht.hasData && ht.data!) {
                                        return IconButton(
                                          icon:
                                              const Icon(CupertinoIcons.xmark),
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
                    ),
                    ..._buildEmojiGrid()
                  ],
                ),
              ),
              _buildSearchBar()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onInverseSurface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {
              widget.onEmojiSearch(true);
              _scrollController.jumpTo(
                0,
              );
              Future.delayed(const Duration(milliseconds: 500), () {})
                  .then((_) {
                _searchFocusNode.requestFocus();
              });
            },
            icon: const Icon(CupertinoIcons.search),
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.backspace_rounded,
              color: theme.colorScheme.primary,
            ),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  void _onScrollEnded(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = _getColumnsCount();
    var offset = 0.0;
    var selectedGroup = EmojiGroup.smileysEmotion;
    for (final group in EmojiGroup.values) {
      offset = offset +
          (width / columns) *
              (((Emoji.byGroup(group).length / columns)).round()) +
          30;
      if (_scrollController.offset > offset) {
        selectedGroup = EmojiGroup.values[group.index + 1];
      }
    }
    _selectedEmojiGroup.add(selectedGroup);
  }

  List<RenderObjectWidget> _buildEmojiGrid() {
    final gridList = <RenderObjectWidget>[];

    for (final emojiGroup in EmojiGroup.values) {
      gridList.addAll(_buildEmojiGridItem(emojiGroup));
    }
    return gridList;
  }

  List<RenderObjectWidget> _buildEmojiGridItem(
    EmojiGroup emojiGroup,
  ) {
    final emoji = Emoji.byGroup(emojiGroup);
    return [
      SliverToBoxAdapter(
        key: _headersKeyList[emojiGroup.index],
        child: Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Text(
              Emoji.convertEmojiGroupToHeader(emojiGroup),
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      SliverGrid(
        delegate:
            SliverChildBuilderDelegate(childCount: emoji.length, (c, index) {
          return Material(
            color: Colors.white.withOpacity(0.0),
            child: GestureDetector(
              onSecondaryTap: () {
                _openSkinToneOverlay(index, emoji.elementAt(index));
              },
              child: InkWell(
                borderRadius: tertiaryBorder,
                onTap: () {
                  _onEmojiSelected(emoji.elementAt(index).toString());
                },
                onLongPress: () {
                  vibrate(duration: 30);
                  _openSkinToneOverlay(index, emoji.elementAt(index));
                },
                onTapDown: storePosition,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        emoji.elementAt(index).toString(),
                        style: EmojiFont.notoColorEmojiCompat(fontSize: 25),
                      ),
                    ),
                    if (_featureFlags.showDeveloperDetails)
                      if (isAnimatedEmoji(emoji.elementAt(index).toString()))
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
          crossAxisCount: _getColumnsCount(),
        ),
      ),
    ];
  }

  void _openSkinToneOverlay(int index, Emoji emoji) {
    _closeSkinToneOverlay();
    if (emoji.modifiable) {
      _buildSkinToneOverlay(
        index,
        emoji,
      );
    }
  }

  void _buildSkinToneOverlay(int index, Emoji emoji) {
    final positionRect = _calculateEmojiPosition(index);
    final theme = Theme.of(context);
    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        left: positionRect.left,
        top: positionRect.top,
        child: Container(
          height: positionRect.width + 10,
          decoration: const BoxDecoration(
            boxShadow: DEFAULT_BOX_SHADOWS,
            borderRadius: tertiaryBorder,
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: DEFAULT_BOX_SHADOWS,
                  borderRadius: tertiaryBorder,
                ),
                child: Row(
                  children: [
                    ...List.generate(
                      fitzpatrick.values.length,
                      (i) => _buildSkinToneEmoji(
                        i,
                        emoji.toString(),
                        positionRect.width,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: positionRect.width,
                left: (positionRect.width * (index % _getColumnsCount()) -
                    positionRect.left +
                    10),
                child: ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(
                    color: theme.cardColor,
                    height: 10,
                    width: 15,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
    if (_overlay != null) {
      Overlay.of(context)?.insert(_overlay!);
    }
  }

  Rect _calculateEmojiPosition(int index) {
    final columns = _getColumnsCount();
    // Calculate position of emoji in the grid
    final row =
        (Emoji.byGroup(EmojiGroup.smileysEmotion).length / columns).round() +
            (index ~/ columns);
    final column = index % columns;

    // Calculate position for skin tone dialog
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final emojiSpace = renderBox.size.width / columns;
    final topOffset = emojiSpace;
    final leftOffset = _getLeftOffset(
      emojiSpace,
      column,
      fitzpatrick.values.length,
      columns,
    );
    final left = offset.dx -
        (isLarge(context) ? NAVIGATION_PANEL_SIZE : 0) +
        column * emojiSpace +
        leftOffset;
    final top = PersistentEmojiHeaderHeight +
        offset.dy +
        (row + 1) * emojiSpace -
        _scrollController.offset -
        topOffset +
        (isDesktop ? 20 : 0);
    return Rect.fromLTWH(left, top, emojiSpace, .0);
  }

  double _getLeftOffset(
    double emojiWidth,
    int column,
    int skinToneCount,
    int columns,
  ) {
    final remainingColumns = columns - (column + 1 + (skinToneCount ~/ 2));
    if (column >= 0 && column < 3) {
      return -1 * column * emojiWidth;
    } else if (remainingColumns < 0) {
      return -1 *
          ((skinToneCount ~/ 2 - 2) + -1 * remainingColumns) *
          emojiWidth;
    }
    return -1 * ((skinToneCount ~/ 2) * emojiWidth) + emojiWidth / 2;
  }

  int _getColumnsCount() {
    final width = MediaQuery.of(context).size.width;
    return (width - (isLarge(context) ? NAVIGATION_PANEL_SIZE : 0)) ~/ 45;
  }

  void _onEmojiSelected(String emoji) {
    vibrate(duration: 30);
    widget.onTap(emoji);
    _closeSkinToneOverlay();
  }

  Color selectionColor(ThemeData theme, EmojiGroup emoji) {
    if (isSelectedEmojiGroup(emoji)) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.onSurfaceVariant.withOpacity(0.7);
    }
  }

  bool isSelectedEmojiGroup(EmojiGroup emoji) =>
      emoji == _selectedEmojiGroup.value;

  Widget buildTabBarContainer(
    ThemeData theme,
    EmojiGroup emojiGroup,
    void Function() callback,
  ) {
    return StreamBuilder<EmojiGroup>(
      stream: _selectedEmojiGroup,
      builder: (context, snapshot) {
        return AnimatedContainer(
          duration: ANIMATION_DURATION,
          child: InkWell(
            onTap: () {
              _closeSkinToneOverlay();
              _selectedEmojiGroup.add(emojiGroup);
              callback();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Emoji.convertEmojiGroupToIcon(emojiGroup),
                color: selectionColor(theme, emojiGroup),
              ),
            ),
          ),
        );
      },
    );
  }

  void _closeSkinToneOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  Widget _buildSkinToneEmoji(int index, String emoji, double width) {
    final modifyEmoji = Emoji.modify(emoji, fitzpatrick.values[index]);
    return Material(
      color: Colors.white.withOpacity(0.0),
      child: InkWell(
        borderRadius: tertiaryBorder,
        onTap: () {
          _onEmojiSelected(modifyEmoji);
        },
        child: SizedBox(
          height: width,
          width: width - 10,
          child: Center(
            child: Text(
              modifyEmoji,
              style: EmojiFont.notoColorEmojiCompat(fontSize: 25),
            ),
          ),
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width / 2, size.height)
      ..close();
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
