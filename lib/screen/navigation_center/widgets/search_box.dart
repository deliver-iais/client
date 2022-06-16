import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final _focusNode = FocusNode(canRequestFocus: false);
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        style: const TextStyle(fontSize: 16),
        focusNode: _focusNode,
        controller: widget.controller ?? _localController,
        onChanged: (str) {
          if (str.isNotEmpty) {
            _hasText.add(true);
          } else {
            _hasText.add(false);
          }
          widget.onChange(str);
        },
        decoration: InputDecoration(
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
                    _focusNode.unfocus();
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
    );
  }
}
