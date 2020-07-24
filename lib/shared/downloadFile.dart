import 'dart:html';

import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadFile {
  Future<String>  downloadFile (String url) async{


    var taskId =await FlutterDownloader.enqueue(
      url: url,
      savedDir: 'deliverFluter in external storeage ',
      showNotification: true, // show download progress in status bar (for Android)
    );
    return taskId;

  }

  cancelDownload( String taskId){
    FlutterDownloader.cancel(taskId: taskId);
  }

  cancelAllDownload(){
    FlutterDownloader.cancelAll();
  }

}