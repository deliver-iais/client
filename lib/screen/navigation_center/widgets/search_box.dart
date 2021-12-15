import 'package:deliver/localization/i18n.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchBox extends StatefulWidget {
  final Function(String) onChange;
  final Function? onCancel;
  final BorderRadius borderRadius;

  const SearchBox(
      {Key? key,
      required this.onChange,
      this.onCancel,
      this.borderRadius = const BorderRadius.all(Radius.circular(25.0))})
      : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final BehaviorSubject<bool> _hasText = BehaviorSubject.seeded(false);
  final TextEditingController _controller = TextEditingController();
  final _focusNode = FocusNode(canRequestFocus: false);
  final i18n = GetIt.I.get<I18N>();


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextField(
        style: TextStyle(color: ExtraTheme.of(context).textField),
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.start,
        focusNode: _focusNode,
        controller: _controller,
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
        cursorColor: ExtraTheme.of(context).centerPageDetails,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius / 4,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius,
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 0.0,
            ),
          ),
          contentPadding: const EdgeInsets.all(8),
          filled: true,
          isDense: true,
          prefixIcon: Icon(
            Icons.search,
            color: ExtraTheme.of(context).centerPageDetails,
            size: 20,
          ),
          suffixIcon: StreamBuilder<bool?>(
            stream: _hasText.stream,
            builder: (c, ht) {
              if (ht.hasData && ht.data!) {
                return IconButton(
                  icon: Icon(
                    Icons.close,
                    color: ExtraTheme.of(context).centerPageDetails,
                    size: 20,
                  ),
                  onPressed: () {
                    _hasText.add(false);
                    _controller.clear();
                    widget.onCancel!();
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          hintText: i18n.get("search"),
        ),
      ),
    );
  }
}
