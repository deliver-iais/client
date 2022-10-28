import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/custom_text_selection/methods/custom_text_selection_methods.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';

const double _kHandleSize = 22.0;

// Padding between the toolbar and the anchor.
const double _kToolbarContentDistanceBelow = _kHandleSize - 2.0;
const double _kToolbarContentDistance = 8.0;

class CustomMaterialTextSelectionControls
    extends MaterialTextSelectionControls {
  TextEditingController textController;
  BuildContext buildContext;
  Uid roomUid;

  CustomMaterialTextSelectionControls({
    required this.buildContext,
    required this.textController,
    required this.roomUid,
  });

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _TextSelectionControlsToolbar(
      globalEditableRegion: globalEditableRegion,
      textLineHeight: textLineHeight,
      selectionMidpoint: selectionMidpoint,
      endpoints: endpoints,
      delegate: delegate,
      clipboardStatus: clipboardStatus,
      handleCut: canCut(delegate) ? () => handleCut(delegate) : null,
      handleCopy: canCopy(delegate) ? () => handleCopy(delegate) : null,
      handlePaste: canPaste(delegate)
          ? () {
              if (!isDesktop) {
                handlePaste(delegate);
              } else {
                CustomTextSelectionMethods.desktopPastHandle(
                    delegate, textController, roomUid, buildContext);
              }
            }
          : null,
      handleSelectAll:
          canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
      handleUnderline: () => CustomTextSelectionMethods.handleFormatting(
        delegate,
        UnderlineFeature.specialChar,
        textController,
      ),
      handleSpoiler: () => CustomTextSelectionMethods.handleFormatting(
        delegate,
        SpoilerFeature.specialChar,
        textController,
      ),
      handleBold: () => CustomTextSelectionMethods.handleFormatting(
        delegate,
        BoldFeature.specialChar,
        textController,
      ),
      handleItalic: () => CustomTextSelectionMethods.handleFormatting(
        delegate,
        ItalicFeature.specialChar,
        textController,
      ),
      handleStrikethrough: () => CustomTextSelectionMethods.handleFormatting(
        delegate,
        StrikethroughFeature.specialChar,
        textController,
      ),
      isAnyThingSelected: () =>
          CustomTextSelectionMethods.isAnyThingSelected(textController),
      handleCreateLink: () => CustomTextSelectionMethods.handleCreateLink(
        delegate,
        buildContext,
        textController,
      ),
    );
  }
}

// The highest level toolbar widget, built directly by buildToolbar.
class _TextSelectionControlsToolbar extends StatefulWidget {
  const _TextSelectionControlsToolbar({
    required this.clipboardStatus,
    required this.delegate,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCut,
    required this.handleCopy,
    required this.handlePaste,
    required this.handleSelectAll,
    required this.selectionMidpoint,
    required this.textLineHeight,
    required this.handleBold,
    required this.handleItalic,
    required this.handleStrikethrough,
    required this.handleSpoiler,
    required this.handleUnderline,
    required this.handleCreateLink,
    required this.isAnyThingSelected,
  });

  final ClipboardStatusNotifier? clipboardStatus;
  final TextSelectionDelegate delegate;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCut;
  final VoidCallback? handleCopy;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final Offset selectionMidpoint;
  final double textLineHeight;
  final VoidCallback handleBold;
  final VoidCallback handleItalic;
  final VoidCallback handleStrikethrough;
  final VoidCallback handleSpoiler;
  final VoidCallback handleUnderline;
  final VoidCallback handleCreateLink;
  final bool Function() isAnyThingSelected;

  @override
  _TextSelectionControlsToolbarState createState() =>
      _TextSelectionControlsToolbarState();
}

