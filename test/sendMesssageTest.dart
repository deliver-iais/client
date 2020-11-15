



import 'dart:async';

import 'package:test/test.dart';

void main(){
  StreamController<String> streamController = StreamController<String>.broadcast();
  test("sendMessage", ()async {

    for(int i= 0 ;i<4;i++){
      streamController.add("A==$i");
    }
    for(int i=0;i<4;i++){
      streamController.stream.first.then((value) => (){
        print(value);
      });

    }
  });
}