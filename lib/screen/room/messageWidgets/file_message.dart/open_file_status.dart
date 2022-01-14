import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:universal_html/html.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart';

class OpenFileStatus extends StatelessWidget {
  final file_pb.File file;
  final String filePath;

  const OpenFileStatus({Key? key, required this.file, required this.filePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ExtraTheme.of(context).circularFileStatus,
        ),
        child: IconButton(
          padding: const EdgeInsets.all(0),
          alignment: Alignment.center,
          icon: Icon(
            Icons.insert_drive_file,
            color: ExtraTheme.of(context).fileMessageDetails,
            size: 33,
          ),
          onPressed: () async {
            if (kIsWeb) {
              var res = await http.get(Uri.parse(filePath));
              var blob = Blob([res.bodyBytes], file.type);
              var fileUrl = html.Url.createObjectUrl(blob);
              window.open(fileUrl, "_");
            } else {
              OpenFile.open(filePath);
            }
          },
        ));
  }
}
