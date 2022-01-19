import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchBox extends StatefulWidget {
  final Function(String) onChange;
  final Function? onCancel;
  final BorderRadius borderRadius;
  late final TextEditingController controller;

  SearchBox(
      {Key? key,
      required this.onChange,
      this.onCancel,
      this.borderRadius = const BorderRadius.all(Radius.circular(25.0)),
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
  final i18n = GetIt.I.get<I18N>();

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.symmetric(
          horizontal: _focusNode.hasFocus ? 0 : 8, vertical: 4),
      duration: ANIMATION_DURATION,
      child: TextField(
        style: const TextStyle(fontSize: 16, height: 1.2),
        textAlignVertical: TextAlignVertical.center,
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
        cursorColor: ExtraTheme.of(context).centerPageDetails,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius / 10,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius,
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 0.0,
            ),
          ),
          contentPadding: const EdgeInsets.all(12),
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
          hintText: i18n.get("search"),
        ),
      ),
    );
  }
}
