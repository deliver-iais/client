import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Generates the child that's passed into DesktopTextSelectionToolbar.
class DesktopCustomContextMenuToolbar extends StatefulWidget {
  const DesktopCustomContextMenuToolbar({
    super.key,
    this.clipboardStatus,
    required this.handleCopy,
    this.handleCut,
    this.handlePaste,
    required this.handleSelectAll,
    this.handleBold,
    this.handleItalic,
    this.handleStrikethrough,
    this.handleSpoiler,
    this.handleUnderline,
    this.handleCreateLink,
    this.isAnyThingSelected,
    required this.textSelectionToolbarAnchors,
  });

  final ClipboardStatusNotifier? clipboardStatus;
  final VoidCallback? handleCopy;
  final VoidCallback? handleCut;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final TextSelectionToolbarAnchors textSelectionToolbarAnchors;
  final VoidCallback? handleBold;
  final VoidCallback? handleItalic;
  final VoidCallback? handleStrikethrough;
  final VoidCallback? handleSpoiler;
  final VoidCallback? handleUnderline;
  final VoidCallback? handleCreateLink;
  final bool Function()? isAnyThingSelected;

  @override
  DesktopCustomContextMenuToolbarState createState() =>
      DesktopCustomContextMenuToolbarState();
}

class DesktopCustomContextMenuToolbarState
    extends State<DesktopCustomContextMenuToolbar> {
  final _i18n = GetIt.I.get<I18N>();

  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    widget.clipboardStatus?.addListener(_onChangedClipboardStatus);
  }

  @override
  void didUpdateWidget(DesktopCustomContextMenuToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clipboardStatus != widget.clipboardStatus) {
      oldWidget.clipboardStatus?.removeListener(_onChangedClipboardStatus);
      widget.clipboardStatus?.addListener(_onChangedClipboardStatus);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.clipboardStatus?.removeListener(_onChangedClipboardStatus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Don't render the menu until the state of the clipboard is known.
    if (widget.handlePaste != null &&
        widget.clipboardStatus?.value == ClipboardStatus.unknown) {
      return const SizedBox.shrink();
    }

    assert(debugCheckHasMediaQuery(context));

    assert(debugCheckHasMaterialLocalizations(context));
    final localizations = MaterialLocalizations.of(context);
    final items = <Widget>[];

    void addToolbarButton(
      String text,
      VoidCallback onPressed,
      IconData iconData, {
      Color? textColor,
    }) {
      items.add(
        _DesktopTextSelectionToolbarButton.text(
          context: context,
          onPressed: onPressed,
          text: text,
          iconData: iconData,
          textColor: textColor,
        ),
      );
    }

    void addDivider() {
      items.add(const Divider());
    }

    Color? color;
    if (!(widget.isAnyThingSelected != null && widget.isAnyThingSelected!())) {
      color = Colors.grey;
    }

    if (widget.handleCut != null) {
      addToolbarButton(
        localizations.cutButtonLabel,
        widget.handleCut!,
        Icons.cut_rounded,
      );
    }
    if (widget.handleCopy != null) {
      addToolbarButton(
        localizations.copyButtonLabel,
        widget.handleCopy!,
        Icons.copy_all_rounded,
      );
    }
    if (widget.handlePaste != null) {
      addToolbarButton(
        localizations.pasteButtonLabel,
        widget.handlePaste!,
        Icons.paste,
      );
    }
    if (widget.handleSelectAll != null) {
      addToolbarButton(
        localizations.selectAllButtonLabel,
        widget.handleSelectAll!,
        Icons.select_all_rounded,
      );
    }
    if (widget.handleCreateLink != null) {
      addToolbarButton(
        _i18n.get("create_link"),
        widget.handleCreateLink!,
        Icons.link_rounded,
      );
    }
    if (widget.handleBold != null) {
      addDivider();
    }
    if (widget.handleBold != null) {
      addToolbarButton(
        _i18n.get("bold"),
        widget.handleBold!,
        Icons.format_bold_rounded,
        textColor: color,
      );
    }
    if (widget.handleItalic != null) {
      addToolbarButton(
        _i18n.get("italic"),
        widget.handleItalic!,
        Icons.format_italic_rounded,
        textColor: color,
      );
    }
    if (widget.handleStrikethrough != null) {
      addToolbarButton(
        _i18n.get("strike_through"),
        widget.handleStrikethrough!,
        Icons.strikethrough_s_rounded,
        textColor: color,
      );
    }
    if (widget.handleSpoiler != null) {
      addToolbarButton(
        _i18n.get("spoiler"),
        widget.handleSpoiler!,
        Icons.hide_source_rounded,
        textColor: color,
      );
    }
    if (widget.handleUnderline != null) {
      addToolbarButton(
        _i18n.get("underline"),
        widget.handleUnderline!,
        Icons.format_underline_rounded,
        textColor: color,
      );
    }

    // If there is no option available, build an empty widget.
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return IconTheme(
      data: IconTheme.of(context)
          .copyWith(size: 20, color: theme.colorScheme.onSurfaceVariant),
      child: _DesktopTextSelectionToolbar(
        anchor: widget.textSelectionToolbarAnchors.secondaryAnchor ??
            widget.textSelectionToolbarAnchors.primaryAnchor,
        children: items,
      ),
    );
  }
}

