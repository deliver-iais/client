
import 'package:universal_html/html.dart' as html;

html.Blob convertDataByteToBlob(String dataByte, String type) {
  return html.Blob(
    <Object>[UriData.parse(dataByte).contentAsBytes()],
    type,
  );
}
Future<String> getDataByteFromBlob(html.Blob blob) async {
  final reader = html.FileReader()..readAsDataUrl(blob);
  await reader.onLoadEnd
      .firstWhere((element) => element.isTrusted ?? false);
  return reader.result.toString();
}

String convertBlobToBlobUrl(
  html.Blob blob,
) {
  return html.Url.createObjectUrlFromBlob(blob);
}
