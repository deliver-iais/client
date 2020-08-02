import 'package:deliver_flutter/screen/app-auth/widgets/inputFeilds.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){



  String code = "12";
  String phoneNum = "91234567";
  String inputError;

  testWidgets("Input Feilds test", (WidgetTester  tester ) async {
     await tester.pumpWidget(InputFeilds( onChangeCode: (val) =>
           () {
         code = val;
         inputError = inputError == "code"
             ? null
             : inputError == "both" ? "phoneNum" : null;
         print(val);
       },

       onChangePhoneNum: (val) =>(
             () {
           phoneNum = val;
           inputError = inputError == "phoneNum"
               ? null
               : inputError == "both" ? "code" : null;
           print(val);
         }),

       inputError: inputError,));

  });

}