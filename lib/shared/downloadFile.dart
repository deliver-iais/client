

import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permissions_plugin/permissions_plugin.dart';

class DownloadFile {
  Future<String>  downloadFile (String url) async{
    var taskId =await FlutterDownloader.enqueue(
      url: "https://picsum.photos/200/300",
      fileName: "asdasdasd.jpg",
      savedDir: await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_PICTURES),
      // todo save file in external storage
      showNotification: false,
      openFileFromNotification: false,
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