import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BuildInputCaption extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();
  final TextEditingController captionEditingController;
  final void Function() send;
  final int count;

  BuildInputCaption({
    Key? key,
    required this.captionEditingController,
    required this.send,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: BOTTOM_BUTTONS_HEIGHT,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Center(
        child: AutoDirectionTextField(
          decoration: InputDecoration(
            hintText: _i18n.get("add_caption"),
            border: InputBorder.none,
            hintStyle: const TextStyle(fontSize: 16),
            suffixIcon: buildSendButton(theme),
            hintTextDirection: _i18n.defaultTextDirection,
            isCollapsed: true,
            // TODO(bitbeter): باز باید بررسی بشه که چیه ماجرای این کد و به صورت کلی حل بشه و نه با شرط دسکتاپ بودن
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: isDesktop ? 9 : 16,
              left: 16,
              right: 8,
            ),
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.newline,
          minLines: 1,
          maxLines: 15,
          controller: captionEditingController,
        ),
      ),
    );
  }

  Stack buildSendButton(ThemeData theme) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              CupertinoIcons.arrow_up,
              color: theme.colorScheme.primary,
            ),
            onPressed: send,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: AnimatedScale(
            duration: VERY_SLOW_ANIMATION_DURATION,
            curve: Curves.easeInOut,
            scale: count > 0 ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
              ),
              padding: const EdgeInsets.all(1),
              width: 18,
              height: 18,
              child: AnimatedSwitchWidget(
                child: Text(
                  key: ValueKey(count),
                  count.toString(),
                  style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ), // inner content
            ),
          ),
        ),
      ],
    );
  }
}
