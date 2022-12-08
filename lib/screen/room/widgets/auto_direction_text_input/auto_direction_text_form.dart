import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AutoDirectionTextForm extends StatelessWidget {
  static final direction =
      BehaviorSubject<TextDirection>.seeded(TextDirection.ltr);
  static final _i18n = GetIt.I.get<I18N>();
  static final _controller = TextEditingController();

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

  final ToolbarOptions? toolbarOptions;

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
    this.toolbarOptions,
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
  Widget build(BuildContext context) {
    return StreamBuilder<TextDirection>(
      stream: direction.distinct(),
      builder: (c, sn) {
        final textDir = sn.data ?? TextDirection.ltr;
        return TextFormField(
          controller: controller ?? _controller,
          focusNode: focusNode,
          decoration: decoration,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textAlignVertical: textAlignVertical,
          textDirection: textDirection ?? textDir,
          readOnly: readOnly,
          toolbarOptions: toolbarOptions,
          showCursor: showCursor,
          autofocus: autofocus,
          obscuringCharacter: obscuringCharacter,
          obscureText: obscureText,
          autocorrect: autocorrect,
          smartDashesType: smartDashesType,
          smartQuotesType: smartQuotesType,
          enableSuggestions: enableSuggestions,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          maxLengthEnforcement: maxLengthEnforcement,
          onChanged: (value) {
            if (value.isNotEmpty) {
              direction.add(_i18n.getDirection(value));
            }
            onChanged?.call(value);
          },
          onEditingComplete: onEditingComplete,
          inputFormatters: inputFormatters,
          enabled: enabled,
          cursorWidth: cursorWidth,
          cursorHeight: cursorHeight,
          cursorRadius: cursorRadius,
          cursorColor: cursorColor,
          keyboardAppearance: keyboardAppearance,
          scrollPadding: scrollPadding,
          enableInteractiveSelection: enableInteractiveSelection,
          selectionControls: selectionControls,
          scrollPhysics: scrollPhysics,
          autofillHints: autofillHints,
          restorationId: restorationId,
          enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
          autovalidateMode: autovalidateMode,
          buildCounter: buildCounter,
          expands: expands,
          initialValue: initialValue,
          mouseCursor: mouseCursor,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          onTap: () {
            // TODO(Chitsaz): This line of code is for select last character in text field in rtl languages

            final localController = controller ?? _controller;
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

            onTap?.call();
          },
          scrollController: scrollController,
          validator: validator,
        );
      },
    );
  }
}
