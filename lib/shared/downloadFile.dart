

import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permissions_plugin/permissions_plugin.dart';

class DownloadFile {
  Future<String>  downloadFile (String url) async{
    var taskId =await FlutterDownloader.enqueue(
      url: "https://file-examples-com.github.io/uploads/2017/10/file_example_JPG_100kB.jpg",
      savedDir:  await Directory.current.path,
      // todo save file in external storage
      showNotification: true,
      openFileFromNotification: true,
      // show download progress in status bar (for Android)
    ).then((value)  {
      print("download");
    }).catchError((e){
      print("canceldaownload" + e.toString());
    });
    return taskId;

  }

  cancelDownload( String taskId){
    FlutterDownloader.cancel(taskId: taskId);
  }

  cancelAllDownload(){
    FlutterDownloader.cancelAll();
  }

  retryDownload(String taskId){
    FlutterDownloader.retry(taskId: taskId);
  }

}