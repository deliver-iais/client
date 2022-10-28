import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchBox extends StatefulWidget {
  final void Function(String) onChange;
  final void Function()? onCancel;
  final TextEditingController? controller;

  const SearchBox({
    super.key,
    required this.onChange,
    this.onCancel,
    this.controller,
  });

  @override
  SearchBoxState createState() => SearchBoxState();
}

class SearchBoxState extends State<SearchBox> {
  final TextEditingController _localController = TextEditingController();
  final BehaviorSubject<bool> _hasText = BehaviorSubject.seeded(false);
  final _localFocusNode = FocusNode(canRequestFocus: false);
  final _keyboardVisibilityController = KeyboardVisibilityController();
  static final _i18n = GetIt.I.get<I18N>();

  void _clearTextEditingController() {
    widget.controller?.clear();
    _localController.clear();
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (hasVirtualKeyboardCapability) {
      _keyboardVisibilityController.onChange.listen((event) {
        if (!event) {
          _localFocusNode.unfocus();
        }
      });
    }
    (widget.controller ?? _localController).addListener(() {
      if ((widget.controller ?? _localController).text.isNotEmpty) {
        _hasText.add(true);
      } else {
        _hasText.add(false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Directionality(
        textDirection: _i18n.defaultTextDirection,
        child: SizedBox(
          height: 40,
          child: AutoDirectionTextField(
            style: const TextStyle(fontSize: 16),
            focusNode: _localFocusNode,
            controller: widget.controller ?? _localController,
            onChanged: (str) {
              widget.onChange(str);
            },
            decoration: InputDecoration(
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
                stream: _hasText,
                builder: (c, ht) {
                  if (ht.hasData && ht.data!) {
                    return IconButton(
                      icon: const Icon(CupertinoIcons.xmark),
                      onPressed: () {
                        _hasText.add(false);
                        _clearTextEditingController();
                        _localFocusNode.unfocus();
                        widget.onCancel?.call();
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              hintText: _i18n.get("search"),
            ),
          ),
        ),
      ),
    );
  }
}
