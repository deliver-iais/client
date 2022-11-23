import 'package:deliver/fonts/emoji_font.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class EmojiKeyboard extends StatefulWidget {
  final void Function(String) onTap;
  final Function? onStickerTap;

  const EmojiKeyboard({super.key, required this.onTap, this.onStickerTap});

  @override
  EmojiKeyboardState createState() => EmojiKeyboardState();
}

class EmojiKeyboardState extends State<EmojiKeyboard> {
  static final _featureFlags = GetIt.I.get<FeatureFlags>();
  static final _i18n = GetIt.I.get<I18N>();
  final _selectedGroup =
      BehaviorSubject<EmojiGroup>.seeded(EmojiGroup.smileysEmotion);
  final _keyList = List.generate(EmojiGroup.values.length, (i)=>GlobalKey(debugLabel:EmojiGroup.values[i].toString() ));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.onInverseSurface,
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverPersistentHeader(
            floating: true,
            delegate: PersistentHeader(
              widget: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onInverseSurface,
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
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
                          return buildSelectedContainer(
                              theme, EmojiGroup.values[index], () {
                            Scrollable.ensureVisible(_keyList[index].currentContext!);
                          });
                        },
                    ),
                  ),
                ),
              ),
            ),
          ),
          ..._buildEmojiGrid()
        ],
      ),
    );
  }

  String convertEmojiGroupToHeader(EmojiGroup emojiGroup) {
    switch (emojiGroup) {
      case EmojiGroup.smileysEmotion:
        return _i18n.get("smileysEmotion");
      case EmojiGroup.peopleBody:
        return _i18n.get("peopleBody");
      case EmojiGroup.animalsNature:
        return _i18n.get("animalsNature");
      case EmojiGroup.flags:
        return _i18n.get("flags");
      case EmojiGroup.objects:
        return _i18n.get("objects");
      case EmojiGroup.travelPlaces:
        return _i18n.get("travelPlaces");
      case EmojiGroup.symbols:
        return _i18n.get("symbols");
      case EmojiGroup.foodDrink:
        return _i18n.get("foodDrink");
      case EmojiGroup.activities:
        return _i18n.get("activities");
    }
  }

  IconData convertEmojiGroupToIcon(EmojiGroup emojiGroup) {
    switch (emojiGroup) {
      case EmojiGroup.smileysEmotion:
        return Icons.tag_faces;
      case EmojiGroup.peopleBody:
        return Icons.back_hand_outlined;
      case EmojiGroup.animalsNature:
        return Icons.pets;
      case EmojiGroup.flags:
        return Icons.flag;
      case EmojiGroup.objects:
        return Icons.lightbulb_outline;
      case EmojiGroup.travelPlaces:
        return Icons.location_city;
      case EmojiGroup.symbols:
        return Icons.calculate_outlined;
      case EmojiGroup.foodDrink:
        return Icons.fastfood;
      case EmojiGroup.activities:
        return Icons.directions_run;
    }
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
        key: _keyList[emojiGroup.index],
        child: Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Text(
              convertEmojiGroupToHeader(emojiGroup),
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      SliverGrid(
        delegate: SliverChildBuilderDelegate(childCount: emoji.length,
            (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => widget.onTap(emoji.elementAt(index).toString()),
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
          );
        }),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (MediaQuery.of(context).size.width -
                  (isLarge(context) ? NAVIGATION_PANEL_SIZE : 0)) ~/
              45,
        ),
      ),
    ];
  }

  Color selectionColor(ThemeData theme, EmojiGroup emoji) {
    if (isSelectedEmojiGroup(emoji)) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.onSurfaceVariant.withOpacity(0.7);
    }
  }

  bool isSelectedEmojiGroup(EmojiGroup emoji) => emoji == _selectedGroup.value;

  Widget buildSelectedContainer(
    ThemeData theme,
    EmojiGroup emojiGroup,
    void Function() callback,
  ) {
    return StreamBuilder<EmojiGroup>(
      stream: _selectedGroup,
      builder: (context, snapshot) {
        return AnimatedContainer(
          duration: ANIMATION_DURATION,
          child: InkWell(
            onTap: () {
              _selectedGroup.add(emojiGroup);
              callback();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                convertEmojiGroupToIcon(emojiGroup),
                color: selectionColor(theme, emojiGroup),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;

  PersistentHeader({required this.widget});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52.0,
      child: Center(child: widget),
    );
  }

  @override
  double get maxExtent => 52.0;

  @override
  double get minExtent => 52.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
