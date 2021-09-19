import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class SettingsRow extends StatelessWidget {
  final Widget child;

  final Function onClick;

  final IconData iconData;

  final String title;

  const SettingsRow({Key key, this.child, this.onClick, this.iconData, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onClick == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onClick?.call();
        },
        child: Container(
          constraints: BoxConstraints(minHeight: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(width: 8),
                  Icon(
                    iconData,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                        color: ExtraTheme.of(context).textField, fontSize: 16),
                  ),
                ],
              ),
              child
            ],
          ),
        ),
      ),
    );
  }
}
