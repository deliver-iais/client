

import 'package:deliver_flutter/screen/app-auth/widgets/inputFeilds.dart';
import 'package:deliver_flutter/shared/Widget/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


class InnearTestFelIdWidget extends StatelessWidget{

 final String hint;
 final String widgetkey;

 InnearTestFelIdWidget({this.widgetkey,this.hint});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:TextFieldId(hint: this.hint,widgetkey: this.widgetkey,setColor: false,)
    );
  }

}

void main() {
  testWidgets('MyWidget has a title and message', (WidgetTester tester) async {
    await tester.pumpWidget(InnearTestFelIdWidget(hint: 'g',widgetkey: '123',));

    await find.byKey(Key("123"));
    await tester.enterText(find.byKey(Key("123")),"456");
    expect(find.text("456"),findsOneWidget);







  });
}