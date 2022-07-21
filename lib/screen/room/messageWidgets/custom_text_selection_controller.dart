import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';

class CustomTextSelectionController extends CupertinoTextSelectionControls {
  TextEditingController captionController;
  TextEditingController textController;
  VoidCallback enableMarkDown;
  BuildContext buildContext;
  Uid roomUid;
  final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();
  final _i18n = GetIt.I.get<I18N>();

  CustomTextSelectionController({
    required this.captionController,
    required this.buildContext,
    required this.textController,
    required this.roomUid,
    required this.enableMarkDown,
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
    return _CupertinoTextSelectionControlsToolbar(
      clipboardStatus: clipboardStatus,
      endpoints: endpoints,
      globalEditableRegion: globalEditableRegion,
      handleCut:
          canCut(delegate) ? () => handleCut(delegate, clipboardStatus) : null,
      handleCopy: canCopy(delegate)
          ? () => handleCopy(delegate, clipboardStatus)
          : null,
      handlePaste: canPaste(delegate)
          ? () {
              if (!isDesktop) {
                handlePaste(delegate);
              } else {
                _rawKeyboardService.controlVHandle(
                  textController,
                  buildContext,
                  roomUid,
                );
                delegate.hideToolbar();
              }
            }
          : null,
      handleUnderline: () => handleFormatting(
        delegate,
        UnderlineFeature.specialChar,
      ),
      handleSpoiler: () => handleFormatting(
        delegate,
        SpoilerFeature.specialChar,
      ),
      handleBold: () => handleFormatting(delegate, BoldFeature.specialChar),
      handleItalic: () => handleFormatting(delegate, ItalicFeature.specialChar),
      handleStrikethrough: () => handleFormatting(
        delegate,
        StrikethroughFeature.specialChar,
      ),
      handleSelectAll:
          canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
      selectionMidpoint: selectionMidpoint,
      textLineHeight: textLineHeight,
      isAnyThingSelected: isAnyThingSelected,
      handleCreateLink: () => handleCreateLink(delegate),
    );
  }

  void moveCursor(TextSelectionDelegate delegate, int offset) {
    delegate.hideToolbar();
    textController.selection = TextSelection.collapsed(
      offset: offset,
    );
  }

  void handleFormatting(
    TextSelectionDelegate delegate,
    String specialChar,
  ) {
    if (isAnyThingSelected()) {
      final end = textController.selection.end;
      textController.text = createFormattedText(specialChar, textController);
      enableMarkDown();
      moveCursor(
        delegate,
        end + specialChar.length * 2,
      );
    }
  }

  bool isAnyThingSelected() {
    final start = textController.selection.start;
    final end = textController.selection.end;
    if (start != end &&
        textController.text.substring(start, end).trim().isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void handleCreateLink(
    TextSelectionDelegate delegate,
  ) {
    final formKey = GlobalKey<FormState>();
    final linkTextController = TextEditingController();
    final linkController = TextEditingController();
    final end = textController.selection.end;
    final start = textController.selection.start;

    if (isAnyThingSelected()) {
      linkTextController.text = textController.text.substring(start, end);
    }
    showDialog(
      context: buildContext,
      builder: (context) {
        return AlertDialog(
          actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
          content: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _i18n.get("create_link"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      createLinkTextField(
                        linkTextController,
                        _i18n.get("text"),
                      ),
                      const SizedBox(height: 10),
                      createLinkTextField(
                        linkController,
                        _i18n.get("link"),
                        useLinkValidator: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                _i18n.get("cancel"),
              ),
            ),
            TextButton(
              onPressed: () {
                final isValidated = formKey.currentState?.validate() ?? false;
                if (isValidated) {
                  final link =
                      createLink(linkTextController.text, linkController.text);

                  textController.text = textController.text.substring(
                        0,
                        start,
                      ) +
                      link +
                      textController.text.substring(
                        isAnyThingSelected() ? end : start,
                      );

                  Navigator.pop(context);
                }
              },
              child: Text(
                _i18n.get("create"),
              ),
            ),
          ],
        );
      },
    );
  }

  TextFormField createLinkTextField(
    TextEditingController controller,
    String label, {
    bool useLinkValidator = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: useLinkValidator ? validateLink : validateTextLink,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.only(),
        border: const UnderlineInputBorder(),
      ),
    );
  }

  String? validateLink(String? value) {
    final urlRegex = RegExp(UrlFeature.urlRegex);
    final inlineUrlRegex = RegExp(UrlFeature.inlineUrlRegex);
    if (value!.isEmpty) {
      return null;
    } else if (!urlRegex.hasMatch(value) && !inlineUrlRegex.hasMatch(value)) {
      return _i18n.get("link_valid");
    }
    return null;
  }

  String? validateTextLink(String? value) {
    if (value == null) return null;
    if (value.isEmpty) {
      return _i18n.get("text_empty");
    } else {
      return null;
    }
  }
}

const double _kArrowScreenPadding = 26.0;

// Generates the child that's passed into CupertinoTextSelectionToolbar.
class _CupertinoTextSelectionControlsToolbar extends StatefulWidget {
  const _CupertinoTextSelectionControlsToolbar({
    required this.clipboardStatus,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCopy,
    required this.handleCut,
    required this.handlePaste,
    required this.handleSelectAll,
    required this.selectionMidpoint,
    required this.textLineHeight,
    required this.handleBold,
    required this.handleItalic,
    required this.handleStrikethrough,
    required this.handleSpoiler,
    required this.handleUnderline,
    required this.isAnyThingSelected,
    required this.handleCreateLink,
  });

