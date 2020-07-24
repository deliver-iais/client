import 'dart:io';
import 'package:http/http.dart' as http;
class UploadFile {
  Uri _uri;

  uploadFile(String text , File file) async {
    var request  = http.MultipartRequest("POST",_uri);

    request.fields["text_field"] = text;
    var uploadFile = await http.MultipartFile.fromPath("fileId",file.path);
    request.files.add(uploadFile);
    var response = await request.send();

    var responseData = await response.stream.toString();
    print( "uploadfilew result " + responseData);




  }

}