
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/custom_context_menu/methods/custom_text_selection_methods.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CustomMaterialContextMenu {
  TextEditingController textController;
  BuildContext buildContext;
  Uid roomUid;
  EditableTextState editableTextState;

  CustomMaterialContextMenu({
    required this.buildContext,
    required this.textController,
    required this.roomUid,
    required this.editableTextState,
  });

  Widget buildToolbar() {
    return _TextSelectionControlsToolbar(
      textSelectionToolbarAnchors: editableTextState.contextMenuAnchors,
      clipboardStatus: editableTextState.clipboardStatus,
      handleCut: editableTextState.cutEnabled
          ? () => editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.cut,
              )
              .onPressed
          : null,
      handleCopy: editableTextState.copyEnabled
          ? () => editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.copy,
              )
              .onPressed
          : null,
      handleSelectAll: editableTextState.selectAllEnabled
          ? () => editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.selectAll,
              )
              .onPressed
          : null,
      handlePaste: editableTextState.pasteEnabled
          ? editableTextState.contextMenuButtonItems
              .firstWhere(
                (element) => element.type == ContextMenuButtonType.paste,
              )
              .onPressed
          : null,
      handleUnderline: () => CustomContextMenuMethods.handleFormatting(
        UnderlineFeature.specialChar,
        textController,
      ),
      handleSpoiler: () => CustomContextMenuMethods.handleFormatting(
        SpoilerFeature.specialChar,
        textController,
      ),
      handleBold: () => CustomContextMenuMethods.handleFormatting(
        BoldFeature.specialChar,
        textController,
      ),
      handleItalic: () => CustomContextMenuMethods.handleFormatting(
        ItalicFeature.specialChar,
        textController,
      ),
      handleStrikethrough: () => CustomContextMenuMethods.handleFormatting(
        StrikethroughFeature.specialChar,
        textController,
      ),
      isAnyThingSelected: () =>
          CustomContextMenuMethods.isAnyThingSelected(textController),
      handleCreateLink: () => CustomContextMenuMethods.handleCreateLink(
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

    required this.handleCut,
    required this.handleCopy,
    required this.handlePaste,
    required this.handleSelectAll,

    required this.handleBold,
    required this.handleItalic,
    required this.handleStrikethrough,
    required this.handleSpoiler,
    required this.handleUnderline,
    required this.handleCreateLink,
    required this.isAnyThingSelected, required this.textSelectionToolbarAnchors,
  });

  final ClipboardStatusNotifier? clipboardStatus;
  final VoidCallback? handleCut;
  final VoidCallback? handleCopy;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final TextSelectionToolbarAnchors textSelectionToolbarAnchors;
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
      anchorAbove: widget.textSelectionToolbarAnchors.primaryAnchor,
      anchorBelow: widget.textSelectionToolbarAnchors.primaryAnchor,
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
