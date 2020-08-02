

import 'package:deliver_flutter/screen/app-auth/widgets/inputFeilds.dart';
import 'package:deliver_flutter/shared/Widget/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


class InnearTestFelIdWidget extends StatelessWidget{

 final String hint;
 final String widgetkey;
 final Stream  onchange;


 InnearTestFelIdWidget({this.widgetkey,this.hint, this.onchange});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:TextFieldId(hint: this.hint,widgetkey: this.widgetkey,setColor: false,setbacroundColor: false,)
    );
  }
}

void main() {
  testWidgets('input field test ', (WidgetTester tester) async {
    await tester.pumpWidget(InnearTestFelIdWidget(hint: 'g',widgetkey: '123'
    ));

    await tester.enterText(find.byKey(Key("123")),"456");
    await  expect(find.text("456"),findsOneWidget);
    await tester.enterText(find.byKey(Key("123")),"54546");
    await tester.enterText(find.byKey(Key("123")), "");
    await expect(find.text(""), findsOneWidget);


  });
}