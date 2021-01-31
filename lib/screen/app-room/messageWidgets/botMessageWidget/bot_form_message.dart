import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/formTextField_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';

class BotFormMessage extends StatefulWidget{
  final Message message;
  BotFormMessage({this.message});
  @override
  _BotFormMessageState createState() => _BotFormMessageState();
}


class _BotFormMessageState extends State<BotFormMessage> {
  proto.Form form;
  @override
  void initState() {
    form = widget.message.json.toForm();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListView.builder(itemCount: form.fields.length,itemBuilder: (c,index){
            switch(form.fields[index].whichType()){
              case proto.Form_Field_Type.textField:
                return FormTextFieldWidget(formField :form.fields[index] ,);
                break;
              case proto.Form_Field_Type.numberField:
                return FormTextFieldWidget(formField :form.fields[index] );
                break;
              case proto.Form_Field_Type.dateField:
                return FormTextFieldWidget(formField :form.fields[index] );
                break;
              case proto.Form_Field_Type.timeField:
                return FormTextFieldWidget(formField :form.fields[index] );
                break;
              case proto.Form_Field_Type.checkbox:
                return FormTextFieldWidget(formField :form.fields[index] );
                break;
              case proto.Form_Field_Type.radioButtonList:
                return FormTextFieldWidget(formField :form.fields[index] );
                break;
              case proto.Form_Field_Type.list:
                return FormTextFieldWidget(formField :form.fields[index] );
                break;
              case proto.Form_Field_Type.notSet:
                return FormTextFieldWidget(formField :form.fields[index] );
                break;

            }
            return SizedBox.shrink();

          }),

        ],
      ),
    );


  }


}