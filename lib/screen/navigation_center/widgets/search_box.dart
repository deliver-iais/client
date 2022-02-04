import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchBox extends StatefulWidget {
  final Function(String) onChange;
  final Function? onCancel;
  late final TextEditingController controller;

  SearchBox(
      {Key? key,
      required this.onChange,
      this.onCancel,
      TextEditingController? controller})
      : super(key: key) {
    this.controller = controller ?? TextEditingController();
  }

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final BehaviorSubject<bool> _hasText = BehaviorSubject.seeded(false);
  final _focusNode = FocusNode(canRequestFocus: false);
  static final _i18n = GetIt.I.get<I18N>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        style: const TextStyle(fontSize: 16, height: 1.2),
        textAlign: TextAlign.start,
        focusNode: _focusNode,
        controller: widget.controller,
        autofocus: false,
        maxLines: 1,
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
          prefixIcon: const Icon(
            CupertinoIcons.search,
            // size: 20,
          ),
          suffixIcon: StreamBuilder<bool?>(
            stream: _hasText.stream,
            builder: (c, ht) {
              if (ht.hasData && ht.data!) {
                return IconButton(
                  iconSize: 20,
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () {
                    _hasText.add(false);
                    widget.controller.clear();
                    _focusNode.unfocus();
                    widget.onCancel!();
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
