import 'dart:math';

import 'package:deliver_flutter/services/downloadFileServices.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockDownloadFileServices extends Mock implements DownloadFileServices {}

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  GetIt getIt = GetIt.instance;

  FlutterDownloader.initialize();
  test('Download file test', () {
   when(MockDownloadFileServices().downloadFile("https://picsum.photos/200/300", Random().nextInt(5).toString())).thenAnswer((realInvocation){
     print("re");
     return Future.value("");
   });

  });
}