  final ClipboardStatusNotifier? clipboardStatus;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCopy;
  final VoidCallback? handleCut;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final VoidCallback handleBold;
  final VoidCallback handleItalic;
  final VoidCallback handleStrikethrough;
  final VoidCallback handleSpoiler;
  final VoidCallback handleUnderline;
  final VoidCallback handleCreateLink;
  final Offset selectionMidpoint;
  final double textLineHeight;
  final bool Function() isAnyThingSelected;

  @override
  _CupertinoTextSelectionControlsToolbarState createState() =>
      _CupertinoTextSelectionControlsToolbarState();
}

class _CupertinoTextSelectionControlsToolbarState
    extends State<_CupertinoTextSelectionControlsToolbar> {
  ClipboardStatusNotifier? _clipboardStatus;
  final _i18n = GetIt.I.get<I18N>();

  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.handlePaste != null) {
      _clipboardStatus = widget.clipboardStatus ?? ClipboardStatusNotifier();
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
      _clipboardStatus!.update();
    }
  }

  @override
  void didUpdateWidget(_CupertinoTextSelectionControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clipboardStatus != widget.clipboardStatus) {
      if (_clipboardStatus != null) {
        _clipboardStatus!.removeListener(_onChangedClipboardStatus);
        _clipboardStatus!.dispose();
      }
      _clipboardStatus = widget.clipboardStatus ?? ClipboardStatusNotifier();
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
      if (widget.handlePaste != null) {
        _clipboardStatus!.update();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    // When used in an Overlay, this can be disposed after its creator has
    // already disposed _clipboardStatus.
    if (_clipboardStatus != null && !_clipboardStatus!.disposed) {
      _clipboardStatus!.removeListener(_onChangedClipboardStatus);
      if (widget.clipboardStatus == null) {
        _clipboardStatus!.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't render the menu until the state of the clipboard is known.
    if (widget.handlePaste != null &&
        _clipboardStatus!.value == ClipboardStatus.unknown) {
      return const SizedBox.shrink();
    }

    assert(debugCheckHasMediaQuery(context));
    final mediaQuery = MediaQuery.of(context);

    // The toolbar should appear below the TextField when there is not enough
    // space above the TextField to show it, assuming there's always enough
    // space at the bottom in this case.
    final anchorX =
        (widget.selectionMidpoint.dx + widget.globalEditableRegion.left).clamp(
      _kArrowScreenPadding + mediaQuery.padding.left,
      mediaQuery.size.width - mediaQuery.padding.right - _kArrowScreenPadding,
    );

    // The y-coordinate has to be calculated instead of directly quoting
    // selectionMidpoint.dy, since the caller
    // (TextSelectionOverlay._buildToolbar) does not know whether the toolbar is
    // going to be facing up or down.
    final anchorAbove = Offset(
      anchorX,
      widget.endpoints.first.point.dy -
          widget.textLineHeight +
          widget.globalEditableRegion.top,
    );
    final anchorBelow = Offset(
      anchorX,
      widget.endpoints.last.point.dy + widget.globalEditableRegion.top,
    );

    final items = <Widget>[];
    final localizations = CupertinoLocalizations.of(context);
    final Widget onePhysicalPixelVerticalDivider = SizedBox(
      width: 1.0 / MediaQuery.of(context).devicePixelRatio,
    );

    void addToolbarButton(
      String text,
      VoidCallback onPressed,
      IconData iconData, {
      Color? textColor,
    }) {
      if (items.isNotEmpty) {
        items.add(onePhysicalPixelVerticalDivider);
      }

      items.add(
        TextButton(
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: onPressed,
          child: isDesktop
              ? Row(
                  children: [
                    Icon(
                      iconData,
                      size: 15,
                      color: textColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(text, style: TextStyle(color: textColor)),
                  ],
                )
              : Text(text),
        ),
      );
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
        Icons.paste_outlined,
      );
    }
    if (widget.handleSelectAll != null) {
      addToolbarButton(
        localizations.selectAllButtonLabel,
        widget.handleSelectAll!,
        Icons.select_all_rounded,
      );
    }
    if (isDesktop) {
      items.add(const Divider());
    }

    //todo more user of  final _i18n = GetIt.I.get<I18N>();
    if (widget.isAnyThingSelected() || isDesktop) {
      Color? color;
      if (!widget.isAnyThingSelected()) color = Colors.grey;
      addToolbarButton(
        _i18n.get("bold"),
        widget.handleBold,
        Icons.format_bold_rounded,
        textColor: color,
      );
      addToolbarButton(
        _i18n.get("italic"),
        widget.handleItalic,
        Icons.format_italic_rounded,
        textColor: color,
      );
      addToolbarButton(
        _i18n.get("strike_through"),
        widget.handleStrikethrough,
        Icons.strikethrough_s_rounded,
        textColor: color,
      );
      addToolbarButton(
        _i18n.get("spoiler"),
        widget.handleSpoiler,
        Icons.hide_source_rounded,
        textColor: color,
      );
      addToolbarButton(
        _i18n.get("underline"),
        widget.handleUnderline,
        Icons.format_underline_rounded,
        textColor: color,
      );
    }
    if (isDesktop) {
      items.add(const Divider());
    }
    addToolbarButton(
      _i18n.get("create_link"),
      widget.handleCreateLink,
      Icons.link_rounded,
    );

    // If there is no option available, build an empty widget.
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return isDesktop
        ? CustomSingleChildLayout(
            delegate: TextSelectionToolbarLayoutDelegate(
              anchorAbove: anchorAbove,
              anchorBelow: anchorBelow,
            ),
            child: Container(
              width: 150,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                boxShadow: DEFAULT_BOX_SHADOWS,
                borderRadius: tertiaryBorder,
                color: Theme.of(context).dialogBackgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: items,
              ),
            ),
          )
        : TextSelectionToolbar(
            anchorAbove: anchorAbove,
            anchorBelow: anchorBelow,
            children: items,
          );
  }
}
