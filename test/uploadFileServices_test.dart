import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test("upload file test ", () async {
    File file = await FilePicker.getFile().then((value){
      File f = value as File;
      if(f.existsSync()){
        print("file.exit");
      }

    });
  });
}