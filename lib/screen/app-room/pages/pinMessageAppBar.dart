import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:sorted_list/sorted_list.dart';

class PinMessageAppBar extends StatelessWidget {
  final BehaviorSubject<int> lastPinedMessage;
  final SortedList pinMessages;
  final Function onTap;
  final Function onCancel;

  PinMessageAppBar(
      {Key key, this.lastPinedMessage, this.pinMessages, this.onTap,this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return StreamBuilder<int>(
        stream: lastPinedMessage.stream,
        builder: (c, id) {
          if (id.hasData && id.data > 0) {
            var body = "";
            Message mes;
            pinMessages.forEach((m) {
              if (m.id == id.data) {
                mes = m;
              }
            });
            switch (mes.type) {
              case MessageType.TEXT:
                body = mes.json.toText().text;
                break;
              case MessageType.FILE:
                body = "File";
                break;
              case MessageType.STICKER:
                body = "Sticker";
                break;
              case MessageType.LOCATION:
                body = "Location";
                break;
              case MessageType.LIVE_LOCATION:
                body = "Live Location";
                break;
              case MessageType.POLL:
                body = "Poll";
                break;
              case MessageType.FORM:
                body = "Form";
                break;
              case MessageType.PERSISTENT_EVENT:
                // TODO: Handle this case.
                break;
              case MessageType.NOT_SET:
                // TODO: Handle this case.
                break;
              case MessageType.BUTTONS:
                body = "From";
                break;
              case MessageType.SHARE_UID:
                body = "contact";
                break;
              case MessageType.FORM_RESULT:
                // TODO: Handle this case.
                break;
              case MessageType.SHARE_PRIVATE_DATA_REQUEST:
                body = "Private Data";
                break;
              case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
                // TODO: Handle this case.
                break;
            }
            return GestureDetector(
              onTap: () {
                onTap(id.data, mes);
              },
              child: Container(
                padding:
                    const EdgeInsets.only(left: 8, right: 3, bottom: 8, top: 0),
                color: ExtraTheme.of(context).pinMessageTheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appLocalization.getTraslateValue("pinned_message"),
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                        IconButton(
                            onPressed: () {
                              onCancel();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.blue,
                            ))
                      ],
                    ),
                    Container(
                        child: Text(
                      body,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ExtraTheme.of(context).textField,
                      ),
                    )),
                  ],
                ),
              ),
            );
          } else
            return SizedBox.shrink();
        });
  }
}
