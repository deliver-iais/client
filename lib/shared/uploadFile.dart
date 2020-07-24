import 'dart:async';
import 'dart:io';

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;


class CloseableMultipartRequest extends http.MultipartRequest {
  http.Client client = http.Client();
   static var servicesDiscoverRepo = GetIt.I.get<ServicesDiscoveryRepo>();
  Uri _uri  = new Uri(host: servicesDiscoverRepo.FileConnection.host,port: servicesDiscoverRepo.FileConnection.port);
  CloseableMultipartRequest(String method, Uri uri) : super(method, uri);

  void cancel(){
    client.close();

  @override
  Future<http.StreamedResponse> uploadFile(File file) async {
    try {
      var request = http.MultipartRequest("POST", _uri);
      var uploadFile= await http.MultipartFile.fromPath("file_field", file.path);
      request.files.add(uploadFile);
      var response = await client.send(request);
      print("responseStatusCode" + response.statusCode.toString());
    } catch (_) {
      client.close();
      rethrow;
    }
    finally{
      client.close();
  }

  Stream<T> onDone<T>(Stream<T> stream, void onDone()) =>
      stream.transform(new StreamTransformer.fromHandlers(handleDone: (sink) {
        sink.close();
        onDone();
      }));
}




  }

}