/// A Material-style desktop text selection toolbar.
///
/// Typically displays buttons for text manipulation, e.g. copying and pasting
/// text.
///
/// Tries to position itself as closely as possible to [anchor] while remaining
/// fully on-screen.
///
/// See also:
///
///  * [_DesktopTextSelectionControls.buildToolbar], where this is used by
///    default to build a Material-style desktop toolbar.
///  * [TextSelectionToolbar], which is similar, but builds an Android-style
///    toolbar.
class _DesktopTextSelectionToolbar extends StatelessWidget {
  /// Creates an instance of _DesktopTextSelectionToolbar.
  const _DesktopTextSelectionToolbar({
    required this.anchor,
    required this.children,
  }) : assert(children.length > 0);

  /// The point at which the toolbar will attempt to position itself as closely
  /// as possible.
  final Offset anchor;

  /// {@macro flutter.material.TextSelectionToolbar.children}
  ///
  /// See also:
  ///   * [DesktopTextSelectionToolbarButton], which builds a default
  ///     Material-style desktop text selection toolbar text button.
  final List<Widget> children;

  // Builds a desktop toolbar in the Material style.
  static Widget _defaultToolbarBuilder(BuildContext context, Widget child) {
    final theme = Theme.of(context);

    return Material(
      elevation: 4,
      borderRadius: tertiaryBorder,
      clipBehavior: Clip.hardEdge,
      color: elevation(theme.colorScheme.surface, theme.colorScheme.primary, 2),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: p8),
        constraints: const BoxConstraints(minWidth: 112, maxWidth: 180),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final mediaQuery = MediaQuery.of(context);

    final paddingAbove = mediaQuery.padding.top + p8;
    final localAdjustment = Offset(p8, paddingAbove);

    return Padding(
      padding: EdgeInsets.only(top: paddingAbove, bottom: p8),
      child: CustomSingleChildLayout(
        delegate: DesktopTextSelectionToolbarLayoutDelegate(
          anchor: anchor - localAdjustment,
        ),
        child: _defaultToolbarBuilder(
          context,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// A [TextButton] for the Material desktop text selection toolbar.
class _DesktopTextSelectionToolbarButton extends StatelessWidget {
  /// Creates an instance of DesktopTextSelectionToolbarButton.
  const _DesktopTextSelectionToolbarButton({
    required this.onPressed,
    required this.child,
  });

  /// Create an instance of [_DesktopTextSelectionToolbarButton] whose child is
  /// a [Text] widget in the style of the Material text selection toolbar.
  _DesktopTextSelectionToolbarButton.text({
    required BuildContext context,
    required this.onPressed,
    required IconData iconData,
    Color? textColor,
    required String text,
  }) : child = Row(
          children: [
            const SizedBox(width: p8),
            Icon(
              iconData,
              color: textColor,
            ),
            const SizedBox(width: p12),
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor ??
                    (Theme.of(context).colorScheme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87),
              ),
            ),
          ],
        );

  /// {@macro flutter.material.TextSelectionToolbarTextButton.onPressed}
  final VoidCallback onPressed;

  /// {@macro flutter.material.TextSelectionToolbarTextButton.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      // width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.onSurface),
          foregroundColor: theme.colorScheme.onSurface,
          shape: const RoundedRectangleBorder(),
          fixedSize: const Size.fromHeight(48),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