class _TextSelectionControlsToolbarState
    extends State<_TextSelectionControlsToolbar> with TickerProviderStateMixin {
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
  void didUpdateWidget(_TextSelectionControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clipboardStatus != oldWidget.clipboardStatus) {
      widget.clipboardStatus?.addListener(_onChangedClipboardStatus);
      oldWidget.clipboardStatus?.removeListener(_onChangedClipboardStatus);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.clipboardStatus?.removeListener(_onChangedClipboardStatus);
  }

  @override
  Widget build(BuildContext context) {
    // If there are no buttons to be shown, don't render anything.
    if (widget.handleCut == null &&
        widget.handleCopy == null &&
        widget.handlePaste == null &&
        widget.handleSelectAll == null) {
      return const SizedBox.shrink();
    }
    // If the paste button is desired, don't render anything until the state of
    // the clipboard is known, since it's used to determine if paste is shown.
    if (widget.handlePaste != null &&
        widget.clipboardStatus?.value == ClipboardStatus.unknown) {
      return const SizedBox.shrink();
    }

    // Calculate the positioning of the menu. It is placed above the selection
    // if there is enough room, or otherwise below.
    final startTextSelectionPoint = widget.endpoints[0];
    final endTextSelectionPoint =
        widget.endpoints.length > 1 ? widget.endpoints[1] : widget.endpoints[0];
    final topAmountInEditableRegion =
        startTextSelectionPoint.point.dy - widget.textLineHeight;
    final anchorTop = max(topAmountInEditableRegion, 0) +
        widget.globalEditableRegion.top -
        _kToolbarContentDistance;

    final anchorAbove = Offset(
      widget.globalEditableRegion.left + widget.selectionMidpoint.dx,
      anchorTop,
    );
    final anchorBelow = Offset(
      widget.globalEditableRegion.left + widget.selectionMidpoint.dx,
      widget.globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    // Determine which buttons will appear so that the order and total number is
    // known. A button's position in the menu can slightly affect its
    // appearance.
    assert(debugCheckHasMaterialLocalizations(context));
    final localizations = MaterialLocalizations.of(context);
    final itemDatas = <_TextSelectionToolbarItemData>[
      if (widget.handleCut != null)
        _TextSelectionToolbarItemData(
          label: localizations.cutButtonLabel,
          onPressed: widget.handleCut!,
        ),
      if (widget.handleCopy != null)
        _TextSelectionToolbarItemData(
          label: localizations.copyButtonLabel,
          onPressed: widget.handleCopy!,
        ),
      if (widget.handlePaste != null &&
          widget.clipboardStatus?.value == ClipboardStatus.pasteable)
        _TextSelectionToolbarItemData(
          label: localizations.pasteButtonLabel,
          onPressed: widget.handlePaste!,
        ),
      if (widget.handleSelectAll != null)
        _TextSelectionToolbarItemData(
          label: localizations.selectAllButtonLabel,
          onPressed: widget.handleSelectAll!,
        ),
      if (widget.isAnyThingSelected()) ...[
        _TextSelectionToolbarItemData(
          label: _i18n.get("bold"),
          onPressed: widget.handleBold,
        ),
        _TextSelectionToolbarItemData(
          label: _i18n.get("italic"),
          onPressed: widget.handleItalic,
        ),
        _TextSelectionToolbarItemData(
          label: _i18n.get("strike_through"),
          onPressed: widget.handleStrikethrough,
        ),
        _TextSelectionToolbarItemData(
          label: _i18n.get("spoiler"),
          onPressed: widget.handleSpoiler,
        ),
        _TextSelectionToolbarItemData(
          label: _i18n.get("underline"),
          onPressed: widget.handleUnderline,
        ),
        _TextSelectionToolbarItemData(
          label: _i18n.get("create_link"),
          onPressed: widget.handleCreateLink,
        ),
      ]
    ];

    // If there is no option available, build an empty widget.
    if (itemDatas.isEmpty) {
      return const SizedBox.shrink();
    }

    return TextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      children: itemDatas.asMap().entries.map((entry) {
        return TextSelectionToolbarTextButton(
          padding: TextSelectionToolbarTextButton.getPadding(
            entry.key,
            itemDatas.length,
          ),
          onPressed: entry.value.onPressed,
          child: Text(entry.value.label),
        );
      }).toList(),
    );
  }
}

// The label and callback for the available default text selection menu buttons.
class _TextSelectionToolbarItemData {
  const _TextSelectionToolbarItemData({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}
