import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareBoxInputCaption extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();
  final void Function(String) onSend;
  final int count;

  ShareBoxInputCaption({
    Key? key,
    required this.onSend,
    required this.count,
  }) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: BOTTOM_BUTTONS_HEIGHT,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Row(
        children: [
          buildSendButton(theme),
          const SizedBox(
            width: 5,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AutoDirectionTextField(
                decoration: InputDecoration(
                  hintText: _i18n.get("add_caption"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(),
                  ),
                  hintStyle: const TextStyle(fontSize: 16),
                  hintTextDirection: _i18n.defaultTextDirection,
                  isCollapsed: true,
                  // TODO(bitbeter): باز باید بررسی بشه که چیه ماجرای این کد و به صورت کلی حل بشه و نه با شرط دسکتاپ بودن
                  contentPadding: EdgeInsetsDirectional.only(
                    top: 12,
                    bottom: isDesktopDevice ? 9 : 16,
                    start: 16,
                    end: 8,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 15,
                controller: _controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSendButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 13),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: theme.primaryColor),
            child: IconButton(
                icon: Icon(
                  CupertinoIcons.location,
                  size: 28,
                  textDirection: TextDirection.ltr,
                  color: theme.colorScheme.background,
                ),
                onPressed: () {
                  onSend(_controller.text);
                }),
          ),
          Positioned(
            top: 0,
            left:1 ,
            child: AnimatedScale(
              duration: AnimationSettings.verySlow,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ), // inner content
              ),
            ),
          ),
        ],
      ),
    );
  }
}
