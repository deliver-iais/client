import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AutoDirectionTextForm extends StatefulWidget {
  final TextEditingController? controller;

  final FocusNode? focusNode;

  final InputDecoration? decoration;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final TextCapitalization textCapitalization;

  final TextStyle? style;

  final StrutStyle? strutStyle;

  final TextAlign textAlign;

  final TextAlignVertical? textAlignVertical;

  final TextDirection? textDirection;

  final bool autofocus;

  final String obscuringCharacter;

  final bool obscureText;

  final bool autocorrect;

  final SmartDashesType? smartDashesType;

  final SmartQuotesType? smartQuotesType;

  final bool enableSuggestions;

  final int? maxLines;

  final int? minLines;

  final bool expands;

  final bool readOnly;

  final EditableTextContextMenuBuilder? contextMenuBuilder;

  final bool? showCursor;

  static const int noMaxLength = -1;

  final int? maxLength;

  final MaxLengthEnforcement? maxLengthEnforcement;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onEditingComplete;

  final AppPrivateCommandCallback? onAppPrivateCommand;

  final List<TextInputFormatter>? inputFormatters;

  final bool? enabled;

  final double cursorWidth;

  final double? cursorHeight;

  final Radius? cursorRadius;

  final Color? cursorColor;

  final Brightness? keyboardAppearance;

  final EdgeInsets scrollPadding;

  final bool? enableInteractiveSelection;

  final TextSelectionControls? selectionControls;

  final ScrollPhysics? scrollPhysics;

  final Iterable<String>? autofillHints;

  final String? restorationId;

  final bool enableIMEPersonalizedLearning;

  final AutovalidateMode? autovalidateMode;

  final InputCounterWidgetBuilder? buildCounter;

  final String? initialValue;

  final MouseCursor? mouseCursor;

  final ValueChanged<String>? onFieldSubmitted;

  final FormFieldSetter<String>? onSaved;

  final GestureTapCallback? onTap;

  final ScrollController? scrollController;

  final FormFieldValidator<String>? validator;

  const AutoDirectionTextForm({
    Key? key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.selectionControls,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.keyboardType,
    this.smartDashesType,
    this.smartQuotesType,
    this.contextMenuBuilder,
    this.enableInteractiveSelection,
    this.autovalidateMode,
    this.buildCounter,
    this.initialValue,
    this.mouseCursor,
    this.onFieldSubmitted,
    this.onSaved,
    this.onTap,
    this.scrollController,
    this.validator,
  }) : super(key: key);

  @override
  State<AutoDirectionTextForm> createState() => _AutoDirectionTextFormState();
}

class _AutoDirectionTextFormState extends State<AutoDirectionTextForm> {
  static final direction = BehaviorSubject<TextDirection?>.seeded(null);
  static final _i18n = GetIt.I.get<I18N>();
  static final _controller = TextEditingController();

  @override
  void initState() {
    getController().addListener(() {
      final value = getController().text;
      if (value.isNotEmpty) {
        direction.add(_i18n.getDirection(value));
      } else {
        direction.add(null);
      }
    });
    super.initState();
  }

  TextEditingController getController() => widget.controller ?? _controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TextDirection?>(
      stream: direction.distinct(),
      builder: (c, sn) {
        final textDir = sn.data ?? _i18n.defaultTextDirection;
        return TextFormField(
          controller: widget.controller ?? _controller,
          focusNode: widget.focusNode,
          decoration: widget.decoration,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          style: widget.style,
          strutStyle: widget.strutStyle,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          textDirection: widget.textDirection ?? textDir,
          readOnly: widget.readOnly,
          contextMenuBuilder: widget.contextMenuBuilder,
          showCursor: widget.showCursor,
          autofocus: widget.autofocus,
          obscuringCharacter: widget.obscuringCharacter,
          obscureText: widget.obscureText,
          autocorrect: widget.autocorrect,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          enableSuggestions: widget.enableSuggestions,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          cursorWidth: widget.cursorWidth,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius,
          cursorColor: widget.cursorColor,
          keyboardAppearance: widget.keyboardAppearance,
          scrollPadding: widget.scrollPadding,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          selectionControls: widget.selectionControls,
          scrollPhysics: widget.scrollPhysics,
          autofillHints: widget.autofillHints,
          restorationId: widget.restorationId,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          autovalidateMode: widget.autovalidateMode,
          buildCounter: widget.buildCounter,
          expands: widget.expands,
          initialValue: widget.initialValue,
          mouseCursor: widget.mouseCursor,
          onFieldSubmitted: widget.onFieldSubmitted,
          onSaved: widget.onSaved,
          onTap: () {
            // TODO(Chitsaz): This line of code is for select last character in text field in rtl languages

            final localController = widget.controller ?? _controller;
            if (localController.selection ==
                TextSelection.fromPosition(
                  TextPosition(
                    offset: localController.text.length - 1,
                  ),
                )) {
              localController.selection = TextSelection.fromPosition(
                TextPosition(
                  offset: localController.text.length,
                ),
              );
            }
            if (localController.text.isNotEmpty &&
                localController.text[localController.text.length - 1] != ' ') {
              final selection = localController.selection;
              localController
                ..text = ('${localController.text} ')
                ..selection = selection;
            }

            widget.onTap?.call();
          },
          scrollController: widget.scrollController,
          validator: widget.validator,
        );
      },
    );
  }
}
