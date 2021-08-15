import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class MessageWrapper extends StatelessWidget {
  final Widget child;
  final bool isSent;

  const MessageWrapper({Key key, this.child, this.isSent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = const Radius.circular(8);
    final border = BorderRadius.all(radius).copyWith(
        bottomRight: isSent ? const Radius.circular(4) : radius,
        bottomLeft: !isSent ? const Radius.circular(4) : radius);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: border, boxShadow: [
          BoxShadow(
              color: Colors.black38, blurRadius: 0.5, offset: Offset(0, 0.5))
        ]),
        child: ClipRRect(
            borderRadius: border,
            child: Container(
                color: isSent
                    ? ExtraTheme.of(context).sentMessageBox
                    : ExtraTheme.of(context).receivedMessageBox,
                child: child)),
      ),
    );
  }
}
