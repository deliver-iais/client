import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as formModel;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:deliver_flutter/shared/extensions/json_extension.dart';

import '../timeAndSeenStatus.dart';

class FormResultWidget extends StatefulWidget {
  final Message message;
  final bool isSeen;
  FormResultWidget({this.message, this.isSeen});

  @override
  _FormResultWidgetState createState() => _FormResultWidgetState();
}

class _FormResultWidgetState extends State<FormResultWidget> {

  @override
  Widget build(BuildContext context) {
    var formResult = widget.message.json.toFormResult();

            return Stack(children: [
              Container(
                child: Column(
                  children: [
                    Text(
                      formResult.id,
                      style: TextStyle(fontSize: 16, color: ExtraTheme.of(context).textField),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: SizedBox(
                        width: 250,
                        child: ListView.builder(
                            itemCount: formResult.values.length,
                            shrinkWrap: true,
                            itemBuilder: (c, index) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "${formResult.values.keys.toList()[index]??""}  :  ",
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            ExtraTheme.of(context).textField),
                                  ),
                                  Expanded(
                                    child: Text(
                                      formResult.values.values
                                          .toList()[index]??"",
                                      // getText(form, index, formResult),
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              ExtraTheme.of(context).textField),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),

              TimeAndSeenStatus(widget.message, true, true, widget.isSeen),
            ]);

  }

  String getText(String body) {
    String text = "";
    if (body == null) {
      return "";
    } else {
      int textLenght = body.length;
      if (textLenght > 25) {
        int d = (textLenght / 25).floor();
        int i = 0;
        while (i <= d) {
          if (i < d) {
            text = text + body.substring(i * 25, (((i + 1) * 25) - 1)) + "\n";
          } else {
            text = text + body.substring(i * 25, textLenght);
          }
          i++;
        }
        return text;
      } else
        return body;
    }
  }
}
