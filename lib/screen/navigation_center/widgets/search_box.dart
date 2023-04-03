import 'package:animate_do/animate_do.dart';
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
  final void Function(String)? onChange;
  final void Function()? onTap;
  final void Function()? onCancel;
  final void Function()? onSearchEnd;
  final double? animationValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const SearchBox({
    super.key,
    this.onChange,
    this.onCancel,
    this.controller,
    this.onTap,
    this.onSearchEnd,
    this.animationValue,
    this.focusNode,
  });

  @override
  SearchBoxState createState() => SearchBoxState();
}

class SearchBoxState extends State<SearchBox> {
  final TextEditingController _localController = TextEditingController();
  final BehaviorSubject<bool?> _hasText = BehaviorSubject.seeded(null);
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

  FocusNode _getFocusNode() {
    return widget.focusNode ?? _localFocusNode;
  }

  @override
  void initState() {
    if (hasVirtualKeyboardCapability) {
      _keyboardVisibilityController.onChange.listen((event) {
        if (!event) {
          _getFocusNode().unfocus();
        }
      });
    }
    (widget.controller ?? _localController).addListener(() {
      if ((widget.controller ?? _localController).text.isNotEmpty) {
        _hasText.add(true);
      } else if (_hasText.value ?? false) {
        _hasText.add(false);
      }
    });
    super.initState();
  }

  double get height =>
      widget.animationValue != null ? (43 - (widget.animationValue! / 4)) : 40;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: height,
              child: AutoDirectionTextField(
                style: const TextStyle(fontSize: 16),
                focusNode: _getFocusNode(),
                controller: widget.controller ?? _localController,
                onChanged: (str) {
                  widget.onChange?.call(str);
                },
                onTap: () {
                  widget.onTap?.call();
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsetsDirectional.only(top: 1),
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
                      if (ht.hasData) {
                        if (ht.data!) {
                          return _buildZoomInClearIcon();
                        } else {
                          return _buildZoomOutClearIcon();
                        }
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
          if (widget.animationValue != null)
            SizedBox(
              width: (widget.animationValue! - 40) * -1.7,
              height: height,
              child: IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () {
                  widget.onSearchEnd?.call();
                  _hasText.add(false);
                  _clearTextEditingController();
                  _getFocusNode().unfocus();
                },
                icon: Opacity(
                  opacity: widget.animationValue! < 10
                      ? ((widget.animationValue!) - 40) * -1 / 40
                      : 0,
                  child: Text(_i18n.get("cancel")),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildZoomInClearIcon() {
    return Spin(
      key: const Key("zoom-in"),
      spins: 1 / 4,
      duration: const Duration(milliseconds: 200),
      child: ZoomIn(
        duration: const Duration(milliseconds: 200),
        child: _buildClearIcon(),
      ),
    );
  }

  Widget _buildClearIcon() {
    return IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        _hasText.add(false);
        _clearTextEditingController();
        _getFocusNode().unfocus();
        widget.onCancel?.call();
      },
    );
  }

  Widget _buildZoomOutClearIcon() {
    return Spin(
      key: const Key("zoom-out"),
      spins: 1 / 4,
      duration: const Duration(milliseconds: 200),
      child: ZoomOut(
        duration: const Duration(milliseconds: 400),
        child: _buildClearIcon(),
      ),
    );
  }
}
