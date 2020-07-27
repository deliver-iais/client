

import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadFile {


  // todo :  delete :  we call this in function to call downloadFile(). : to show progress in ui  widget
   static Future downloadCallback(String taskId, DownloadTaskStatus status, int progress) async {
    if (status == DownloadTaskStatus.complete) {
      print("Downlaod Compelete");
    }
    if(status == DownloadTaskStatus.canceled){
      print("Downlaod cancel");
    }
    if(status == DownloadTaskStatus.paused){
      print("Downlaod paused");
    }
    if(status == DownloadTaskStatus.failed){
      print("Downlaod failed");
    }
    if(status == DownloadTaskStatus.enqueued){
      print("Downlaod enqueued");
    }
    if(status == DownloadTaskStatus.running){
      print("Downlaod run");
    }

    print('task ($taskId) is in status ($status) and process ($progress)',);
    print(progress.toString()+"%");
  }


  Future<String>  downloadFile (String url, String fileName) async{

     // todo  start to delete : we call this in function to call downloadFile().

     FlutterDownloader.registerCallback(downloadCallback);

    // todo : end delete

    // todo : create folder before call this function
    _createFolder();

      var taskId = await FlutterDownloader.enqueue(
      url: "https://picsum.photos/200/300",
      fileName: "dbgasd.jpg",
      savedDir: await ExtStorage.getExternalStoragePublicDirectory("Deliver"),
      showNotification: false,
      openFileFromNotification: false,
    ).then((value)  {
      print("value="+value);
    }).catchError((e){
      print("canceldaownload" + e.toString());
    });

    return taskId;

  }
  _createFolder() async {
    final folderName = "Deliver";
    final path = Directory("$folderName");
    if ((await path.exists())) {
    } else {
     await path.create();
    }
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

  removeDownload(String taskId){
     FlutterDownloader.remove(taskId:taskId);
  }

  resumeDownload(String taskId){
     FlutterDownloader.resume(taskId: taskId);
  }


  pausedDownload(taskId){
     FlutterDownloader.pause(taskId: taskId);
   }


}