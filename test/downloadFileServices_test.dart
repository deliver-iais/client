

import 'dart:math';

import 'package:deliver_flutter/services/downloadFileServices.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';


void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<DownloadFileServices>(DownloadFileServices());
  FlutterDownloader.initialize();
  var downloadFile = GetIt.I.get<DownloadFileServices>();
  test('Download file test',(){
    var download =  downloadFile.downloadFile("https://picsum.photos/200/300", Random().nextInt(5).toString());

    download.then((value) {
      prints("download result" +value.toString());

    }).catchError((e){
      print("downloadFile error :"+ e.toString());

    });
  });
}

//import 'package:test/test.dart';
//import 'package:counter_app/counter.dart';
//
//void main() {
//  test('Counter value should be incremented', () {
//    final counter = Counter();
//
//    counter.increment();
//
//    expect(counter.value, 1);
//  });
//}

// muc server